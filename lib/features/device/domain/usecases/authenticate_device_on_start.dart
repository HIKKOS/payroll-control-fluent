import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/device_credentials.dart';
import '../repositories/device_repository.dart';

/// Caso de uso: **autenticar contra el dispositivo**.
///
/// Un caso de uso tiene una única responsabilidad y un único método público
/// llamado [call], lo que permite invocarlo con sintaxis de función:
/// ```dart
/// final result = await authenticateDevice(credentials);
/// ```
class AuthenticateDeviceOnStart {
  final DeviceRepository _repository;

  const AuthenticateDeviceOnStart(this._repository);

  Future<Either<Failure, bool>> call() {
    return _repository.authenticateOnStart();
  }
}
