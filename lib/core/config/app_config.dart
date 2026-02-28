/// Configuración global de la app.
/// Los valores de timeout y rutas de la API del dispositivo viven aquí
/// para que sean fáciles de cambiar sin tocar la lógica de negocio.
class AppConfig {
  AppConfig._();

  // ── Timeouts ──────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ── Endpoints del ControlID ───────────────────────────────────────────────
  static const String loginEndpoint       = '/login.fcgi';
  static const String loadObjectsEndpoint = '/load_objects.fcgi';
  static const String logoutEndpoint      = '/logout.fcgi';

  // ── Nombres de objetos en la API ──────────────────────────────────────────
  static const String userObject          = 'users';
  static const String accessLogsObject          = 'access_logs';
}