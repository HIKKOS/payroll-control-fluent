import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/work_schedule_config.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/work_schedule_config_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource _datasource;

  const SettingsRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, WorkScheduleConfig>> getConfig() async {
    try {
      final model = await _datasource.getConfig();
      // Si no hay config guardada, retornamos los valores por defecto
      return Right(model?.toEntity() ?? const WorkScheduleConfig());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> saveConfig(WorkScheduleConfig config) async {
    try {
      await _datasource.saveConfig(WorkScheduleConfigModel.fromEntity(config));
      return const Right(true);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
