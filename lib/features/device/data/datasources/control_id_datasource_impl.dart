import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';
import 'device_remote_datasource.dart';

/// Implementación concreta del datasource para el **ControlID Flex**.
///
/// Toda la lógica de comunicación HTTP con el dispositivo está aquí.
/// Si mañana cambian a otro hardware, solo crean una nueva clase que
/// implemente [DeviceRemoteDatasource] y la registran en el contenedor
/// de inyección de dependencias.
class ControlIdDatasourceImpl implements DeviceRemoteDatasource {
  final DioClient _client;

  const ControlIdDatasourceImpl(this._client);

  // ── Login ─────────────────────────────────────────────────────────────────

  @override
  Future<void> login({
    required String login,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post(
        AppConfig.loginEndpoint,
        data: {
          'login': login,
          'password': password,
        },
      );

      _handleStatusCode(response.statusCode, response.data);

      // El ControlID responde con un JSON que incluye "session" cuando el
      // login es exitoso. Si el campo no existe o session es null → error.
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const AuthException('Respuesta de login inesperada.');
      }

      // Algunos firmwares devuelven { "session": "abc123" }
      // Otros devuelven { "logged": true }
      final hasSession  = body['session'] != null;
      final hasLogged   = body['logged'] == true;
      final hasError    = body['error'] != null;

      if (hasError || (!hasSession && !hasLogged)) {
        final msg = body['error']?.toString() ?? 'Credenciales inválidas.';
        throw AuthException(msg);
      }

      // Si llegamos aquí, el [SessionCookieInterceptor] ya capturó la cookie.
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  // ── Get Users ─────────────────────────────────────────────────────────────

  @override
  Future<List<UserModel>> getUsers() async {
    if (!_client.hasActiveSession) {
      throw const SessionExpiredException();
    }

    try {
      final response = await _client.dio.post(
        AppConfig.loadObjectsEndpoint,
        data: {
          'object': AppConfig.userObject,

        },
      );

      _handleStatusCode(response.statusCode, response.data);

      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const ParseException('Respuesta de usuarios inesperada.');
      }

      final rawList = body[AppConfig.userObject];
      if (rawList == null) return [];
      if (rawList is! List) {
        throw const ParseException('El campo "user" no es una lista.');
      }

      return rawList
          .whereType<Map<String, dynamic>>()
          .map(UserModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    try {
      // Intentamos hacer logout en el servidor; si falla no importa,
      // igual limpiamos la sesión local.
      await _client.dio.post(AppConfig.logoutEndpoint);
    } catch (_) {
      // Ignoramos errores de red en logout
    } finally {
      _client.clearSession();
    }
  }

  // ── Helpers privados ──────────────────────────────────────────────────────

  /// Lanza la excepción adecuada según el status code HTTP.
  Never? _handleStatusCode(int? status, dynamic body) {
    if (status == null) throw const NetworkException();
    if (status == 401) throw const AuthException();
    if (status == 403) throw const SessionExpiredException();
    if (status >= 500) {
      throw ServerException('Error del servidor ($status).',
          statusCode: status);
    }
    if (status >= 400) {
      throw ServerException('Error del cliente ($status).', statusCode: status);
    }

  }

  /// Convierte [DioException] en excepciones de dominio más descriptivas.
  Never _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const NetworkException(
            'Tiempo de espera agotado. Verifica que el dispositivo esté encendido y en la misma red.');
      case DioExceptionType.connectionError:
        throw const NetworkException(
            'No se pudo conectar. Verifica la IP y que el dispositivo esté accesible.');
      case DioExceptionType.badResponse:
        _handleStatusCode(e.response?.statusCode, e.response?.data);
      default:
        throw NetworkException(e.message ?? 'Error de red desconocido.');
    }
    throw NetworkException(e.message ?? 'Error de red desconocido.');
  }
}
