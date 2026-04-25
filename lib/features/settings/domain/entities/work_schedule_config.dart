import 'package:equatable/equatable.dart';

/// Configuración de la semana laboral y reglas de nómina.
///
/// Esta entidad centraliza TODAS las reglas de negocio configurables:
/// horarios, tiempo de gracia, y los parámetros del bono de puntualidad.
///
/// Se almacena localmente en Drift y el usuario la edita desde Settings.
/// Al ser una entidad de dominio pura, no sabe nada de JSON ni de base de datos.
class WorkScheduleConfig extends Equatable {
  // ── Semana laboral ─────────────────────────────────────────────────────────

  /// Día de inicio de semana laboral (1=lunes … 7=domingo).
  final int weekStartDay;

  /// Día de fin de semana laboral (1=lunes … 7=domingo).
  final int weekEndDay;

  // ── Horario diario ─────────────────────────────────────────────────────────

  /// Hora oficial de entrada (ej: 08:00).
  final Duration workStartTime;

  /// Hora oficial de salida (ej: 17:00).
  final Duration workEndTime;

  /// Duración del tiempo de comida que se descuenta automáticamente.
  /// Ej: 1 hora = Duration(hours: 1).
  final Duration lunchDuration;

  // ── Tiempo de gracia ───────────────────────────────────────────────────────

  /// Minutos de gracia para la entrada.
  /// El empleado puede llegar hasta [workStartTime + graceMinutes] y
  /// todavía califica como puntual.
  final int graceMinutes;

  /// Minutos de gracia para la salida.
  /// El empleado debe salir después de [workEndTime - graceMinutes]
  /// para que el día cuente como salida completa.
  final int exitGraceMinutes;

  // ── Reglas del bono ────────────────────────────────────────────────────────

  /// Si true, el bono aplica en la semana actual.
  /// (Flag de feature — permite desactivar el bono sin tocar lógica.)
  final bool bonusEnabled;

  const WorkScheduleConfig({
    this.weekStartDay = DateTime.monday,
    this.weekEndDay = DateTime.friday,
    this.workStartTime = const Duration(hours: 7,minutes: 30),
    this.workEndTime = const Duration(hours: 17),
    this.lunchDuration = const Duration(minutes: 30),
    this.graceMinutes = 5,
    this.exitGraceMinutes = 5,
    this.bonusEnabled = true,
  });

  // ── Computed helpers ───────────────────────────────────────────────────────

  /// Horas netas esperadas por día (descontando comida).
  Duration get netDailyHours => workEndTime - workStartTime;

  /// Límite máximo de entrada para ser puntual.
  Duration get lateThreshold => workStartTime + Duration(minutes: graceMinutes);

  /// Límite mínimo de salida para que el día sea válido.
  Duration get earlyLeaveThreshold => workEndTime - Duration(minutes: exitGraceMinutes);

  // ── copyWith ───────────────────────────────────────────────────────────────

  WorkScheduleConfig copyWith({
    int? weekStartDay,
    int? weekEndDay,
    Duration? workStartTime,
    Duration? workEndTime,
    Duration? lunchDuration,
    int? graceMinutes,
    int? exitGraceMinutes,
    bool? bonusEnabled,
  }) {
    return WorkScheduleConfig(
      weekStartDay: weekStartDay ?? this.weekStartDay,
      weekEndDay: weekEndDay ?? this.weekEndDay,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      lunchDuration: lunchDuration ?? this.lunchDuration,
      graceMinutes: graceMinutes ?? this.graceMinutes,
      exitGraceMinutes: exitGraceMinutes ?? this.exitGraceMinutes,
      bonusEnabled: bonusEnabled ?? this.bonusEnabled,
    );
  }

  @override
  List<Object?> get props => [
        weekStartDay,
        weekEndDay,
        workStartTime,
        workEndTime,
        lunchDuration,
        graceMinutes,
        exitGraceMinutes,
        bonusEnabled,
      ];
}
