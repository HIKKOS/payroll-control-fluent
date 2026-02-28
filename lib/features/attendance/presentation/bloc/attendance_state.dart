part of 'attendance_bloc.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();
}

class AttendanceLoaded extends AttendanceState {
  final List<WeekAttendance> weekData;
  final DateTime weekStart;
  final DateTime weekEnd;
  final WorkScheduleConfig config;
  final bool isCurrentWeek;
  final bool isLocalData;

  const AttendanceLoaded({
    required this.weekData,
    required this.weekStart,
    required this.weekEnd,
    required this.config,
    required this.isCurrentWeek,
    this.isLocalData = false,
  });

  @override
  List<Object?> get props => [weekData, weekStart, weekEnd, isCurrentWeek, isLocalData];
}

class AttendanceSyncing extends AttendanceState {
  final String message;
  const AttendanceSyncing({this.message = 'Descargando accesos…'});

  @override
  List<Object?> get props => [message];
}

class AttendanceSyncSuccess extends AttendanceState {
  final int totalRecords;
  const AttendanceSyncSuccess(this.totalRecords);

  @override
  List<Object?> get props => [totalRecords];
}

class AttendanceError extends AttendanceState {
  final String message;
  final bool requiresReconnect;

  const AttendanceError({
    required this.message,
    this.requiresReconnect = false,
  });

  @override
  List<Object?> get props => [message, requiresReconnect];
}
