import '../entities/access_log.dart';
import '../entities/day_attendance.dart';
import '../entities/week_attendance.dart';
import '../../../settings/domain/entities/work_schedule_config.dart';

/// Motor de cálculo de asistencia — clase pura sin estado, 100% testeable.
///
/// Reglas de negocio implementadas:
///
/// Días L–V (laborables según config):
///   · Primer acceso = entrada, último = salida.
///   · Puntualidad: entrada ≤ horario + gracia / salida ≥ horario – gracia.
///   · Overtime: minutos antes del horario oficial + minutos después.
///   · Día incompleto (solo 1 acceso) → missingExit, no cuenta overtime.
///   · Sin accesos → absent.
///   · Cualquier día incompleto o ausente → pierde bono TODA la semana.
///   · Tardanza o salida anticipada → pierde bono.
///
/// Sábado y domingo:
///   · Si hay al menos 2 accesos: overtime = salida – entrada (tiempo total).
///   · Si hay solo 1 acceso: se ignora (no hay suficiente info).
///   · Si no hay accesos: no aparece en weekendDays.
///   · NO afectan el bono de puntualidad.
///   · NO tienen concepto de horario oficial, tardanza ni salida anticipada.
class AttendanceCalculator {
  const AttendanceCalculator();

  // ── API pública ────────────────────────────────────────────────────────────

  WeekAttendance calculateWeek({
    required int userId,
    required String userName,
    required DateTime weekStart,
    required DateTime weekEnd,
    required List<AccessLog> logs,
    required WorkScheduleConfig config,
  }) {
    // Logs del usuario en el rango completo (L–D)
    final userLogs = logs
        .where((l) =>
            l.userId == userId &&
            !l.timestamp.isBefore(weekStart) &&
            l.timestamp.isBefore(weekEnd.add(const Duration(days: 1))))
        .toList();

    final now = DateTime.now();

    // ── Días laborables L–V ──────────────────────────────────────────────────
    final workDays = <DayAttendance>[];
    // ── Fin de semana Sáb/Dom (con registros) ────────────────────────────────
    final weekendDays = <DayAttendance>[];

    DateTime current = weekStart;
    while (!current.isAfter(weekEnd)) {
      final wd = current.weekday; // 1=lun … 7=dom

      if (_isConfiguredWorkday(wd, config)) {
        // Día laborable según la configuración del cliente
        if (current.isAfter(now)) {
          workDays.add(DayAttendance(date: current, status: DayStatus.future));
        } else {
          workDays.add(
              _calcWorkday(current, _logsForDay(userLogs, current), config));
        }
      } else {
        // Fuera de la semana laboral configurada → puede ser sáb/dom
        // Solo lo procesamos si tiene registros
        final dayLogs = _logsForDay(userLogs, current);
        if (dayLogs.length >= 2 && !current.isAfter(now)) {
          // Hay suficiente info para calcular tiempo trabajado
          final day = _calcWeekendDay(current, dayLogs);
          weekendDays.add(day);
        }
        // Si no hay registros o solo hay 1 → lo omitimos completamente
      }

      current = current.add(const Duration(days: 1));
    }

    return _buildResult(
      userId: userId,
      userName: userName,
      weekStart: weekStart,
      weekEnd: weekEnd,
      workDays: workDays,
      weekendDays: weekendDays,
      config: config,
    );
  }

  // ── Cálculo día laborable (L–V) ───────────────────────────────────────────

  DayAttendance _calcWorkday(
    DateTime date,
    List<AccessLog> dayLogs,
    WorkScheduleConfig config,
  ) {
    if (dayLogs.isEmpty) {
      return DayAttendance(date: date, status: DayStatus.absent);
    }

    dayLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final entry = dayLogs.first.timestamp;
    final exit = dayLogs.length > 1 ? dayLogs.last.timestamp : null;

    if (exit == null || _isSameMinute(entry, exit)) {
      return DayAttendance(
        date: date,
        status: DayStatus.missingExit,
        entryTime: entry,
      );
    }

    final scheduledStart = _timeOnDay(date, config.workStartTime);
    final scheduledEnd = _timeOnDay(date, config.workEndTime);
    final lateThreshold =
        scheduledStart.add(Duration(minutes: config.graceMinutes));
    final earlyThreshold =
        scheduledEnd.subtract(Duration(minutes: config.exitGraceMinutes));

    final isPunctualEntry = !entry.isAfter(lateThreshold);
    final isPunctualExit = !exit.isBefore(earlyThreshold);

    final earlyEntryMinutes = entry.isBefore(scheduledStart)
        ? scheduledStart.difference(entry).inMinutes
        : 0;
    final lateExitMinutes = exit.isAfter(scheduledEnd)
        ? exit.difference(scheduledEnd).inMinutes
        : 0;

    return DayAttendance(
      date: date,
      status: DayStatus.complete,
      entryTime: entry,
      exitTime: exit,
      earlyEntryMinutes: earlyEntryMinutes,
      lateExitMinutes: lateExitMinutes,
      overtimeMinutes: earlyEntryMinutes + lateExitMinutes,
      isPunctualEntry: isPunctualEntry,
      isPunctualExit: isPunctualExit,
    );
  }

