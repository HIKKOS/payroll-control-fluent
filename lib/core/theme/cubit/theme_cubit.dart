import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estado sellado del tema — solo dos posibles valores.
enum AppThemeMode { dark, light }

/// Cubit mínimo: mantiene el tema activo y lo persiste en SharedPreferences.
///
/// No usa BLoC completo porque no hay eventos complejos —
/// solo un toggle y una carga inicial.
class ThemeCubit extends Cubit<AppThemeMode> {
  static const _prefKey = 'app_theme_mode';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_load(_prefs));

  /// Lee la preferencia guardada; si no existe, usa dark por defecto.
  static AppThemeMode _load(SharedPreferences prefs) {
    final saved = prefs.getString(_prefKey);
    return saved == 'light' ? AppThemeMode.light : AppThemeMode.dark;
  }

  void setDark()  => _set(AppThemeMode.dark);
  void setLight() => _set(AppThemeMode.light);

  void toggle() => _set(
    state == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark,
  );

  void _set(AppThemeMode mode) {
    _prefs.setString(_prefKey, mode.name); // persiste inmediatamente
    emit(mode);
  }
}
