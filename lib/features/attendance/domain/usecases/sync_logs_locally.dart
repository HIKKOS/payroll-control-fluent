
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/attendance_repository.dart';

class SyncLogsLocallyParams {
  final List<int> userIds;
  final DateTime from;
  final DateTime to;

  const SyncLogsLocallyParams({
    required this.userIds,
    required this.from,
    required this.to,
  });
}

/// Descarga y persiste localmente los logs de todos los usuarios
/// para el rango de fechas indicado.
///
/// Esto es la features "descargar accesos localmente" que permite
/// consultar nómina sin estar en la misma red que el dispositivo.
class SyncLogsLocally {
  final AttendanceRepository _repository;

  const SyncLogsLocally(this._repository);

  Future<Either<Failure, int>> call(SyncLogsLocallyParams params) async {
    int totalSynced = 0;

    for (final userId in params.userIds) {
      final result = await _repository.syncLogsLocally(
        GetAccessLogsParams(userId: userId, from: params.from, to: params.to),
      );
      result.fold((_) {}, (count) => totalSynced += count);
    }

    return Right(totalSynced);
  }
}
