
import 'package:fpdart/fpdart.dart';
import 'package:nomina_control/features/device/data/datasources/control_id_datasource_impl.dart';
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
  DioClient? _dioClient;

  // ── Authenticate ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> authenticate(DeviceCredentials credentials) async {
    // Cada vez que el usuario intenta conectarse a un dispositivo,
    // recreamos el cliente con la nueva baseUrl.
    _dioClient = DioClient(baseUrl: credentials.baseUrl);
    _datasource = ControlIdDatasourceImpl(_dioClient!);

    try {
      await _datasource!.login(
        login: credentials.login,
        password: credentials.password,
      );
      return const Right(true);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  // ── Get Users ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<DeviceUser>>> getUsers() async {
    if (_datasource == null) {
      return const Left(SessionExpiredFailure(
        'No hay conexión activa. Inicia sesión primero.',
      ));
    }

    try {
      final models = await _datasource!.getUsers();
      return Right(models);
    } on SessionExpiredException {
      return const Left(SessionExpiredFailure());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ParseException catch (e) {
      return Left(ParseFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await _datasource?.logout();
      _datasource = null;
      _dioClient = null;
      return const Right(true);
    } catch (e) {
      // El logout siempre limpia el estado local aunque falle en el servidor
      _datasource = null;
      _dioClient = null;
      return const Right(true);
    }
  }
}