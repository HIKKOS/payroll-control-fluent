import 'package:fpdart/fpdart.dart';
import 'package:nomina_control/features/attendance/domain/repositories/attendance_repository.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/access_log.dart';

import '../datasources/attendance_local_datasource.dart';
import '../datasources/attendance_remote_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDatasource _remote;
  final AttendanceLocalDatasource _local;

  const AttendanceRepositoryImpl({
    required AttendanceRemoteDatasource remote,
    required AttendanceLocalDatasource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<Either<Failure, List<AccessLog>>> getAccessLogs(
      GetAccessLogsParams params) async {
    try {
      final models = await _remote.getAccessLogs(
        userId: params.userId,
        from: params.from,
        to: params.to,
      );
      return Right(models);
    } on SessionExpiredException {
      return const Left(SessionExpiredFailure());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> syncLogsLocally(
      GetAccessLogsParams params) async {
    try {
      final models = await _remote.getAccessLogs(
        userId: params.userId,
        from: params.from,
        to: params.to,
      );
      await _local.insertLogs(models);
      return Right(models.length);
    } on SessionExpiredException {
      return const Left(SessionExpiredFailure());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AccessLog>>> getLocalLogs(
      GetAccessLogsParams params) async {
    try {
      final models = await _local.getLocalLogs(
        userId: params.userId,
        from: params.from,
        to: params.to,
      );
      return Right(models);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
