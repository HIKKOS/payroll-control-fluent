import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/saved_session.dart';
import '../repositories/session_repository.dart';

/// Resultado sellado del arranque. Cada rama lleva exactamente los datos
/// que la UI necesita — nada más, nada menos.
sealed class StartupResult {
  const StartupResult();
}

/// Sesión restaurada (fresca o re-autenticada silenciosamente).
/// → Ir al shell directamente, sin pasar por el login.
final class StartupOnline extends StartupResult {
  final SavedSession session;
  const StartupOnline(this.session);
}

/// El dispositivo no responde. Hay datos locales en Drift.
/// → Shell en modo offline (solo lectura de datos locales).
final class StartupOffline extends StartupResult {
  final SavedSession session; // todavía útil para mostrar host, etc.
  const StartupOffline(this.session);
}

/// Sin sesión guardada, o credenciales incorrectas (cambió contraseña).
/// → Pantalla de login.
final class StartupNeedsLogin extends StartupResult {
  const StartupNeedsLogin();
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Algoritmo:
///
/// 1. ¿Hay sesión guardada?           NO  → NeedsLogin
/// 2. ¿Tiene credenciales válidas?    NO  → NeedsLogin
/// 3. Llamar restoreSession()
///    right(session)               → Online
///    left(NetworkFailure)         → Offline
///    left(AuthFailure)            → NeedsLogin  (credenciales cambiadas)
///    left(otro)                   → NeedsLogin  (seguro)
class AppStartupUseCase {
  final SessionRepository _repo;
  const AppStartupUseCase(this._repo);

  Future<StartupResult> call() async {
    try {
      // 1 + 2 — Cargar sesión guardada
      final savedResult = await _repo.getSavedSession();
      final session = savedResult.fold((_) => null, (s) => s);

      if (session == null || !session.hasCredentials) {
        return const StartupNeedsLogin();
      }

      // 3 — Verificar red y restaurar sesión
      final restoreResult = await _repo.restoreSession(session);

      return restoreResult.fold(
        (failure) => switch (failure) {
          NetworkFailure() => StartupOffline(session),
          _                => const StartupNeedsLogin(),
        },
        (updatedSession) => StartupOnline(updatedSession),
      );
    } catch (e) {
      // Ante cualquier excepción no manejada, pedimos login limpio
      return const StartupNeedsLogin();
    }
  }
}
