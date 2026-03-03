import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nomina_control/features/session/domain/entities/saved_session.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/device_credentials.dart';
import '../../domain/entities/device_user.dart';
import '../../domain/usecases/authenticate_device.dart';
import '../../domain/usecases/get_device_users.dart';
import '../../domain/usecases/logout_device.dart';
import '../../domain/repositories/device_repository.dart';

part 'device_event.dart';

part 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final AuthenticateDevice _auth;
  final GetDeviceUsers _getUsers;
  final LogoutDevice _logout;
  final DeviceRepository _repo;

  DeviceBloc({
    required AuthenticateDevice authenticateDevice,
    required GetDeviceUsers getDeviceUsers,
    required LogoutDevice logoutDevice,
    required DeviceRepository repository,
  })  : _auth = authenticateDevice,
        _getUsers = getDeviceUsers,
        _logout = logoutDevice,
        _repo = repository,
        super(const DeviceInitial()) {
    on<DeviceAuthRequested>(_onAuth);
    on<DeviceUsersLoadRequested>(_onLoadUsers);
    on<DeviceOfflineLoadRequested>(_onOfflineLoad);
    on<DeviceLogoutRequested>(_onLogout);
  }

  Future<void> _onAuth(DeviceAuthRequested e, Emitter<DeviceState> emit) async {
    emit(const DeviceAuthenticating());
    final result = await _auth(DeviceCredentials(
      host: e.host,
      port: e.port,
      login: e.login,
      password: e.password,
    ));
    result.fold(
      (f) => emit(DeviceError(message: _msg(f))),
      (_) => emit(const DeviceAuthenticated()),
    );
  }

  Future<void> _onLoadUsers(
      DeviceUsersLoadRequested e, Emitter<DeviceState> emit) async {
    emit(const DeviceUsersLoading());
    final result = await _getUsers();
    result.fold(
      (f) => emit(DeviceError(
        message: _msg(f),
        requiresReconnect: f is SessionExpiredFailure,
      )),
      (users) => emit(DeviceUsersLoaded(users)),
    );
  }

  Future<void> _onOfflineLoad(
      DeviceOfflineLoadRequested e, Emitter<DeviceState> emit) async {
    emit(const DeviceUsersLoading());
    final result = await _repo.getCachedUsers();
    result.fold(
      (f) => emit(DeviceError(message: _msg(f))),
      (users) => emit(DeviceUsersLoaded(users, fromCache: true)),
    );
  }

  Future<void> _onLogout(
      DeviceLogoutRequested e, Emitter<DeviceState> emit) async {
    emit(const DeviceLoggingOut());
    await _logout();
    emit(const DeviceLoggedOut());
  }

  String _msg(Failure f) => switch (f) {
        ParseFailure() => 'Error al procesar datos del dispositivo.',
        _ => f.message,
      };
}
