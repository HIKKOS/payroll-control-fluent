part of 'device_bloc.dart';

abstract class DeviceEvent extends Equatable {
  const DeviceEvent();
  @override List<Object?> get props => [];
}

class DeviceAuthRequested extends DeviceEvent {
  final String host;
  final int    port;
  final String login;
  final String password;

  const DeviceAuthRequested({
    required this.host,
    required this.port,
    required this.login,
    required this.password,
  });

  factory DeviceAuthRequested.fromSession(SavedSession session) => DeviceAuthRequested(
    host: session.host,
    port: session.port,
    login: session.login,
    password: session.password,
  );

  @override List<Object?> get props => [host, port, login, password];
}

class DeviceUsersLoadRequested extends DeviceEvent {
  const DeviceUsersLoadRequested();
}

/// Modo offline: carga el snapshot guardado en Drift (sin red).
class DeviceOfflineLoadRequested extends DeviceEvent {
  const DeviceOfflineLoadRequested();
}

class DeviceLogoutRequested extends DeviceEvent {
  const DeviceLogoutRequested();
}
