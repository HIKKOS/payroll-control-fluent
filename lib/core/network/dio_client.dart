import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'session_cookie_interceptor.dart';

/// Cliente HTTP centralizado para comunicarse con el ControlID.
///
/// Ciclo de vida:
/// - Al arrancar la app se crea un cliente vacío (sin baseUrl).
/// - [reconfigure] lo inicializa con el host/puerto del dispositivo.
///   Se llama tanto desde el login manual como desde la restauración de sesión.
/// - El singleton en GetIt garantiza que Session y Device comparten
///   la misma cookie de autenticación.
class DioClient {
  late Dio _dio;
  late SessionCookieInterceptor _sessionInterceptor;
  bool _configured = false;

  DioClient() {
    _sessionInterceptor = SessionCookieInterceptor();
    _dio = Dio(); // instancia vacía hasta reconfigure()
  }

  Dio get dio => _dio;

  bool get hasActiveSession => _configured && _sessionInterceptor.hasSession;

  void clearSession() => _sessionInterceptor.clearSession();

  /// Inicializa (o re-inicializa) el cliente con nuevo host/puerto.
  /// [keepSession] conserva la cookie existente (para el check de sesión).
  void reconfigure({
    required String host,
      int? port,
    bool keepSession = true,
  }) {
    if (!keepSession) _sessionInterceptor = SessionCookieInterceptor();

    _dio = Dio(BaseOptions(
      baseUrl:     'http://$host${port != null ? ':$port' : ''}',
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      contentType: Headers.jsonContentType,
      validateStatus: (_) => true,
    ))
      ..interceptors.addAll([
        _sessionInterceptor,
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
        ),
      ]);

    _configured = true;
  }
}
