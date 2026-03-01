import 'package:nomina_control/features/device/data/models/device_credentials_model.dart';
import 'package:nomina_control/features/device/domain/entities/device_credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class DeviceLocalDatasource {
  Future<void> saveCredentials(DeviceCredentials credentials);
  Future <void> deleteCredentials();
  Future<DeviceCredentials?> loadCredentials();
}

class DeviceLocalDatasourceImpl implements DeviceLocalDatasource {
  static const _key = 'device_auth_credentials';

  final SharedPreferences _prefs;

  const DeviceLocalDatasourceImpl(this._prefs);

  @override
  Future<void> saveCredentials(DeviceCredentials credentials) async {
    await _prefs.setString(_key, DeviceCredentialsModel.fromEntity(credentials).toString());
  }

  @override
  Future<DeviceCredentials?> loadCredentials() async {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      return null;
    }
    try {
      return DeviceCredentialsModel.parse(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteCredentials() async{
      await  _prefs.remove(_key);
  }
}
