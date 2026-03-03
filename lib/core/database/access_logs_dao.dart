import 'package:drift/drift.dart';
import 'app_database.dart';

part 'access_logs_dao.g.dart';

@DriftAccessor(tables: [AccessLogs, SyncMetadata, CachedUsers])
class AccessLogsDao extends DatabaseAccessor<AppDatabase>
    with _$AccessLogsDaoMixin {
  AccessLogsDao(super.db);

  // ── AccessLogs ────────────────────────────────────────────────────────────

  Future<void> insertLogs(List<AccessLogsCompanion> rows) async {
    await batch((b) {
      b.insertAll(accessLogs, rows, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> upsertSyncMeta({
    required int userId,
    required String weekKey,
    required int count,
  }) async {
    await into(syncMetadata).insertOnConflictUpdate(SyncMetadataData(
      userId: userId,
      weekKey: weekKey,
      lastSyncedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      recordCount: count,
    ));
  }

  Future<List<AccessLog>> getLogsForUser({
    required int userId,
    required DateTime from,
    required DateTime to,
  }) {
    final fromTs = from.millisecondsSinceEpoch ~/ 1000;
    final toTs = to.millisecondsSinceEpoch ~/ 1000;
    return (select(accessLogs)
          ..where((t) =>
              t.userId.equals(userId) &
              t.timestampTs.isBiggerOrEqualValue(fromTs) &
              t.timestampTs.isSmallerOrEqualValue(toTs))
          ..orderBy([(t) => OrderingTerm.asc(t.timestampTs)]))
        .get();
  }

  /// Metadatos del último sync de un usuario para una semana.
  Future<SyncMetadataData?> getSyncMeta({
    required int userId,
    required String weekKey,
  }) {
    return (select(syncMetadata)
          ..where((t) => t.userId.equals(userId) & t.weekKey.equals(weekKey)))
        .getSingleOrNull();
  }

  Future<int> pruneOldLogs({int keepWeeks = 12}) async {
    final cutoff = DateTime.now()
            .subtract(Duration(days: keepWeeks * 7))
            .millisecondsSinceEpoch ~/
        1000;
    final cutoffKey =
        buildWeekKey(DateTime.now().subtract(Duration(days: keepWeeks * 7)));

    final deleted = await (delete(accessLogs)
          ..where((t) => t.timestampTs.isSmallerThanValue(cutoff)))
        .go();
    await (delete(syncMetadata)
          ..where((t) => t.weekKey.isSmallerThanValue(cutoffKey)))
        .go();
    return deleted;
  }

  Future<int> totalLogCount() async {
    final count = countAll();
    final query = selectOnly(accessLogs)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  // ── CachedUsers ───────────────────────────────────────────────────────────

  Future<void> upsertCachedUsers(List<CachedUsersCompanion> rows) async {
    await batch((b) {
      b.insertAll(cachedUsers, rows, mode: InsertMode.insertOrReplace);
    });
  }

  Future<List<CachedUser>> getAllCachedUsers() => select(cachedUsers).get();

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String buildWeekKey(DateTime weekStart) {
    final monday = weekStart.subtract(Duration(days: weekStart.weekday - 1));
    final weekNum =
        ((monday.difference(DateTime(monday.year, 1, 1)).inDays) / 7).ceil() +
            1;
    return '${monday.year}-W${weekNum.toString().padLeft(2, '0')}';
  }
}
