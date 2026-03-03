import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'access_logs_dao.dart';

part 'app_database.g.dart';

// ── Tablas ────────────────────────────────────────────────────────────────────

class AccessLogs extends Table {
  IntColumn get id => integer()();

  IntColumn get userId => integer()();

  IntColumn get timestampTs => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncMetadata extends Table {
  IntColumn get userId => integer()();

  TextColumn get weekKey => text()();

  IntColumn get lastSyncedAt => integer()();

  IntColumn get recordCount => integer()();

  @override
  Set<Column> get primaryKey => {userId, weekKey};
}

/// Snapshot de empleados para modo offline.
/// Se actualiza cada vez que se carga la lista online.
class CachedUsers extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text()();

  TextColumn get registration => text()();

  IntColumn get savedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Base de datos ─────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [AccessLogs, SyncMetadata, CachedUsers],
  daos: [AccessLogsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2; // bumped por CachedUsers

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(cachedUsers);
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'nomina_control.db'));
    return NativeDatabase.createInBackground(file);
  });
}
