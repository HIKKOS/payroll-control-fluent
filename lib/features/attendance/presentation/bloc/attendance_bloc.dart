import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../device/domain/entities/device_user.dart';
import '../../../settings/domain/entities/work_schedule_config.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../domain/entities/week_attendance.dart';
import '../../domain/usecases/get_week_attendance.dart';
import '../../domain/usecases/sync_logs_locally.dart';
import '../../domain/usecases/week_range_helper.dart';
import '../../../../core/error/failures.dart';

part 'attendance_event.dart';

part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GetWeekAttendance _getWeekAttendance;
  final SyncLogsLocally _syncLogsLocally;
  final SettingsRepository _settingsRepository;
  final bool _hideAbsences;

  /// Usuarios cargados previamente desde el BLoC de dispositivo.
  final List<DeviceUser> users;

  // Estado interno de la semana seleccionada
  DateTime? _currentWeekStart;
  DateTime? _currentWeekEnd;
  WorkScheduleConfig? _config;

  AttendanceBloc({
    required GetWeekAttendance getWeekAttendance,
    required SyncLogsLocally syncLogsLocally,
    required SettingsRepository settingsRepository,
    required this.users,
    bool hideAbsences = true,
  })  : _getWeekAttendance = getWeekAttendance,
        _syncLogsLocally = syncLogsLocally,
        _hideAbsences = hideAbsences,
        _settingsRepository = settingsRepository,
        super(const AttendanceInitial()) {
    on<AttendanceLoadCurrentWeek>(_onLoadCurrentWeek);
    on<AttendanceWeekSelected>(_onWeekSelected);
    on<AttendanceSyncLocalRequested>(_onSyncLocal);
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onLoadCurrentWeek(
    AttendanceLoadCurrentWeek event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading());

    final configResult = await _settingsRepository.getConfig();
    final config =
        configResult.fold((_) => const WorkScheduleConfig(), (c) => c);
    _config = config;

    _currentWeekStart = WeekRangeHelper.currentWeekStart(config);
    _currentWeekEnd = WeekRangeHelper.currentWeekEnd(config);

    await _loadWeek(emit,  useLocalLogs: false, isCurrentWeek: true);
  }

  Future<void> _onWeekSelected(
    AttendanceWeekSelected event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading());
    _currentWeekStart = event.weekStart;
    _currentWeekEnd = event.weekEnd;

    final now = DateTime.now();
    final isCurrentWeek =
        !event.weekStart.isAfter(now) && !event.weekEnd.isBefore(now);

    await _loadWeek(emit,  useLocalLogs: true, isCurrentWeek: isCurrentWeek);
  }

  Future<void> _onSyncLocal(
    AttendanceSyncLocalRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    if (_currentWeekStart == null || _currentWeekEnd == null) return;

    emit(const AttendanceSyncing());

    final result = await _syncLogsLocally(SyncLogsLocallyParams(
      userIds: users.map((u) => u.id).toList(),
      from: _currentWeekStart!,
      to: _currentWeekEnd!,
    ));

    result.fold(
      (failure) => emit(AttendanceError(message: failure.message)),
      (count) {
        emit(AttendanceSyncSuccess(count));
        // Recargamos desde local
        add(AttendanceWeekSelected(
          weekStart: _currentWeekStart!,
          weekEnd: _currentWeekEnd!,
        ));
      },
    );
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  Future<void> _loadWeek(
    Emitter<AttendanceState> emit, {
    required bool useLocalLogs,
    required bool isCurrentWeek,

  }) async {
    final config = _config ?? const WorkScheduleConfig();

    final result = await _getWeekAttendance(GetWeekAttendanceParams(
      users: users,
      weekStart: _currentWeekStart!,
      weekEnd: _currentWeekEnd!,
      config: config,
      useLocalLogs: useLocalLogs,
    ));

    result.fold(
      (failure) => emit(AttendanceError(
        message: failure.message,
        requiresReconnect: failure is SessionExpiredFailure,
      )),
      (data) => emit(AttendanceLoaded(
        hideAbsences:  _hideAbsences,
        weekData: data.where((w){
          if(!_hideAbsences){
            return true;
          }

          return !w.wasAbsent;
        }).toList(),
        weekStart: _currentWeekStart!,
        weekEnd: _currentWeekEnd!,
        config: config,
        isCurrentWeek: isCurrentWeek,
        isLocalData: useLocalLogs,
      )),
    );
  }
}
