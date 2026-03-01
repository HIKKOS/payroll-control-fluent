import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'access_logs_dao.dart';

part 'app_database.g.dart';

// ── Tablas ────────────────────────────────────────────────────────────────────

/// Registros de acceso crudos del ControlID.
class AccessLogs extends Table {
  IntColumn get id          => integer()();
  IntColumn get userId      => integer()();
  /// Unix timestamp en segundos.
  IntColumn get timestampTs => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Metadatos de sincronización: cuándo y cuántos registros se bajaron.
class SyncMetadata extends Table {
  IntColumn  get userId       => integer()();
  TextColumn get weekKey      => text()();
  IntColumn  get lastSyncedAt => integer()();
  IntColumn  get recordCount  => integer()();

  @override
  Set<Column> get primaryKey => {userId, weekKey};
}

// ── Base de datos ─────────────────────────────────────────────────────────────

@DriftDatabase(tables: [AccessLogs, SyncMetadata], daos: [AccessLogsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Migraciones futuras aquí
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir  = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'nomina_control.db'));
    return NativeDatabase.createInBackground(file);
  });
}
