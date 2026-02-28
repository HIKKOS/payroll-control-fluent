import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  // ── Externos ───────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(prefs);

  // ── Settings ───────────────────────────────────────────────────────────────
  serviceLocator.registerLazySingleton<SettingsLocalDatasource>(
        () => SettingsLocalDatasourceImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<SettingsRepository>(
        () => SettingsRepositoryImpl(serviceLocator()),
  );

  // ── Device ─────────────────────────────────────────────────────────────────
  serviceLocator.registerLazySingleton<DeviceRepository>(() => DeviceRepositoryImpl());
  serviceLocator.registerLazySingleton(() => AuthenticateDevice(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetDeviceUsers(serviceLocator()));
  serviceLocator.registerLazySingleton(() => LogoutDevice(serviceLocator()));
  serviceLocator.registerFactory(() => DeviceBloc(
    authenticateDevice: serviceLocator(),
    getDeviceUsers: serviceLocator(),
    logoutDevice: serviceLocator(),
  ));

  // ── Attendance ─────────────────────────────────────────────────────────────
  serviceLocator.registerLazySingleton<AttendanceLocalDatasource>(
        () => AttendanceLocalDatasourceInMemory(),
  );

  // Registramos el datasource remoto como LazySingleton.
  // IMPORTANTE: debe llamarse DESPUÉS del login para que dioClient no sea null.
  serviceLocator.registerLazySingleton<AttendanceRemoteDatasource>(() {
    final deviceRepo = serviceLocator<DeviceRepository>() as DeviceRepositoryImpl;
    return ControlIdAttendanceDatasourceImpl(deviceRepo.dioClient!);
  });

  serviceLocator.registerLazySingleton<AttendanceRepository>(
        () => AttendanceRepositoryImpl(
      remote: serviceLocator(),
      local: serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(() => const AttendanceCalculator());
  serviceLocator.registerLazySingleton(() => GetWeekAttendance(serviceLocator(), serviceLocator()));
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
}