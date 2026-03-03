import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/saved_session.dart';

abstract class SessionLocalDatasource {
  Future<SavedSession?> getSession();
  Future<void> saveSession(SavedSession session);
  Future<void> clearSession();
  Future<void> touchSession();
}

class SessionLocalDatasourceImpl implements SessionLocalDatasource {
  static const _key = 'nomina_device_session_v1';
  final SharedPreferences _prefs;

  const SessionLocalDatasourceImpl(this._prefs);

  @override
  Future<SavedSession?> getSession() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      final m = json.decode(raw) as Map<String, dynamic>;
      return SavedSession(
        host:        m['host']          as String,
        port:        m['port']          as int,
        login:       m['login']         as String,
        password:    m['password']      as String,
        lastLoginAt: m['last_login_at'] as int,
      );
    } catch (_) {
      return null; // JSON corrupto → tratar como sin sesión
    }
  }

  @override
  Future<void> saveSession(SavedSession s) => _prefs.setString(_key,
      json.encode({
        'host':          s.host,
        'port':          s.port,
        'login':         s.login,
        'password':      s.password,
        'last_login_at': s.lastLoginAt,
      }));

  @override
  Future<void> clearSession() => _prefs.remove(_key);

  @override
  Future<void> touchSession() async {
    final s = await getSession();
    if (s != null) await saveSession(s.copyWithNow());
  }
}
