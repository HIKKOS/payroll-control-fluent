import 'package:equatable/equatable.dart';
import 'day_attendance.dart';

enum BonusFailReason {
  /// Tiene todos los días completos y fue puntual — SÍ gana bono.
  none,

  /// Faltó al menos un día o tiene un registro incompleto.
  incompleteDays,

  /// Llegó tarde al menos un día (fuera del tiempo de gracia).
  lateEntry,

  /// Salió temprano al menos un día (antes del tiempo de gracia inverso).
  earlyExit,

  /// Múltiples razones.
  multiple,
}

/// Resumen completo de la semana de UN empleado.
///
/// [days] contiene SOLO los días L–V (laborables según config).
/// [weekendDays] contiene los sábados/domingos que tuvieron registros.
/// Los fines de semana sin registros no aparecen en ninguna lista.
class WeekAttendance extends Equatable {
  final int userId;
  final String userName;
  final DateTime weekStart;
  final DateTime weekEnd;

  /// Días L–V (laborables). Incluye: complete, absent, missingEntry,
  /// missingExit, future. NO incluye nonWorkday ni weekend.
  final List<DayAttendance> days;

  /// Sábados y domingos con al menos un registro.
  /// Estado siempre [DayStatus.weekend]. Vacío si nadie fue el fin de semana.
  final List<DayAttendance> weekendDays;

  final bool qualifiesForBonus;
  final BonusFailReason bonusFailReason;

  /// Total de minutos extra en la semana COMPLETA:
  /// overtime L–V + tiempo total trabajado sáb/dom.
  final int totalOvertimeMinutes;

  const WeekAttendance({
    required this.userId,
    required this.userName,
    required this.weekStart,
    required this.weekEnd,
    required this.days,
    required this.weekendDays,
    required this.qualifiesForBonus,
    required this.bonusFailReason,
    required this.totalOvertimeMinutes,
  });

  // ── Computed helpers ───────────────────────────────────────────────────────
  /// Todos los días con al menos un registro, ordenados cronológicamente.
  /// Incluye L–V con asistencia (cualquier estado excepto absent/future/nonWorkday)
  /// más los días de fin de semana con registros.
  /// Usado por la vista "Por horas" — no filtra por completitud ni puntualidad.
  List<DayAttendance> get allAttendedDays {
    final workdaysWithRecords = days.where((d) =>
    d.status != DayStatus.absent &&
        d.status != DayStatus.future &&
        d.status != DayStatus.nonWorkday &&
        d.entryTime != null);
    return [...workdaysWithRecords, ...weekendDays]
      ..sort((a, b) => a.date.compareTo(b.date));
  }
  /// Días laborables esperados en la semana (excluye futuros).
  int get expectedWorkDays =>
      days.where((d) => d.status != DayStatus.future).length;

  /// Días con asistencia completa (solo L–V).
  int get completeDays => days.where((d) => d.isComplete).length;

  /// Total de minutos extra solo en fin de semana.
  int get weekendOvertimeMinutes =>
      weekendDays.fold(0, (s, d) => s + d.overtimeMinutes);

  /// Total de minutos extra solo en días L–V.
  int get weekdayOvertimeMinutes =>
      totalOvertimeMinutes - weekendOvertimeMinutes;

  bool get wasAbsent => expectedWorkDays > 0 && completeDays == 0;

  /// Horas extra totales formateadas.
  String get overtimeFormatted => fmtMinutes(totalOvertimeMinutes);

  /// Horas extra de fin de semana formateadas.
  String get weekendOvertimeFormatted => fmtMinutes(weekendOvertimeMinutes);

  static String fmtMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  List<Object?> get props => [
        userId,
        weekStart,
        weekEnd,
        days,
        weekendDays,
        qualifiesForBonus,
        bonusFailReason,
        totalOvertimeMinutes,
      ];
}
