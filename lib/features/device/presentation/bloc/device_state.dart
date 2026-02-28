part of 'device_bloc.dart';

/// Estados del BLoC del dispositivo.
/// Cada estado es inmutable e incluye solo los datos que la UI necesita.
abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial — la app acaba de arrancar, no hay sesión.
class DeviceInitial extends DeviceState {
  const DeviceInitial();
}

/// Autenticando contra el dispositivo (mostramos un spinner).
class DeviceAuthenticating extends DeviceState {
  const DeviceAuthenticating();
}

/// Login exitoso — se puede navegar a la pantalla de usuarios.
class DeviceAuthenticated extends DeviceState {
  const DeviceAuthenticated();
}

/// Cargando la lista de usuarios del dispositivo.
class DeviceUsersLoading extends DeviceState {
  const DeviceUsersLoading();
}

/// Lista de usuarios cargada y lista para mostrarse.
class DeviceUsersLoaded extends DeviceState {
  final List<DeviceUser> users;

  const DeviceUsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

/// Cerrando sesión en progreso.
class DeviceLoggingOut extends DeviceState {
  const DeviceLoggingOut();
}

/// Sesión cerrada correctamente — regresamos a la pantalla de conexión.
class DeviceLoggedOut extends DeviceState {
  const DeviceLoggedOut();
}

/// Ocurrió un error en cualquier operación.
class DeviceError extends DeviceState {
  final String message;

  /// Indica si el error es recuperable (el usuario puede reintentar)
  /// o si debe volver a la pantalla de conexión (sesión expirada, etc.).
  final bool requiresReconnect;

  const DeviceError({
    required this.message,
    this.requiresReconnect = false,
  });

  @override
  List<Object?> get props => [message, requiresReconnect];
}