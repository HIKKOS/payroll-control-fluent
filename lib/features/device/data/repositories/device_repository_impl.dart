import 'package:fpdart/fpdart.dart';
import 'package:nomina_control/features/device/data/datasources/control_id_datasource_impl.dart';
import 'package:nomina_control/features/device/data/datasources/device_local_datasource.dart';
import 'package:nomina_control/features/device/data/datasources/device_remote_datasource.dart';
import 'package:nomina_control/features/device/domain/entities/device_credentials.dart';
import 'package:nomina_control/features/device/domain/entities/device_user.dart';
import 'package:nomina_control/features/device/domain/repositories/device_repository.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';

/// Implementación concreta del repositorio de dispositivo.
///
/// Su responsabilidad es:
/// 1. Crear/reemplazar el [DioClient] cuando cambian las credenciales.
/// 2. Delegar las operaciones al datasource.
/// 3. Capturar excepciones de la capa de datos y convertirlas en [Failure].
///
/// La UI y los casos de uso nunca ven excepciones; solo ven [Either].
class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRemoteDatasource? _datasource;
  final DeviceLocalDatasource _localDatasource;
  DioClient? _dioClient;

  DioClient? get dioClient => _dioClient;

  DeviceRepositoryImpl({
    required DeviceLocalDatasource localDatasource,
  }) : _localDatasource = localDatasource;

  // ── Authenticate ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> authenticate(
    DeviceCredentials credentials, {
    bool saveCredentials = true,
  }) async {
    // Cada vez que el usuario intenta conectarse a un dispositivo,
    // recreamos el cliente con la nueva baseUrl.
    _dioClient = DioClient(baseUrl: credentials.baseUrl);
    _datasource = ControlIdDatasourceImpl(_dioClient!);

    try {
      await _datasource!.login(
        login: credentials.login,
        password: credentials.password,
      );
      if (saveCredentials) {
        await _localDatasource.saveCredentials(credentials);
      }
      return right(true);
    } on AuthException catch (e) {
      await _localDatasource.deleteCredentials();
      return left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  // ── Get Users ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<DeviceUser>>> getUsers() async {
    if (_datasource == null) {
      return left(const SessionExpiredFailure(
        'No hay conexión activa. Inicia sesión primero.',
      ));
    }

    try {
      final models = await _datasource!.getUsers();
      return right(models);
    } on SessionExpiredException {
      return left(const SessionExpiredFailure());
    } on NetworkException catch (e) {
      return left(NetworkFailure(e.message));
    } on ParseException catch (e) {
      return left(ParseFailure(e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final futures = <Future<void>>[   _localDatasource.deleteCredentials()];
      if (_datasource != null) {
        futures.add(_datasource!.logout());
      }
      await Future.wait(futures);

      _datasource = null;
      _dioClient = null;
      return right(true);
    } catch (e) {
      // El logout siempre limpia el estado local aunque falle en el servidor
      _datasource = null;
      _dioClient = null;
      return right(true);
    }
  }

  @override
  Future<Either<Failure, bool>> authenticateOnStart() async {
    final credentials = await _localDatasource.loadCredentials();
    if (credentials == null) {

      return left(
          const SessionExpiredFailure('No hay credenciales guardadas.'));
    }
    return authenticate(credentials, saveCredentials: false);
  }
}
