

import 'package:nomina_control/features/settings/domain/entities/work_schedule_config.dart';

/// Utilidad para calcular rangos de semana laboral.
class WeekRangeHelper {
  const WeekRangeHelper._();

  /// Retorna el inicio de la semana laboral actual según [config].
  static DateTime currentWeekStart(WorkScheduleConfig config) {
    final now = DateTime.now();
    return _weekStartFor(now, config.weekStartDay);
  }

  /// Retorna el fin de la semana laboral actual.
  /// Si hoy no ha terminado la semana, el fin es hoy (no el fin oficial de semana).
  static DateTime currentWeekEnd(WorkScheduleConfig config) {
    final now = DateTime.now();
    final officialEnd = _weekEndFor(now, config.weekStartDay, config.weekEndDay);
    // Si la semana no ha terminado, el rango llega hasta hoy
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return officialEnd.isBefore(today) ? officialEnd : today;
  }

  /// Retorna el inicio de la semana anterior.
  static DateTime previousWeekStart(DateTime currentStart, WorkScheduleConfig config) {
    return currentStart.subtract(const Duration(days: 7));
  }

  /// Retorna el fin de la semana anterior (siempre completa).
  static DateTime previousWeekEnd(DateTime currentStart, WorkScheduleConfig config) {
    final prevStart = previousWeekStart(currentStart, config);
    final workdaysInWeek = _workdaysCount(config);
    return prevStart.add(Duration(days: workdaysInWeek - 1));
  }

  /// Construye el inicio de semana laboral para una fecha dada.
  static DateTime _weekStartFor(DateTime date, int weekStartDay) {
    var d = DateTime(date.year, date.month, date.day);
    while (d.weekday != weekStartDay) {
      d = d.subtract(const Duration(days: 1));
    }
    return d;
  }

  /// Construye el fin de semana laboral para una fecha dada.
  static DateTime _weekEndFor(DateTime date, int weekStartDay, int weekEndDay) {
    final start = _weekStartFor(date, weekStartDay);
    final workdays = _workdaysBetween(weekStartDay, weekEndDay);
    return DateTime(
      start.year, start.month, start.day + workdays - 1, 23, 59, 59,
    );
  }

  static int _workdaysCount(WorkScheduleConfig config) {
    return _workdaysBetween(config.weekStartDay, config.weekEndDay);
  }

  static int _workdaysBetween(int start, int end) {
    if (end >= start) return end - start + 1;
    return 7 - start + end + 1; // cruza fin de semana
  }

  /// Genera una lista de semanas hacia atrás desde la semana actual.
  static List<({DateTime start, DateTime end})> recentWeeks(
    WorkScheduleConfig config, {
    int count = 8,
  }) {
    final weeks = <({DateTime start, DateTime end})>[];
    var start = _weekStartFor(DateTime.now(), config.weekStartDay);

    for (int i = 0; i < count; i++) {
      final end = _weekEndFor(start, config.weekStartDay, config.weekEndDay);
      weeks.add((start: start, end: end));
      start = start.subtract(const Duration(days: 7));
    }
    return weeks;
  }
}
