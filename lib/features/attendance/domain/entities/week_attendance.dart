import 'package:equatable/equatable.dart';
import 'day_attendance.dart';

/// Razón por la que el empleado NO gana el bono de puntualidad.
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

/// Resumen completo de la semana laboral de UN empleado.
///
/// Contiene todos los [DayAttendance] y los resultados calculados:
/// bono de puntualidad y horas extra totales.
class WeekAttendance extends Equatable {
  final int userId;
  final String userName;

  /// Rango de la semana.
  final DateTime weekStart;
  final DateTime weekEnd;

  /// Asistencia día por día (solo días laborables).
  final List<DayAttendance> days;

  // ── Resultados ─────────────────────────────────────────────────────────────

  /// El empleado califica para el bono de puntualidad esta semana.
  final bool qualifiesForBonus;

  /// Razón por la que NO califica (si aplica).
  final BonusFailReason bonusFailReason;

  /// Total de minutos de horas extra en la semana.
  /// Solo se acumula en días [DayStatus.complete].
  final int totalOvertimeMinutes;

  const WeekAttendance({
    required this.userId,
    required this.userName,
    required this.weekStart,
    required this.weekEnd,
    required this.days,
    required this.qualifiesForBonus,
    required this.bonusFailReason,
    required this.totalOvertimeMinutes,
  });

  /// Días laborables esperados en la semana.
  int get expectedWorkDays =>
      days.where((d) => d.status != DayStatus.nonWorkday && d.status != DayStatus.future).length;

  /// Días con asistencia completa.
  int get completeDays =>
      days.where((d) => d.isComplete).length;

  /// Horas extra formateadas como "Xh Ym".
  String get overtimeFormatted {
    final h = totalOvertimeMinutes ~/ 60;
    final m = totalOvertimeMinutes % 60;
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
        qualifiesForBonus,
        bonusFailReason,
        totalOvertimeMinutes,
      ];
}
