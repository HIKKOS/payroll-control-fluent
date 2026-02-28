import '../models/access_log_model.dart';

/// Datasource local para logs de acceso (modo offline).
///
/// La implementación real usará Drift. Por ahora proveemos la interfaz
/// para que el repositorio ya pueda compilar. En la siguiente fase
/// se agrega la tabla Drift y se implementa [AttendanceLocalDatasourceImpl].
abstract class AttendanceLocalDatasource {
  /// Guarda logs en la base de datos local.
  Future<void> insertLogs(List<AccessLogModel> logs);

  /// Obtiene logs filtrados por usuario y rango de fechas desde local.
  Future<List<AccessLogModel>> getLocalLogs({
    required int userId,
    required DateTime from,
    required DateTime to,
  });

  /// Limpia logs más antiguos que [olderThan] para no crecer indefinidamente.
  Future<void> pruneOldLogs(DateTime olderThan);
}

/// Implementación en memoria temporal.
/// Reemplazar con Drift cuando se implemente la base de datos.
class AttendanceLocalDatasourceInMemory implements AttendanceLocalDatasource {
  final List<AccessLogModel> _store = [];

  @override
  Future<void> insertLogs(List<AccessLogModel> logs) async {
    for (final log in logs) {
      if (!_store.any((s) => s.id == log.id)) {
        _store.add(log);
      }
    }
  }

  @override
  Future<List<AccessLogModel>> getLocalLogs({
    required int userId,
    required DateTime from,
    required DateTime to,
  }) async {
    return _store
        .where((l) =>
            l.userId == userId &&
            !l.timestamp.isBefore(from) &&
            !l.timestamp.isAfter(to))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  @override
  Future<void> pruneOldLogs(DateTime olderThan) async {
    _store.removeWhere((l) => l.timestamp.isBefore(olderThan));
  }
}
