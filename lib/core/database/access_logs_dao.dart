import 'package:drift/drift.dart';
import 'app_database.dart';

part 'access_logs_dao.g.dart';

@DriftAccessor(tables: [AccessLogs, SyncMetadata])
class AccessLogsDao extends DatabaseAccessor<AppDatabase>
    with _$AccessLogsDaoMixin {
  AccessLogsDao(super.db);

  // ── Escritura ──────────────────────────────────────────────────────────────

  /// Inserta logs sin fallar si ya existen (INSERT OR IGNORE equivalente).
  Future<void> insertLogs(List<AccessLogsCompanion> rows) async {
    await batch((b) {
      b.insertAll(accessLogs, rows, mode: InsertMode.insertOrIgnore);
    });
  }

  /// Registra el último sync de un usuario para una semana.
  Future<void> upsertSyncMeta({
    required int userId,
    required String weekKey,
    required int count,
  }) async {
    await into(syncMetadata).insertOnConflictUpdate(SyncMetadataData(
      userId:       userId,
      weekKey:      weekKey,
      lastSyncedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      recordCount:  count,
    ));
  }

  // ── Lectura ────────────────────────────────────────────────────────────────

  /// Devuelve logs de un usuario en un rango de fechas, ordenados por timestamp.
  Future<List<AccessLog>> getLogsForUser({
    required int userId,
    required DateTime from,
    required DateTime to,
  }) {
    final fromTs = from.millisecondsSinceEpoch ~/ 1000;
    final toTs   = to.millisecondsSinceEpoch   ~/ 1000;

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
          ..where((t) =>
              t.userId.equals(userId) &
              t.weekKey.equals(weekKey)))
        .getSingleOrNull();
  }

  /// Todos los weekKeys con datos locales de un usuario (para mostrar en UI).
  Future<List<String>> getAvailableWeekKeys(int userId) {
    return (select(syncMetadata)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.weekKey)]))
        .map((r) => r.weekKey)
        .get();
  }

  // ── Mantenimiento ──────────────────────────────────────────────────────────

  /// Elimina logs y metadatos más viejos que [keepWeeks] semanas.
  /// Llámalo al arrancar la app para no crecer indefinidamente.
  Future<int> pruneOldLogs({int keepWeeks = 12}) async {
    final cutoff = DateTime.now()
        .subtract(Duration(days: keepWeeks * 7))
        .millisecondsSinceEpoch ~/ 1000;

    final deleted = await (delete(accessLogs)
          ..where((t) => t.timestampTs.isSmallerThanValue(cutoff)))
        .go();

    // También limpiamos metadatos huérfanos del mismo período
    final cutoffKey = _weekKey(
        DateTime.now().subtract(Duration(days: keepWeeks * 7)));
    await (delete(syncMetadata)
          ..where((t) => t.weekKey.isSmallerThanValue(cutoffKey)))
        .go();

    return deleted;
  }

  /// Cuenta total de logs en la base de datos local.
  Future<int> totalLogCount() async {
    final count = countAll();
    final query = selectOnly(accessLogs)..addColumns([count]);
    final row   = await query.getSingle();
    return row.read(count) ?? 0;
  }

  // ── Helper ─────────────────────────────────────────────────────────────────

  /// Convierte una fecha a clave de semana ISO: "2024-W12".
  static String _weekKey(DateTime date) {
    // Semana ISO: lunes = día 1
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final weekNum = ((monday.difference(DateTime(monday.year, 1, 1)).inDays) / 7).ceil() + 1;
    return '${monday.year}-W${weekNum.toString().padLeft(2, '0')}';
  }

  /// Clave pública para que el repositorio construya el weekKey.
  static String buildWeekKey(DateTime weekStart) => _weekKey(weekStart);
}
