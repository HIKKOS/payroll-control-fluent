import 'package:fpdart/fpdart.dart';
import 'package:nomina_control/features/session/domain/entities/saved_session.dart';
import '../../../../core/error/failures.dart';
import '../entities/device_credentials.dart';
import '../entities/device_user.dart';

abstract class DeviceRepository {
  Future<Either<Failure, bool>> authenticate(DeviceCredentials credentials);
  Future<Either<Failure, Unit>> restoreDeviceSession(DeviceCredentials credentials);
  Future<Either<Failure, List<DeviceUser>>> getUsers();
  Future<Either<Failure, List<DeviceUser>>> getCachedUsers();
  Future<Either<Failure, bool>> logout();
}
