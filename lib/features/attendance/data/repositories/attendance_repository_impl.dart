import 'package:fpdart/fpdart.dart';
import '../../../../core/database/access_logs_dao.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/access_log.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_local_datasource.dart';
import '../datasources/attendance_remote_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDatasource _remote;
  final AttendanceLocalDatasource  _local;

  const AttendanceRepositoryImpl({
    required AttendanceRemoteDatasource remote,
    required AttendanceLocalDatasource  local,
  })  : _remote = remote,
        _local  = local;

  @override
  Future<Either<Failure, List<AccessLog>>> getAccessLogs(
      GetAccessLogsParams params) async {
    try {
      final models = await _remote.getAccessLogs(
        userId: params.userId,
        from:   params.from,
        to:     params.to,
      );
      return right(models);
    } on SessionExpiredException {
      return  left(const SessionExpiredFailure());
    } on NetworkException catch (e) {
      return left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> syncLogsLocally(
      GetAccessLogsParams params) async {
    try {
      final models = await _remote.getAccessLogs(
        userId: params.userId,
        from:   params.from,
        to:     params.to,
      );

      final weekKey = AccessLogsDao.buildWeekKey(params.from);
      await _local.insertLogs(models, weekKey: weekKey);
      return right(models.length);
    } on SessionExpiredException {
      return    left(const SessionExpiredFailure());
    } on NetworkException catch (e) {
      return left(NetworkFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AccessLog>>> getLocalLogs(
      GetAccessLogsParams params) async {
    try {
      final models = await _local.getLocalLogs(
        userId: params.userId,
        from:   params.from,
        to:     params.to,
      );
      return right(models);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }
}
