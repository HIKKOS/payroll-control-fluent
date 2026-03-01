import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/device_credentials.dart';
import '../entities/device_user.dart';

/// **Contrato abstracto** del repositorio de dispositivo.
///
/// La capa de dominio solo conoce esta interfaz.
/// Hoy la implementa [DeviceRepositoryImpl] con Dio + ControlID;
/// mañana puede implementarla cualquier otra clase para otro hardware
/// sin cambiar ni una línea de dominio o presentación.
abstract class DeviceRepository {
  /// Autentica contra el dispositivo y establece la sesión.
  /// Retorna [true] si el login fue exitoso.
  Future<Either<Failure, bool>> authenticate(DeviceCredentials credentials);

  /// Obtiene la lista de usuarios registrados en el dispositivo.
  /// Requiere sesión activa (llamar [authenticate] primero).
  Future<Either<Failure, List<DeviceUser>>> getUsers();

  Future<Either<Failure, bool>> authenticateOnStart();


  /// Cierra la sesión contra el dispositivo y limpia el estado local.
  Future<Either<Failure, bool>> logout();
}