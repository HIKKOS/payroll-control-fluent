import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/saved_session.dart';

abstract class SessionRepository {
  Future<Either<Failure, SavedSession?>> getSavedSession();
  Future<Either<Failure, Unit>> saveSession(SavedSession session);
  Future<Either<Failure, Unit>> clearSession();
  Future<Either<Failure, Unit>> touchSession();

  /// Verifica red y estado de sesión. Opciones:
  /// - OK fresca  → right(session) sin re-login
  /// - Expirada   → re-autentica y devuelve right(session actualizada)
  /// - Sin red    → left(NetworkFailure) → la app va a modo offline
  /// - Credenciales wrongas → left(AuthFailure) → forzar login manual
  Future<Either<Failure, SavedSession>> restoreSession(SavedSession session);
}
