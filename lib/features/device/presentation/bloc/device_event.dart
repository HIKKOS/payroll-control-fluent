part of 'device_bloc.dart';

/// Eventos que el BLoC del dispositivo puede recibir.
/// Cada acción del usuario o del sistema genera un evento inmutable.
abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

/// El usuario presionó "Conectar" en la pantalla de login del dispositivo.
class DeviceAuthRequested extends DeviceEvent {
  final String host;
  final int? port;
  final String login;
  final String password;

  const DeviceAuthRequested({
    required this.host,
    required this.login,
    required this.password,
      this.port,
  });

  @override
  List<Object?> get props => [host, port, login, password];
}

/// El usuario está en la pantalla de usuarios y se deben cargar los registros.
/// También se usa para hacer "pull to refresh".
class DeviceUsersLoadRequested extends DeviceEvent {
  const DeviceUsersLoadRequested();
}

/// El usuario presionó "Cerrar sesión".
class DeviceLogoutRequested extends DeviceEvent {
  const DeviceLogoutRequested();
}
class DeviceAuthRequestedOnStart extends DeviceEvent {
  const DeviceAuthRequestedOnStart();
}