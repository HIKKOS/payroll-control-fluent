import 'package:fpdart/fpdart.dart';
import 'package:nomina_control/features/attendance/domain/entities/access_log.dart';
import '../../../../core/error/failures.dart';
import '../../../settings/domain/entities/work_schedule_config.dart';
import '../entities/week_attendance.dart';
import '../repositories/attendance_repository.dart';
import '../../../device/domain/entities/device_user.dart';
import 'attendance_calculator.dart';

class GetWeekAttendanceParams {
  final List<DeviceUser> users;
  final DateTime weekStart;
  final DateTime weekEnd;
  final WorkScheduleConfig config;
  final bool useLocalLogs;

  const GetWeekAttendanceParams({
    required this.users,
    required this.weekStart,
    required this.weekEnd,
    required this.config,
    this.useLocalLogs = false,
  });
}

/// Caso de uso principal: obtiene la semana laboral de TODOS los usuarios.
///
/// Orquesta:
/// 1. Obtener logs del dispositivo (o local si [useLocalLogs])
/// 2. Aplicar [AttendanceCalculator] por cada usuario
/// 3. Devolver lista de [WeekAttendance]
class GetWeekAttendance {
  final AttendanceRepository _repository;
  final AttendanceCalculator _calculator;

  const GetWeekAttendance(this._repository, this._calculator);

  Future<Either<Failure, List<WeekAttendance>>> call(
      GetWeekAttendanceParams params) async {
    final results = <WeekAttendance>[];

    for (final user in params.users) {
      final logParams = GetAccessLogsParams(
        userId: user.id,
        from: params.weekStart,
        to: params.weekEnd,
      );

      final logsResult = params.useLocalLogs
          ? await _repository.getLocalLogs(logParams)
          : await _repository.getAccessLogs(logParams);

      // Si falla la obtención de logs de un usuario, lo saltamos con 0 registros
      // (el calculador lo marcará como ausente toda la semana)
      final logs = logsResult.fold((_) => <AccessLog>[], (l) => l);

      final week = _calculator.calculateWeek(
        userId: user.id,
        userName: user.name,
        weekStart: params.weekStart,
        weekEnd: params.weekEnd,
        logs: logs,
        config: params.config,
      );

      results.add(week);
    }

    return Right(results);
  }
}
