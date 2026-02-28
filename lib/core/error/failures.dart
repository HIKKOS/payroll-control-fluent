import 'package:equatable/equatable.dart';

/// Clase base para todos los errores de dominio.
/// Usamos [Either<Failure, T>] en los repositorios para evitar excepciones
/// no controladas en la UI.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// ── Fallos de red / dispositivo ────────────────────────────────────────────

/// No se pudo alcanzar el host (timeout, sin red, IP incorrecta).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No se pudo conectar al dispositivo.']);
}

/// El servidor respondió pero con un código de error HTTP.
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

/// Credenciales incorrectas (401 / respuesta de login fallida).
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Usuario o contraseña incorrectos.']);
}

/// La sesión expiró o no existe cookie válida.
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([super.message = 'La sesión ha expirado. Vuelve a iniciar sesión.']);
}

/// Error al parsear la respuesta JSON.
class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Error al procesar la respuesta del dispositivo.']);
}

/// Error genérico / inesperado.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Ocurrió un error inesperado.']);
}