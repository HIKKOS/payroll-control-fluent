part of 'device_bloc.dart';

abstract class DeviceState extends Equatable {
  const DeviceState();
  @override List<Object?> get props => [];
}

class DeviceInitial extends DeviceState {
  const DeviceInitial();
}

class DeviceAuthenticating extends DeviceState {
  const DeviceAuthenticating();
}

class DeviceAuthenticated extends DeviceState {
  const DeviceAuthenticated();
}

class DeviceUsersLoading extends DeviceState {
  const DeviceUsersLoading();
}

class DeviceUsersLoaded extends DeviceState {
  final List<DeviceUser> users;
  /// True si los datos vienen de Drift (modo offline).
  final bool fromCache;

  const DeviceUsersLoaded(this.users, {this.fromCache = false});

  @override List<Object?> get props => [users, fromCache];
}

class DeviceLoggingOut extends DeviceState {
  const DeviceLoggingOut();
}

class DeviceLoggedOut extends DeviceState {
  const DeviceLoggedOut();
}

class DeviceError extends DeviceState {
  final String message;
  final bool requiresReconnect;

  const DeviceError({required this.message, this.requiresReconnect = false});
  @override List<Object?> get props => [message, requiresReconnect];
}
