import 'package:get_it/get_it.dart';
import 'package:nomina_control/features/device/data/repositories/device_repository_impl.dart';
import 'package:nomina_control/features/device/domain/repositories/device_repository.dart';
import 'package:nomina_control/features/device/domain/usecases/authenticate_device.dart';
import 'package:nomina_control/features/device/domain/usecases/get_device_users.dart';
import 'package:nomina_control/features/device/domain/usecases/logout_device.dart';
import 'package:nomina_control/features/device/presentation/bloc/device_bloc.dart';


/// Instancia global del contenedor de inyección de dependencias.
final serviceLocator = GetIt.instance;

/// Registra todas las dependencias de la app.
///
/// Llama a esta función en [main()] antes de [runApp()].
///
/// Orden importante: registrar de abajo hacia arriba (de infraestructura
/// hacia presentación) para que cada capa encuentre sus dependencias.
Future<void> initDependencies() async {
  // ── Repositorios ───────────────────────────────────────────────────────────
  // LazySingleton: se crea la primera vez que se pide y luego se reutiliza.
  // El repositorio mantiene el estado de la sesión, por eso es singleton.
  serviceLocator.registerLazySingleton<DeviceRepository>(
        () => DeviceRepositoryImpl(),
  );

  // ── Casos de uso ──────────────────────────────────────────────────────────
  serviceLocator.registerLazySingleton(() => AuthenticateDevice(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetDeviceUsers(serviceLocator()));
  serviceLocator.registerLazySingleton(() => LogoutDevice(serviceLocator()));

  // ── BLoCs ─────────────────────────────────────────────────────────────────
  // Factory: se crea una nueva instancia cada vez que se solicita.
  // Así cada pantalla/widget tiene su propio BLoC sin estado compartido
  // involuntariamente.
  serviceLocator.registerFactory(
        () => DeviceBloc(
      authenticateDevice: serviceLocator(),
      getDeviceUsers: serviceLocator(),
      logoutDevice: serviceLocator(),
    ),
  );
}