import 'package:drift/drift.dart';

import '../../../../core/database/access_logs_dao.dart';
import '../../../../core/database/app_database.dart';
import '../models/access_log_model.dart';

// ── Contrato ──────────────────────────────────────────────────────────────────
abstract class AttendanceLocalDatasource {
  Future<void> insertLogs(List<AccessLogModel> logs, {required String weekKey});
  Future<List<AccessLogModel>> getLocalLogs({
    required int userId,
    required DateTime from,
    required DateTime to,
  });
  Future<void> pruneOldLogs({int keepWeeks = 12});
  Future<SyncInfo?> getSyncInfo({required int userId, required String weekKey});
  Future<int> totalLogCount();
}

/// Información del último sync — se muestra en la UI.
class SyncInfo {
  final DateTime syncedAt;
  final int recordCount;
  const SyncInfo({required this.syncedAt, required this.recordCount});
}

// ── Implementación Drift ──────────────────────────────────────────────────────
class AttendanceLocalDatasourceImpl implements AttendanceLocalDatasource {
  final AccessLogsDao _dao;

  const AttendanceLocalDatasourceImpl(this._dao);

  @override
  Future<void> insertLogs(
    List<AccessLogModel> logs, {
    required String weekKey,
  }) async {
    if (logs.isEmpty) return;

    final userId = logs.first.userId;
    final companions = logs
        .map((m) => AccessLogsCompanion.insert(
              id:          Value(m.id),
              userId:      m.userId,
              timestampTs: m.timestamp.millisecondsSinceEpoch ~/ 1000,
            ))
        .toList();

    await _dao.insertLogs(companions);
    await _dao.upsertSyncMeta(
      userId:  userId,
      weekKey: weekKey,
      count:   logs.length,
    );
  }

  @override
  Future<List<AccessLogModel>> getLocalLogs({
    required int userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await _dao.getLogsForUser(userId: userId, from: from, to: to);
    return rows
        .map((r) => AccessLogModel(
              id:        r.id,
              userId:    r.userId,
              timestamp: DateTime.fromMillisecondsSinceEpoch(
                  r.timestampTs * 1000, isUtc: false),
            ))
        .toList();
  }

  @override
  Future<void> pruneOldLogs({int keepWeeks = 12}) =>
      _dao.pruneOldLogs(keepWeeks: keepWeeks);

  @override
  Future<SyncInfo?> getSyncInfo({
    required int userId,
    required String weekKey,
  }) async {
    final meta = await _dao.getSyncMeta(userId: userId, weekKey: weekKey);
    if (meta == null) return null;
    return SyncInfo(
      syncedAt:    DateTime.fromMillisecondsSinceEpoch(meta.lastSyncedAt * 1000),
      recordCount: meta.recordCount,
    );
  }

  @override
  Future<int> totalLogCount() => _dao.totalLogCount();
}
