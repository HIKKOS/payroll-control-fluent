import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'session_cookie_interceptor.dart';

/// Cliente HTTP centralizado para comunicarse con el ControlID.
///
/// Se instancia con la IP/host del dispositivo en tiempo de ejecución
/// (cuando el usuario ingresa los datos de conexión), no al arrancar la app.
/// Esto permite que la app funcione sin red hasta que el usuario configure
/// la conexión.
class DioClient {
  late final Dio dio;
  late final SessionCookieInterceptor sessionInterceptor;

  DioClient({required String baseUrl}) {
    sessionInterceptor = SessionCookieInterceptor();

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        // El ControlID espera JSON en el body
        contentType: Headers.jsonContentType,
        // Acepta cualquier status para manejarlo nosotros mismos
        validateStatus: (_) => true,
      ),
    )..interceptors.addAll([
      sessionInterceptor,
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ),
    ]);
  }

  bool get hasActiveSession => sessionInterceptor.hasSession;

  void clearSession() => sessionInterceptor.clearSession();
}