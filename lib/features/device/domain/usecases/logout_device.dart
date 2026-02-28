import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/device_repository.dart';

/// Caso de uso: **cerrar sesión del dispositivo**.
class LogoutDevice {
  final DeviceRepository _repository;

  const LogoutDevice(this._repository);

  Future<Either<Failure, bool>> call() {
    return _repository.logout();
  }
}