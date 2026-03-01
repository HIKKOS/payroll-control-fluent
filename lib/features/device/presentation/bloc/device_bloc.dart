import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nomina_control/features/device/domain/usecases/authenticate_device_on_start.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/device_credentials.dart';
import '../../domain/entities/device_user.dart';
import '../../domain/usecases/authenticate_device.dart';
import '../../domain/usecases/get_device_users.dart';
import '../../domain/usecases/logout_device.dart';

part 'device_event.dart';

part 'device_state.dart';

/// BLoC del dispositivo de control de acceso.
///
/// Orquesta los casos de uso y traduce [Either<Failure, T>] en estados
/// que la UI puede renderizar de forma declarativa.
///
/// Flujo principal:
/// 1. UI envía [DeviceAuthRequested]
/// 2. BLoC emite [DeviceAuthenticating] → llama [AuthenticateDevice]
/// 3. Si OK: emite [DeviceAuthenticated]  →  UI navega a lista de usuarios
/// 4. UI envía [DeviceUsersLoadRequested]
/// 5. BLoC emite [DeviceUsersLoading]   →  llama [GetDeviceUsers]
/// 6. Si OK: emite [DeviceUsersLoaded]
class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final AuthenticateDevice _authenticateDevice;
  final GetDeviceUsers _getDeviceUsers;
  final LogoutDevice _logoutDevice;
  final AuthenticateDeviceOnStart _authenticateDeviceOnStart;
  DeviceBloc({
    required AuthenticateDevice authenticateDevice,
    required AuthenticateDeviceOnStart authenticateDeviceOnStart,
    required GetDeviceUsers getDeviceUsers,
    required LogoutDevice logoutDevice,
  })  : _authenticateDevice = authenticateDevice,
        _getDeviceUsers = getDeviceUsers,
          _authenticateDeviceOnStart = authenticateDeviceOnStart,
        _logoutDevice = logoutDevice,
        super(const DeviceInitial()) {
    on<DeviceAuthRequested>(_onAuthRequested);
    on<DeviceUsersLoadRequested>(_onUsersLoadRequested);
    on<DeviceLogoutRequested>(_onLogoutRequested);
    on<DeviceAuthRequestedOnStart>(
        _onDeviceAuthRequestedOnStart
    );

  }
  Future<void >_onDeviceAuthRequestedOnStart (DeviceAuthRequestedOnStart event, emit)async {
    emit(const DeviceAuthenticating());
    final result = await _authenticateDeviceOnStart();
    result.fold(
          (failure) => emit(DeviceError(message: _mapFailureToMessage(failure))),
          (_) => emit(const DeviceAuthenticated()),
    );
  }
  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onAuthRequested(
    DeviceAuthRequested event,
    Emitter<DeviceState> emit,
  ) async {
    emit(const DeviceAuthenticating());

    final credentials = DeviceCredentials(
      host: event.host,
      port: event.port,
      login: event.login,
      password: event.password,
    );

    final result = await _authenticateDevice(credentials);

    result.fold(
      (failure) => emit(DeviceError(message: _mapFailureToMessage(failure))),
      (_) => emit(const DeviceAuthenticated()),
    );
  }

  Future<void> _onUsersLoadRequested(
    DeviceUsersLoadRequested event,
    Emitter<DeviceState> emit,
  ) async {
    emit(const DeviceUsersLoading());

    final result = await _getDeviceUsers();

    result.fold(
      (failure) => emit(DeviceError(
        message: _mapFailureToMessage(failure),
        requiresReconnect: failure is SessionExpiredFailure,
      )),
      (users) => emit(DeviceUsersLoaded(users)),
    );
  }

  Future<void> _onLogoutRequested(
    DeviceLogoutRequested event,
    Emitter<DeviceState> emit,
  ) async {
    emit(const DeviceLoggingOut());
    await _logoutDevice();
    emit(const DeviceLoggedOut());
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return failure.message;
      case const (AuthFailure):
        return failure.message;
      case const (SessionExpiredFailure):
        return failure.message;
      case const (ServerFailure):
        return failure.message;
      case const (ParseFailure):
        return 'Error al procesar datos del dispositivo.';
      default:
        return 'Error inesperado. Intenta de nuevo.';
    }
  }
  @override
  Future<void> close() {
    // TODO: implement close
    return super.close();
  }
}
