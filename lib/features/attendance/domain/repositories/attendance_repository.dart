import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/access_log.dart';

/// Params para solicitar logs de acceso.
class GetAccessLogsParams {
  final int userId;
  final DateTime from;
  final DateTime to;

  const GetAccessLogsParams({
    required this.userId,
    required this.from,
    required this.to,
  });
}

abstract class AttendanceRepository {
  /// Obtiene los logs de acceso del dispositivo para un usuario y rango de fechas.
  Future<Either<Failure, List<AccessLog>>> getAccessLogs(GetAccessLogsParams params);

  /// Descarga y persiste localmente los logs de acceso (modo offline).
  Future<Either<Failure, int>> syncLogsLocally(GetAccessLogsParams params);

  /// Obtiene logs desde la base de datos local (modo offline).
  Future<Either<Failure, List<AccessLog>>> getLocalLogs(GetAccessLogsParams params);
}