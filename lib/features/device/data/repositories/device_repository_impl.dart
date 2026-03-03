import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:nomina_control/core/database/app_database.dart';
import '../../../../core/database/access_logs_dao.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/device_credentials.dart';
import '../../domain/entities/device_user.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/control_id_datasource_impl.dart';
import '../datasources/device_remote_datasource.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DioClient _dioClient;
  final AccessLogsDao _dao;
  DeviceRemoteDatasource? _datasource;

  DeviceRepositoryImpl({
    required DioClient dioClient,
    required AccessLogsDao dao,
  })  : _dioClient = dioClient,
        _dao = dao;

  // ── Authenticate ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> authenticate(
      DeviceCredentials credentials) async {
    // Reconfigurar el cliente compartido con el nuevo host
    _dioClient.reconfigure(
      host: credentials.host,
      port: credentials.port,
      keepSession: false, // login fresco, limpiar cookie anterior
    );
    _datasource = ControlIdDatasourceImpl(_dioClient);

    try {
      await _datasource!.login(
        login: credentials.login,
        password: credentials.password,
      );
      return right(true);
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  // ── Get Users (online) ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<DeviceUser>>> getUsers() async {
    if (_datasource == null) {
      return left(const SessionExpiredFailure('No hay conexión activa.'));
    }
    try {
      final models = await _datasource!.getUsers();

      // Guardar snapshot para modo offline
      await _dao.upsertCachedUsers(
        models
            .map((u) => CachedUsersCompanion.insert(
                  id: Value(u.id),
                  name: u.name,
                  registration: u.registration,
                  savedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                ))
            .toList(),
      );

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

  // ── Get Users (offline) ───────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<DeviceUser>>> getCachedUsers() async {
    try {
      final rows = await _dao.getAllCachedUsers();
      return right(rows
          .map((r) => DeviceUser(
                id: r.id,
                name: r.name,
                registration: r.registration,
              ))
          .toList());
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await _datasource?.logout();
    } catch (_) {}
    _datasource = null;
    _dioClient.clearSession();
    return right(true);
  }

  /// Expone el cliente para que AttendanceDatasource comparta la sesión.
  DioClient get dioClient => _dioClient;

  @override
  Future<Either<Failure, Unit>> restoreDeviceSession(
      DeviceCredentials credentials) async {
    // Reconfigurar el cliente compartido con el nuevo host
    _dioClient.reconfigure(
      host: credentials.host,
      port: credentials.port,
      keepSession: true
    );
    _datasource = ControlIdDatasourceImpl(_dioClient);
  return right(unit);
  }
}
