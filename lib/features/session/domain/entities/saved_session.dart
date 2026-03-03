import 'package:equatable/equatable.dart';

/// Credenciales + timestamp del último login exitoso, guardadas en disco.
/// Permiten saltarse el login si la sesión sigue fresca,
/// o re-autenticar silenciosamente si expiró.
class SavedSession extends Equatable {
  final String host;
  final int    port;
  final String login;
  final String password;
  /// Unix timestamp (segundos) del último login exitoso.
  final int lastLoginAt;

  /// 20 min — margen conservador antes de confirmar que la cookie expiró.
  static const int ttlSeconds = 20 * 60;

  const SavedSession({
    required this.host,
    required this.port,
    required this.login,
    required this.password,
    required this.lastLoginAt,
  });

  bool get isLikelyFresh {
    final elapsed = DateTime.now().millisecondsSinceEpoch ~/ 1000 - lastLoginAt;
    return elapsed < ttlSeconds;
  }

  bool get hasCredentials =>
      host.isNotEmpty && login.isNotEmpty && password.isNotEmpty;

  SavedSession copyWithNow() => SavedSession(
    host: host, port: port, login: login, password: password,
    lastLoginAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
  );

  @override
  List<Object?> get props => [host, port, login, password, lastLoginAt];
}
