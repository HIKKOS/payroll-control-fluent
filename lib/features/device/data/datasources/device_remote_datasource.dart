import '../models/user_model.dart';

/// Contrato del datasource remoto del dispositivo.
/// Separar el contrato de la implementación facilita sustituir
/// el hardware (o crear un [MockDeviceDatasource] para tests).
abstract interface class DeviceRemoteDatasource {
  /// Realiza el login en el dispositivo.
  /// Lanza [AuthException] si las credenciales son incorrectas.
  /// Lanza [NetworkException] si no hay conectividad.
  Future<void> login({
    required String login,
    required String password,
  });

  /// Obtiene los usuarios registrados en el dispositivo.
  /// Lanza [SessionExpiredException] si no hay sesión activa.
  Future<List<UserModel>> getUsers();

  /// Cierra la sesión en el dispositivo.
  Future<void> logout();
}