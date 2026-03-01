import 'package:get_it/get_it.dart';
import 'package:nomina_control/features/device/data/datasources/device_local_datasource.dart';
import 'package:nomina_control/features/device/domain/usecases/authenticate_device_on_start.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/database/access_logs_dao.dart';
import 'core/database/app_database.dart';
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
import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/repositories/settings_repository.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // ── Externos ─────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(prefs);

  // ── Base de datos Drift ───────────────────────────────────────────────────
  final db = AppDatabase();
  serviceLocator.registerSingleton<AppDatabase>(db);
  serviceLocator.registerLazySingleton<AccessLogsDao>(
      () => AccessLogsDao(serviceLocator()));

  // ── Settings ──────────────────────────────────────────────────────────────
  serviceLocator.registerLazySingleton<SettingsLocalDatasource>(
      () => SettingsLocalDatasourceImpl(serviceLocator()));
  serviceLocator.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(serviceLocator()));

  // ── Device ────────────────────────────────────────────────────────────────
  serviceLocator.registerLazySingleton<DeviceLocalDatasource>(
      () => DeviceLocalDatasourceImpl(serviceLocator()));

  serviceLocator
      .registerLazySingleton<DeviceRepository>(() => DeviceRepositoryImpl(
    localDatasource:  serviceLocator(),
  ));
  serviceLocator
      .registerLazySingleton(() => AuthenticateDevice(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetDeviceUsers(serviceLocator()));
  serviceLocator.registerLazySingleton(() => LogoutDevice(serviceLocator()));
  serviceLocator.registerLazySingleton(() => AuthenticateDeviceOnStart(serviceLocator()));
  serviceLocator.registerLazySingleton(() => DeviceBloc(
        authenticateDevice: serviceLocator(),
        authenticateDeviceOnStart: serviceLocator(),
        getDeviceUsers: serviceLocator(),
        logoutDevice: serviceLocator(),
      )..add(const DeviceAuthRequestedOnStart()));

  // ── Attendance · datasources ──────────────────────────────────────────────
  // Local: implementación real con Drift
  serviceLocator.registerLazySingleton<AttendanceLocalDatasource>(
      () => AttendanceLocalDatasourceImpl(serviceLocator<AccessLogsDao>()));

  // Remoto: se registra como factory porque necesita el DioClient activo.
  // IMPORTANTE: solo se resuelve DESPUÉS del login exitoso.
  serviceLocator.registerLazySingleton<AttendanceRemoteDatasource>(() {
    final repo = serviceLocator<DeviceRepository>() as DeviceRepositoryImpl;
    return ControlIdAttendanceDatasourceImpl(repo.dioClient!);
  });

  // ── Attendance · repositorio + casos de uso ───────────────────────────────
  serviceLocator.registerLazySingleton<AttendanceRepository>(
      () => AttendanceRepositoryImpl(
            remote: serviceLocator(),
            local: serviceLocator(),
          ));

  serviceLocator.registerLazySingleton(() => const AttendanceCalculator());
  serviceLocator.registerLazySingleton(
      () => GetWeekAttendance(serviceLocator(), serviceLocator()));
  serviceLocator.registerLazySingleton(() => SyncLogsLocally(serviceLocator()));

  // AttendanceBloc recibe los usuarios como parámetro en tiempo de ejecución.
  serviceLocator.registerFactoryParam<AttendanceBloc, List<DeviceUser>, void>(
    (users, _) => AttendanceBloc(
      getWeekAttendance: serviceLocator(),
      syncLogsLocally: serviceLocator(),
      settingsRepository: serviceLocator(),
      users: users,
    ),
  );

  // Pruning automático al iniciar — limpia logs más viejos de 12 semanas
  _schedulePruning();
}

void _schedulePruning() {
  Future.microtask(() async {
    try {
      final dao = serviceLocator<AccessLogsDao>();
      await dao.pruneOldLogs(keepWeeks: 12);
    } catch (_) {}
  });
}
