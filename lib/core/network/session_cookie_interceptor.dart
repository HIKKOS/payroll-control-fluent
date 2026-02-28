import 'package:dio/dio.dart';

/// Interceptor que captura la cookie `session` que devuelve el ControlID
/// tras un login exitoso y la reenvía automáticamente en cada petición.
///
/// El ControlID usa autenticación basada en cookies HTTP; sin esto,
/// cada llamada a [/load_objects.fcgi] sería rechazada con 401.
class SessionCookieInterceptor extends Interceptor {
  String? _sessionCookie;

  /// Permite inspeccionar externamente si hay sesión activa.
  bool get hasSession => _sessionCookie != null;

  /// Limpia la sesión (logout local).
  void clearSession() => _sessionCookie = null;

  // ── Outgoing request ──────────────────────────────────────────────────────

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_sessionCookie != null) {
      options.queryParameters = {
        ...options.queryParameters,
        'session': _sessionCookie!,
      };
    }
    handler.next(options);
  }

  // ── Incoming response ─────────────────────────────────────────────────────

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _extractAndStoreCookie(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Si el servidor devuelve 401 limpiamos la sesión local.
    if (err.response?.statusCode == 401) {
      clearSession();
    }
    handler.next(err);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _extractAndStoreCookie(Response response) {
    final setCookie = response.data is Map<String, dynamic>
        ? response.data['session'] as String?
        : null;
    if (setCookie == null || setCookie.isEmpty) return;
    _sessionCookie = setCookie;
  }
}
