
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/device_user.dart';
import '../repositories/device_repository.dart';

/// Caso de uso: **obtener usuarios registrados en el dispositivo**.
class GetDeviceUsers {
  final DeviceRepository _repository;

  const GetDeviceUsers(this._repository);

  Future<Either<Failure, List<DeviceUser>>> call() {
    return _repository.getUsers();
  }
}