  // ── Cálculo día de fin de semana ──────────────────────────────────────────

  /// Para sáb/dom: no hay horario oficial.
  /// Overtime = tiempo total entre primer y último acceso.
  /// Sin puntualidad, sin penalización de bono.
  DayAttendance _calcWeekendDay(DateTime date, List<AccessLog> dayLogs) {
    dayLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final entry = dayLogs.first.timestamp;
    final exit = dayLogs.last.timestamp;

    // Tiempo total trabajado ese día en minutos
    final workedMinutes = exit.difference(entry).inMinutes;

    return DayAttendance(
      date: date,
      status: DayStatus.weekend,
      entryTime: entry,
      exitTime: exit,
      overtimeMinutes: workedMinutes,
      // isPunctualEntry / isPunctualExit quedan false (no aplica)
    );
  }

  // ── Resumen semanal ────────────────────────────────────────────────────────

  WeekAttendance _buildResult({
    required int userId,
    required String userName,
    required DateTime weekStart,
    required DateTime weekEnd,
    required List<DayAttendance> workDays,
    required List<DayAttendance> weekendDays,
    required WorkScheduleConfig config,
  }) {
    // Solo días L–V pasados para evaluar el bono
    final pastWorkdays = workDays.where((d) => d.status != DayStatus.future);

    final hasIncompleteDays = pastWorkdays.any((d) => d.invalidatesBonus);
    final hasLateEntry =
        pastWorkdays.where((d) => d.isComplete).any((d) => !d.isPunctualEntry);
    final hasEarlyExit =
        pastWorkdays.where((d) => d.isComplete).any((d) => !d.isPunctualExit);

    final failReasons = [
      if (hasIncompleteDays) BonusFailReason.incompleteDays,
      if (hasLateEntry) BonusFailReason.lateEntry,
      if (hasEarlyExit) BonusFailReason.earlyExit,
    ];

    final failReason = switch (failReasons.length) {
      0 => BonusFailReason.none,
      1 => failReasons.first,
      _ => BonusFailReason.multiple,
    };

    final qualifies = config.bonusEnabled && failReason == BonusFailReason.none;

    // Overtime L–V (solo días completos)
    final weekdayOvertime = workDays
        .where((d) => d.isComplete)
        .fold<int>(0, (s, d) => s + d.overtimeMinutes);

    // Overtime fin de semana (todo el tiempo trabajado)
    final weekendOvertime =
        weekendDays.fold<int>(0, (s, d) => s + d.overtimeMinutes);

    return WeekAttendance(
      userId: userId,
      userName: userName,
      weekStart: weekStart,
      weekEnd: weekEnd,
      days: workDays,
      weekendDays: weekendDays,
      qualifiesForBonus: qualifies,
      bonusFailReason: failReason,
      totalOvertimeMinutes: weekdayOvertime + weekendOvertime,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool _isConfiguredWorkday(int weekday, WorkScheduleConfig config) {
    if (config.weekStartDay <= config.weekEndDay) {
      return weekday >= config.weekStartDay && weekday <= config.weekEndDay;
    }
    return weekday >= config.weekStartDay || weekday <= config.weekEndDay;
  }

  DateTime _timeOnDay(DateTime day, Duration time) => DateTime.utc(
        day.year,
        day.month,
        day.day,
        time.inHours,
        time.inMinutes % 60,
      );

  List<AccessLog> _logsForDay(List<AccessLog> logs, DateTime day) =>
      logs.where((l) {
        final t = l.timestamp;
        return t.year == day.year && t.month == day.month && t.day == day.day;
      }).toList();

  bool _isSameMinute(DateTime a, DateTime b) =>
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day &&
      a.hour == b.hour &&
      a.minute == b.minute;
}
