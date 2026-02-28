import '../entities/access_log.dart';
import '../entities/day_attendance.dart';
import '../entities/week_attendance.dart';
import '../../../settings/domain/entities/work_schedule_config.dart';

/// **Motor de cálculo de asistencia.**
///
/// Esta clase contiene TODA la lógica de negocio:
/// - Deducir entrada/salida a partir de logs crudos
/// - Calcular puntualidad con tiempo de gracia
/// - Calcular horas extra (antes de entrada + después de salida)
/// - Evaluar si el empleado califica para el bono
///
/// Es una clase pura sin estado — todos los métodos son funciones.
/// Esto la hace 100% testeable sin mocks.
class AttendanceCalculator {
  const AttendanceCalculator();

  // ── API pública ────────────────────────────────────────────────────────────

  /// Calcula el resumen semanal de un empleado a partir de sus logs crudos.
  WeekAttendance calculateWeek({
    required int userId,
    required String userName,
    required DateTime weekStart,
    required DateTime weekEnd,
    required List<AccessLog> logs,
    required WorkScheduleConfig config,
  }) {
    // Filtramos logs que pertenecen a este usuario y a esta semana
    final userLogs = logs
        .where((l) =>
            l.userId == userId &&
            !l.timestamp.isBefore(weekStart) &&
            l.timestamp.isBefore(weekEnd.add(const Duration(days: 1))))
        .toList();

    final days = <DayAttendance>[];
    final now = DateTime.now();

    // Iteramos cada día de la semana configurada
    var current = weekStart;
    while (!current.isAfter(weekEnd)) {
      final weekday = current.weekday; // 1=lun … 7=dom

      if (!_isWorkday(weekday, config)) {
        days.add(DayAttendance(
          date: current,
          status: DayStatus.nonWorkday,
        ));
      } else if (current.isAfter(now)) {
        days.add(DayAttendance(
          date: current,
          status: DayStatus.future,
        ));
      } else {
        final dayLogs = _logsForDay(userLogs, current);
        days.add(_calculateDay(current, dayLogs, config));
      }

      current = current.add(const Duration(days: 1));
    }

    return _buildWeekResult(
      userId: userId,
      userName: userName,
      weekStart: weekStart,
      weekEnd: weekEnd,
      days: days,
      config: config,
    );
  }

  // ── Cálculo por día ────────────────────────────────────────────────────────

  DayAttendance _calculateDay(
    DateTime date,
    List<AccessLog> dayLogs,
    WorkScheduleConfig config,
  ) {
    if (dayLogs.isEmpty) {
      return DayAttendance(date: date, status: DayStatus.absent);
    }

    // Ordenamos cronológicamente
    dayLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Primer acceso = entrada, último = salida
    final entry = dayLogs.first.timestamp;
    final exit = dayLogs.length > 1 ? dayLogs.last.timestamp : null;

    if (exit == null || _isSameMinute(entry, exit)) {
      // Solo un registro: no podemos saber si es entrada o salida
      // Asumimos que es entrada y falta la salida
      return DayAttendance(
        date: date,
        status: DayStatus.missingExit,
        entryTime: entry,
      );
    }

    // ── Horario oficial del día ──────────────────────────────────────────────
    final scheduledStart = DateTime(
      date.year, date.month, date.day,
      config.workStartTime.inHours,
      config.workStartTime.inMinutes % 60,
    );
    final scheduledEnd = DateTime(
      date.year, date.month, date.day,
      config.workEndTime.inHours,
      config.workEndTime.inMinutes % 60,
    );
    final lateThreshold = scheduledStart.add(Duration(minutes: config.graceMinutes));
    final earlyLeaveThreshold = scheduledEnd.subtract(Duration(minutes: config.exitGraceMinutes));

    // ── Puntualidad ──────────────────────────────────────────────────────────
    final isPunctualEntry = !entry.isAfter(lateThreshold);
    final isPunctualExit  = !exit.isBefore(earlyLeaveThreshold);

    // ── Horas extra ──────────────────────────────────────────────────────────
    // Entrada anticipada: minutos antes del horario oficial (no del umbral de gracia)
    final earlyEntryMinutes = entry.isBefore(scheduledStart)
        ? scheduledStart.difference(entry).inMinutes
        : 0;

    // Salida tardía: minutos después del horario oficial de salida
    final lateExitMinutes = exit.isAfter(scheduledEnd)
        ? exit.difference(scheduledEnd).inMinutes
        : 0;

    // Las horas extra solo existen si el día es completo (entrada Y salida)
    final overtimeMinutes = earlyEntryMinutes + lateExitMinutes;

    return DayAttendance(
      date: date,
      status: DayStatus.complete,
      entryTime: entry,
      exitTime: exit,
      earlyEntryMinutes: earlyEntryMinutes,
      lateExitMinutes: lateExitMinutes,
      overtimeMinutes: overtimeMinutes,
      isPunctualEntry: isPunctualEntry,
      isPunctualExit: isPunctualExit,
    );
  }

