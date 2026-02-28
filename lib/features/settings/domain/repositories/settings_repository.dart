import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/work_schedule_config.dart';

abstract class SettingsRepository {
  /// Carga la configuración guardada. Si no existe, devuelve los valores por defecto.
  Future<Either<Failure, WorkScheduleConfig>> getConfig();

  /// Persiste la configuración localmente.
  Future<Either<Failure, bool>> saveConfig(WorkScheduleConfig config);
}
