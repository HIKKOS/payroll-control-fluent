import 'package:equatable/equatable.dart';

enum DayStatus {
  /// Día laborable completo: entrada y salida registradas.
  complete,

  /// Solo entrada registrada — falta salida.
  missingExit,

  /// Solo salida registrada — falta entrada.
  missingEntry,

  /// Sin ningún registro — ausente.
  absent,

  /// Sábado o domingo con registros: todo el tiempo cuenta como extra.
  /// No tiene concepto de puntualidad ni invalida el bono.
  weekend,

  /// Sábado o domingo sin registros — no se muestra en UI de semana laboral.
  nonWorkday,

  /// Día futuro — aún no ha ocurrido.
  future,
}

/// Resumen de la asistencia de UN empleado en UN día.
class DayAttendance extends Equatable {
  final DateTime date;
  final DayStatus status;

  /// Hora real de entrada (primer acceso del día).
  final DateTime? entryTime;

  /// Hora real de salida (último acceso del día).
  final DateTime? exitTime;

  /// Minutos trabajados antes del horario oficial de entrada.
  /// Solo aplica a días laborables (L–V).
  final int earlyEntryMinutes;

  /// Minutos trabajados después del horario oficial de salida.
  /// Solo aplica a días laborables (L–V).
  final int lateExitMinutes;

  /// Minutos totales de horas extra en este día.
  ///
  /// Para días L–V completos: earlyEntryMinutes + lateExitMinutes.
  /// Para días de fin de semana con registros: duración total (salida – entrada).
  final int overtimeMinutes;

  /// true si llegó antes o dentro del tiempo de gracia de entrada.
  /// Siempre false para días de fin de semana (no aplica).
  final bool isPunctualEntry;

  /// true si salió después o dentro del tiempo de gracia de salida.
  /// Siempre false para días de fin de semana (no aplica).
  final bool isPunctualExit;

  const DayAttendance({
    required this.date,
    required this.status,
    this.entryTime,
    this.exitTime,
    this.earlyEntryMinutes = 0,
    this.lateExitMinutes = 0,
    this.overtimeMinutes = 0,
    this.isPunctualEntry = false,
    this.isPunctualExit = false,
  });

  bool get isComplete => status == DayStatus.complete;

  bool get isWeekend => status == DayStatus.weekend;

  /// El día invalida el bono (solo aplica a días L–V).
  /// Los días de fin de semana nunca invalidan el bono.
  bool get invalidatesBonus =>
      status == DayStatus.absent ||
      status == DayStatus.missingEntry ||
      status == DayStatus.missingExit;

  @override
  List<Object?> get props => [
        date,
        status,
        entryTime,
        exitTime,
        earlyEntryMinutes,
        lateExitMinutes,
        overtimeMinutes,
        isPunctualEntry,
        isPunctualExit,
      ];
}
