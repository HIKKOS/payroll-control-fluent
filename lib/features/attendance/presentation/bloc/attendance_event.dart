part of 'attendance_bloc.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

/// Carga la semana actual al entrar a la pantalla.
class AttendanceLoadCurrentWeek extends AttendanceEvent {
  const AttendanceLoadCurrentWeek();
}

/// El usuario seleccionó una semana diferente en el picker.
class AttendanceWeekSelected extends AttendanceEvent {
  final DateTime weekStart;
  final DateTime weekEnd;

  const AttendanceWeekSelected({
    required this.weekStart,
    required this.weekEnd,
  });

  @override
  List<Object?> get props => [weekStart, weekEnd];
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
