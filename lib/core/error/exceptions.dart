/// Excepciones internas de la capa de **data**.
/// Nunca deben escapar hacia dominio o presentación;
/// los repositorios las capturan y las convierten en [Failure].

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Error de red.']);
  @override
  String toString() => 'NetworkException: $message';
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException(this.message, {this.statusCode});
  @override
  String toString() => 'ServerException($statusCode): $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Credenciales inválidas.']);
  @override
  String toString() => 'AuthException: $message';
}

class SessionExpiredException implements Exception {
  const SessionExpiredException();
  @override
  String toString() => 'SessionExpiredException';
}

class ParseException implements Exception {
  final String message;
  const ParseException([this.message = 'Error de parseo.']);
  @override
  String toString() => 'ParseException: $message';
}