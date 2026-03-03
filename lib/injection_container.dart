import 'package:get_it/get_it.dart';
import 'package:nomina_control/core/theme/cubit/theme_cubit.dart';
import 'package:nomina_control/features/device/domain/usecases/restore_device_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/database/access_logs_dao.dart';
import 'core/database/app_database.dart';
import 'core/network/dio_client.dart';
import 'features/attendance/data/datasources/attendance_local_datasource.dart';
import 'features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'features/attendance/data/repositories/attendance_repository_impl.dart';
import 'features/attendance/domain/repositories/attendance_repository.dart';
import 'features/attendance/domain/usecases/attendance_calculator.dart';
import 'features/attendance/domain/usecases/get_week_attendance.dart';
import 'features/attendance/domain/usecases/sync_logs_locally.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/device/data/repositories/device_repository_impl.dart';
import 'features/device/domain/entities/device_user.dart';
import 'features/device/domain/repositories/device_repository.dart';
import 'features/device/domain/usecases/authenticate_device.dart';
import 'features/device/domain/usecases/get_device_users.dart';
import 'features/device/domain/usecases/logout_device.dart';
import 'features/device/presentation/bloc/device_bloc.dart';
import 'features/session/data/datasources/session_local_datasource.dart';
import 'features/session/data/repositories/session_repository_impl.dart';
import 'features/session/domain/repositories/session_repository.dart';
import 'features/session/domain/usecases/app_startup_usecase.dart';
import 'features/session/presentation/bloc/startup_bloc.dart';
import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/repositories/settings_repository.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // ── Externos ─────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(prefs);
  // ThemeCubit — singleton global, vive por encima de FluentApp.
  serviceLocator.registerSingleton<ThemeCubit>(ThemeCubit(prefs));
  // ── Base de datos ─────────────────────────────────────────────────────────
  serviceLocator.registerSingleton<AppDatabase>(AppDatabase());
  serviceLocator.registerLazySingleton<AccessLogsDao>(
      () => AccessLogsDao(serviceLocator()));

  // ── DioClient singleton compartido ────────────────────────────────────────
  // Session y Device usan el mismo cliente → misma cookie de sesión.
  serviceLocator.registerSingleton<DioClient>(DioClient());

  // ── Session ───────────────────────────────────────────────────────────────
  serviceLocator.registerLazySingleton<SessionLocalDatasource>(
      () => SessionLocalDatasourceImpl(serviceLocator()));
  serviceLocator
      .registerLazySingleton<SessionRepository>(() => SessionRepositoryImpl(
            local: serviceLocator(),
            dioClient: serviceLocator(),
          ));

  serviceLocator
      .registerLazySingleton(() => AppStartupUseCase(serviceLocator()));
  serviceLocator
      .registerLazySingleton(() => RestoreDeviceSession(serviceLocator()));
  serviceLocator.registerFactory(() => StartupBloc(
      restoreSession: serviceLocator(), appStartup: serviceLocator()));

  // ── Settings ──────────────────────────────────────────────────────────────
  serviceLocator.registerLazySingleton<SettingsLocalDatasource>(
      () => SettingsLocalDatasourceImpl(serviceLocator()));
  serviceLocator.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(serviceLocator()));

  // ── Device ────────────────────────────────────────────────────────────────
  // El repositorio recibe el DioClient singleton y el DAO para caché.
  serviceLocator.registerSingleton<DeviceRepository>(
    DeviceRepositoryImpl(
      dioClient: serviceLocator(),
      dao: serviceLocator(),
    ),
  );
  serviceLocator
      .registerLazySingleton(() => AuthenticateDevice(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetDeviceUsers(serviceLocator()));
  serviceLocator.registerLazySingleton(() => LogoutDevice(serviceLocator()));
  serviceLocator.registerFactory(() => DeviceBloc(
        authenticateDevice: serviceLocator(),
        getDeviceUsers: serviceLocator(),
        logoutDevice: serviceLocator(),
        repository: serviceLocator(),
      ));

  // ── Attendance ────────────────────────────────────────────────────────────
  serviceLocator.registerLazySingleton<AttendanceLocalDatasource>(
      () => AttendanceLocalDatasourceImpl(serviceLocator()));
  // El datasource remoto reutiliza el DioClient singleton
  serviceLocator.registerLazySingleton<AttendanceRemoteDatasource>(
      () => ControlIdAttendanceDatasourceImpl(serviceLocator()));
  serviceLocator.registerLazySingleton<AttendanceRepository>(() =>
      AttendanceRepositoryImpl(
          remote: serviceLocator(), local: serviceLocator()));
  serviceLocator.registerLazySingleton(() => const AttendanceCalculator());
  serviceLocator.registerLazySingleton(
      () => GetWeekAttendance(serviceLocator(), serviceLocator()));
  serviceLocator.registerLazySingleton(() => SyncLogsLocally(serviceLocator()));
  serviceLocator.registerFactoryParam<AttendanceBloc, List<DeviceUser>, void>(
    (users, _) => AttendanceBloc(
      getWeekAttendance: serviceLocator(),
      syncLogsLocally: serviceLocator(),
      settingsRepository: serviceLocator(),
      users: users,
    ),
  );

  // Pruning silencioso al inicio
  Future.microtask(() async {
    try {
      await serviceLocator<AccessLogsDao>().pruneOldLogs(keepWeeks: 12);
    } catch (_) {}
  });
}