  // ── Resumen semanal ────────────────────────────────────────────────────────

  WeekAttendance _buildWeekResult({
    required int userId,
    required String userName,
    required DateTime weekStart,
    required DateTime weekEnd,
    required List<DayAttendance> days,
    required WorkScheduleConfig config,
  }) {
    // Solo días laborables pasados (no futuros, no fin de semana)
    final workdays = days.where((d) =>
        d.status != DayStatus.nonWorkday && d.status != DayStatus.future);

    // ── Reglas del bono ──────────────────────────────────────────────────────
    // Regla 1: todos los días laborables pasados deben ser completos
    final hasIncompleteDays = workdays.any((d) => d.invalidatesBonus);

    // Regla 2: en todos los días completos debe haber sido puntual en entrada
    final hasLateEntry = workdays
        .where((d) => d.isComplete)
        .any((d) => !d.isPunctualEntry);

    // Regla 3: en todos los días completos debe haber sido puntual en salida
    final hasEarlyExit = workdays
        .where((d) => d.isComplete)
        .any((d) => !d.isPunctualExit);

    final failReasons = [
      if (hasIncompleteDays) BonusFailReason.incompleteDays,
      if (hasLateEntry) BonusFailReason.lateEntry,
      if (hasEarlyExit) BonusFailReason.earlyExit,
    ];

    final BonusFailReason failReason;
    if (failReasons.isEmpty) {
      failReason = BonusFailReason.none;
    } else if (failReasons.length == 1) {
      failReason = failReasons.first;
    } else {
      failReason = BonusFailReason.multiple;
    }

    final qualifies = config.bonusEnabled && failReason == BonusFailReason.none;

    // ── Horas extra ──────────────────────────────────────────────────────────
    // Solo se acumulan en días completos. Si un día está incompleto,
    // ese día no aporta horas extra (pero los otros días completos sí).
    final totalOvertime = days
        .where((d) => d.isComplete)
        .fold<int>(0, (sum, d) => sum + d.overtimeMinutes);

    return WeekAttendance(
      userId: userId,
      userName: userName,
      weekStart: weekStart,
      weekEnd: weekEnd,
      days: days,
      qualifiesForBonus: qualifies,
      bonusFailReason: failReason,
      totalOvertimeMinutes: totalOvertime,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool _isWorkday(int weekday, WorkScheduleConfig config) {
    // Caso normal: lun(1) a vie(5)
    if (config.weekStartDay <= config.weekEndDay) {
      return weekday >= config.weekStartDay && weekday <= config.weekEndDay;
    }
    // Caso que cruza fin de semana (ej: jue a lun)
    return weekday >= config.weekStartDay || weekday <= config.weekEndDay;
  }

  List<AccessLog> _logsForDay(List<AccessLog> logs, DateTime day) {
    return logs.where((l) {
      final t = l.timestamp;
      return t.year == day.year && t.month == day.month && t.day == day.day;
    }).toList();
  }

  bool _isSameMinute(DateTime a, DateTime b) =>
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day &&
      a.hour == b.hour &&
      a.minute == b.minute;
}
