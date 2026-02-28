import 'package:equatable/equatable.dart';

/// Credenciales necesarias para autenticarse contra el dispositivo.
/// Agrupadas en una entidad para que el caso de uso reciba un objeto
/// semánticamente claro en lugar de tres strings sueltos.
class DeviceCredentials extends Equatable {
  /// IP o hostname del dispositivo en la red local. Ej: "192.168.1.100"
  final String host;

  /// Puerto HTTP del dispositivo. Por defecto el ControlID usa 80.
  final int? port;

  final String login;
  final String password;

  const DeviceCredentials({
    required this.host,
    this.port,
    required this.login,
    required this.password,
  });

  /// URL base construida a partir de host y puerto.
  String get baseUrl => 'http://$host${port != null ? ':$port' : ''}';

  @override
  List<Object?> get props => [host, port, login, password];
}