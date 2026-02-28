import 'package:equatable/equatable.dart';

/// Estado de un día laboral para un empleado.
enum DayStatus {
  /// Día completo: tiene entrada y salida válidas.
  complete,

  /// Solo tiene entrada (falta salida) — día inválido.
  missingExit,

  /// Solo tiene salida (falta entrada) — día inválido.
  missingEntry,

  /// No hay ningún registro — ausente.
  absent,

  /// Día no laborable (fin de semana según config).
  nonWorkday,

  /// Día futuro — aún no ha ocurrido.
  future,
}

/// Resumen procesado de la asistencia de UN empleado en UN día.
///
/// Este objeto es el resultado de aplicar las reglas de negocio
/// a los [AccessLog] crudos del dispositivo.
class DayAttendance extends Equatable {
  final DateTime date;
  final DayStatus status;

  /// Hora real de entrada (primer acceso del día).
  final DateTime? entryTime;

  /// Hora real de salida (último acceso del día).
  final DateTime? exitTime;

  /// Minutos de llegada anticipada antes del horario oficial.
  /// Positivo = llegó antes. 0 = llegó después o dentro del tiempo de gracia.
  final int earlyEntryMinutes;

  /// Minutos de permanencia extra después del horario oficial de salida.
  /// Positivo = salió después. 0 = salió antes o dentro del tiempo de gracia.
  final int lateExitMinutes;

  /// Minutos totales de horas extra acumuladas en este día.
  /// = earlyEntryMinutes + lateExitMinutes (solo si el día es [complete]).
  final int overtimeMinutes;

  /// true si el empleado fue puntual en entrada (llegó antes o dentro de la gracia).
  final bool isPunctualEntry;

  /// true si el empleado fue puntual en salida (salió después o dentro de la gracia inversa).
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

  /// El día tiene entrada Y salida registradas.
  bool get isComplete => status == DayStatus.complete;

  /// El día invalida el bono (ausente o registro incompleto).
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
