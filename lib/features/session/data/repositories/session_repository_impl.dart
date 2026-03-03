import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/saved_session.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/session_local_datasource.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionLocalDatasource _local;
  final DioClient _dioClient;

  const SessionRepositoryImpl({
    required SessionLocalDatasource local,
    required DioClient dioClient,
  })  : _local     = local,
        _dioClient = dioClient;

  // ── Persistencia ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, SavedSession?>> getSavedSession() async {
    try {
      return right(await _local.getSession());
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSession(SavedSession s) async {
    try { await _local.saveSession(s); return right(unit); }
    catch (e) { return left(UnexpectedFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, Unit>> clearSession() async {
    try { await _local.clearSession(); return right(unit); }
    catch (e) { return left(UnexpectedFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, Unit>> touchSession() async {
    try { await _local.touchSession(); return right(unit); }
    catch (e) { return left(UnexpectedFailure(e.toString())); }
  }

  // ── Verificación de red y restauración ───────────────────────────────────

  @override
  Future<Either<Failure, SavedSession>> restoreSession(SavedSession session) async {
    // Configurar el cliente con el host guardado
    _dioClient.reconfigure(host: session.host, port: session.port);

    // 1. ¿Hay red? (ping ligero, timeout 3s)
    final reachable = await _ping();
    if (!reachable) {
      return left(NetworkFailure('El dispositivo no responde en ${session.host}'));
    }

    // 2. ¿La sesión sigue fresca y la cookie activa?
    if (session.isLikelyFresh && _dioClient.hasActiveSession) {
      final valid = await _checkCookie();
      if (valid) {
        await _local.touchSession();
        return right(session.copyWithNow());
      }
    }

    // 3. Sesión expirada — re-autenticar silenciosamente
    final reauthed = await _reAuth(login: session.login, password: session.password);
    if (reauthed) {
      final updated = session.copyWithNow();
      await _local.saveSession(updated);
      return right(updated);
    }

    // Credenciales rechazadas — el usuario debe volver al login
    return left(const AuthFailure('Credenciales inválidas. Inicia sesión nuevamente.'));
  }

  // ── Helpers privados ──────────────────────────────────────────────────────

  /// GET /favicon.ico con timeout de 3 s.
  /// Cualquier respuesta HTTP (incluso 404) = dispositivo en la red.
  Future<bool> _ping() async {
    try {
      await _dioClient.dio.get(
        '/favicon.ico',
        options: Options(
          sendTimeout:    const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
          validateStatus: (_) => true,
        ),
      );
      return true;
    } on DioException catch (e) {
      // Timeout o sin conexión = offline
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError   ||
          e.type == DioExceptionType.sendTimeout) {
        return false;
      }
      // Otro error HTTP = dispositivo responde
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Llamada autenticada ligera para verificar que la cookie sigue siendo válida.
  /// Un 401/403 indica sesión expirada.
  Future<bool> _checkCookie() async {
    try {
      final res = await _dioClient.dio.post(
        '/load_objects.fcgi',
        data: {'object': 'user', 'where': {'user': {'id': 0}}},
        options: Options(
          sendTimeout:    const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          validateStatus: (_) => true,
        ),
      );
      return res.statusCode != 401 && res.statusCode != 403;
    } catch (_) {
      return false;
    }
  }

  /// POST /login.fcgi con las credenciales guardadas.
  Future<bool> _reAuth({required String login, required String password}) async {
    try {
      final res = await _dioClient.dio.post(
        '/login.fcgi',
        data: {'login': login, 'password': password},
        options: Options(
          sendTimeout:    const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          validateStatus: (_) => true,
        ),
      );
      final body   = res.data is Map ? res.data as Map : <String, dynamic>{};
      final status = res.statusCode ?? 0;
      // ControlID devuelve session token en el body o simplemente 200
      return (status >= 200 && status < 300) && body['error'] == null;
    } catch (_) {
      return false;
    }
  }
}
