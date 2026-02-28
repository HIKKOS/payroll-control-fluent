import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/work_schedule_config_model.dart';

/// Datasource local de configuración usando SharedPreferences.
/// Simple clave-valor JSON. No necesita Drift para un solo objeto.
///
/// Si mañana se necesita cloud-sync, solo se crea una nueva implementación
/// de [SettingsLocalDatasource].
abstract class SettingsLocalDatasource {
  Future<WorkScheduleConfigModel?> getConfig();
  Future<void> saveConfig(WorkScheduleConfigModel model);
}

class SettingsLocalDatasourceImpl implements SettingsLocalDatasource {
  static const _key = 'work_schedule_config';

  final SharedPreferences _prefs;

  const SettingsLocalDatasourceImpl(this._prefs);

  @override
  Future<WorkScheduleConfigModel?> getConfig() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      return WorkScheduleConfigModel.fromJson(
        json.decode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveConfig(WorkScheduleConfigModel model) async {
    await _prefs.setString(_key, json.encode(model.toJson()));
  }
}
