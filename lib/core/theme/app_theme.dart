import 'package:fluent_ui/fluent_ui.dart';

/// Tokens de diseño de la aplicación.
/// Paleta: grafito oscuro profundo + cian eléctrico + ámbar para alertas.
/// Inspiración: dashboards industriales de control (no SaaS genérico).
class AppColors {
  AppColors._();

  // ── Fondos ────────────────────────────────────────────────────────────────
  static const bg0 = Color(0xFF0D0F14);   // fondo raíz — casi negro azulado
  static const bg1 = Color(0xFF131720);   // panel lateral
  static const bg2 = Color(0xFF1A1F2E);   // cards / superficies
  static const bg3 = Color(0xFF222840);   // hover / elevado
  static const bgBorder = Color(0xFF2A3150); // bordes sutiles

  // ── Acento principal: cian eléctrico ──────────────────────────────────────
  static const cyan = Color(0xFF00D4FF);
  static const cyanDim = Color(0xFF0096B8);
  static const cyanGlow = Color(0x2200D4FF);

  // ── Semánticos ────────────────────────────────────────────────────────────
  static const success = Color(0xFF00E5A0);   // bono ✓
  static const successDim = Color(0xFF00B87A);
  static const successBg = Color(0x1500E5A0);

  static const warning = Color(0xFFFFB830);   // tardanza / parcial
  static const warningDim = Color(0xFFCC8F00);
  static const warningBg = Color(0x15FFB830);

  static const danger = Color(0xFFFF4D6A);    // ausente / sin bono
  static const dangerDim = Color(0xFFCC2244);
  static const dangerBg = Color(0x15FF4D6A);

  static const overtime = Color(0xFFBF7FFF);  // horas extra — violeta suave
  static const overtimeBg = Color(0x15BF7FFF);

  // ── Texto ─────────────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFEDF0FA);
  static const textSecondary = Color(0xFF8892B0);
  static const textTertiary  = Color(0xFF4A5580);
  static const textDisabled  = Color(0xFF2E3755);
}

/// Construye el [FluentThemeData] oscuro personalizado.
FluentThemeData buildAppTheme() {
  return FluentThemeData(
    brightness: Brightness.dark,
    accentColor:   AccentColor.swatch(const {
      'darkest':  Color(0xFF005F7A),
      'darker':   Color(0xFF007A9E),
      'dark':     Color(0xFF0096B8),
      'normal':   AppColors.cyan,
      'light':   Color(0xFF33DDFF),
      'lighter':  Color(0xFF80ECFF),
      'lightest':  Color(0xFFBFF5FF),
    }),
    scaffoldBackgroundColor: AppColors.bg0,
    cardColor: AppColors.bg2,
    micaBackgroundColor: AppColors.bg1,
    navigationPaneTheme: const NavigationPaneThemeData(
      backgroundColor: AppColors.bg1,
      highlightColor: AppColors.cyan,
    ),
    /*typography: Typography(

      const TextStyle(
        fontFamily: 'SF Pro Display',   // macOS nativo; Windows cae en Segoe
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
    ),*/
  );
}