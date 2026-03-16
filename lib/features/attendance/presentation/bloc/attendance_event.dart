part of 'attendance_bloc.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

/// Carga la semana actual al entrar a la pantalla.
class AttendanceLoadCurrentWeek extends AttendanceEvent {
  final bool useLocalLogs;
  const AttendanceLoadCurrentWeek({ this.useLocalLogs = false });
}

/// El usuario seleccionó una semana diferente en el picker.
class AttendanceWeekSelected extends AttendanceEvent {
  final DateTime weekStart;
  final DateTime weekEnd;
  final bool useLocalLogs;
  const AttendanceWeekSelected({
    required this.weekStart,
    required this.weekEnd,
    this.useLocalLogs = false,
  });

  @override
  List<Object?> get props => [weekStart, weekEnd, useLocalLogs];
}

/// El usuario presionó "Descargar accesos localmente".
class AttendanceSyncLocalRequested extends AttendanceEvent {
  const AttendanceSyncLocalRequested();
}

/// El usuario seleccionó un empleado específico para ver su detalle.
class AttendanceUserSelected extends AttendanceEvent {
  final int userId;

  const AttendanceUserSelected(this.userId);

  @override
  List<Object?> get props => [userId];
}
