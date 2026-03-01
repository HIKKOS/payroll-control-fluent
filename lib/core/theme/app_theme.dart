import 'package:fluent_ui/fluent_ui.dart';

/// ─── shadcn/ui · Neutral · Dark ─────────────────────────────────────────────
///
/// Tokens traducidos 1:1 desde el tema oficial:
///   background  → neutral-950  #0a0a0a
///   card        → neutral-900  #171717   (+1 nivel para distinguir del bg)
///   popover     → neutral-900  #171717
///   border      → neutral-800  #262626
///   input       → neutral-800  #262626
///   muted       → neutral-800  #262626   (fondo de hover/secondary)
///   muted-fg    → neutral-400  #a3a3a3
///   foreground  → neutral-50   #fafafa
///   primary     → neutral-50   #fafafa   (botones primarios: blanco)
///   primary-fg  → neutral-900  #171717   (texto sobre botón primario)
///   secondary   → neutral-800  #262626
///   accent      → neutral-800  #262626
///   destructive → red-500      #ef4444
///   ring        → neutral-400  #a3a3a3
///   radius      → 0.5rem  →  8px
///
/// Semánticos de estado (fuera del sistema shadcn, pero consistentes con él):
///   success     → verde apagado, sin saturación gritona
///   warning     → ámbar apagado
///   info        → neutral puro (no usamos azul)
class ShadNeutral {
  ShadNeutral._();

  // ── Escala neutral ─────────────────────────────────────────────────────────
  static const n50 = Color(0xFFFAFAFA); // foreground / primary
  static const n100 = Color(0xFFF5F5F5);
  static const n200 = Color(0xFFE5E5E5);
  static const n300 = Color(0xFFD4D4D4);
  static const n400 = Color(0xFFA3A3A3); // muted-foreground / ring
  static const n500 = Color(0xFF737373);
  static const n600 = Color(0xFF525252);
  static const n700 = Color(0xFF404040);
  static const n800 = Color(0xFF262626); // border / input / muted / secondary
  static const n900 = Color(0xFF171717); // card / popover / sidebar
  static const n950 = Color(0xFF0A0A0A); // background

  // ── Tokens semánticos ──────────────────────────────────────────────────────
  static const background = n950;
  static const card = n900;
  static const cardElevated = Color(0xFF1C1C1C); // card hover / elevado
  static const popover = n900;
  static const border = n800;
  static const input = n800;
  static const muted = n800;
  static const mutedFg = n400;
  static const foreground = n50;
  static const fgSecondary = n400;
  static const fgTertiary = n600;
  static const primary = n50;
  static const primaryFg = n900;
  static const secondary = n800;
  static const secondaryFg = n50;
  static const accent = n800;
  static const accentFg = n50;
  static const ring = n400;
  static const sidebar = n900;

  // ── Radio de bordes (0.5rem = 8px) ────────────────────────────────────────
  static const double radius = 8.0;
  static const double radiusSm = 6.0;
  static const double radiusLg = 10.0;
  static const double radiusXl = 12.0;

  // ── Sombras ───────────────────────────────────────────────────────────────
  // shadcn usa sombras muy sutiles — casi solo un borde con opacidad
  static final shadow = BoxShadow(
    color: Colors.black.withOpacity(0.3),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
  static final shadowMd = BoxShadow(
    color: Colors.black.withOpacity(0.4),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );

  // ── Estados semánticos (apagados, dentro del sistema neutral) ─────────────
  // Verde apagado — no grita, compatible con el tema monocromático
  static const success = Color(0xFF4ADE80); // green-400
  static const successFg = Color(0xFF052E16); // green-950
  static const successMuted = Color(0xFF14532D); // green-900 — bg de badge
  static const successBorder = Color(0xFF166534); // green-800

  // Ámbar apagado
  static const warning = Color(0xFFFBBF24); // amber-400
  static const warningFg = Color(0xFF451A03);
  static const warningMuted = Color(0xFF431407);
  static const warningBorder = Color(0xFF92400E);

  // Rojo — destructive del sistema shadcn
  static const destructive = Color(0xFFEF4444); // red-500
  static const destructiveFg = n50;
  static const destructiveMuted = Color(0xFF450A0A); // red-950
  static const destructiveBorder = Color(0xFF7F1D1D); // red-900

  // Violeta suave — para overtime, neutral dentro del sistema
  static const overtime = Color(0xFFA78BFA); // violet-400
  static const overtimeMuted = Color(0xFF2E1065); // violet-950
  static const overtimeBorder = Color(0xFF4C1D95);
}

/// Construye el [FluentThemeData] con la paleta Neutral de shadcn.
FluentThemeData buildAppTheme() {
  return FluentThemeData(
    brightness: Brightness.dark,
    accentColor: AccentColor.swatch(const {
      'darkest':   Color(0xFF525252),
      'darker':   Color(0xFF737373),
      'dark': ShadNeutral.n400,
      'normal': ShadNeutral.n200,
      'light': ShadNeutral.n100,
      'lighter': ShadNeutral.n50,
      'lightest': Colors.white,
    }),
    scaffoldBackgroundColor: ShadNeutral.background,
    cardColor: ShadNeutral.card,
    micaBackgroundColor: ShadNeutral.sidebar,
    navigationPaneTheme: const NavigationPaneThemeData(
      backgroundColor: ShadNeutral.sidebar,
      highlightColor: ShadNeutral.foreground,
    ),
    typography: const Typography.raw(
      body: TextStyle(
        fontFamily: 'SF Pro Text',
        color: ShadNeutral.foreground,
        fontSize: 14,
        letterSpacing: -0.1,
      ),
    ),
  );
}
