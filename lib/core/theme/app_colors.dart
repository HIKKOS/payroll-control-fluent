import 'package:fluent_ui/fluent_ui.dart';

/// ── AppColors ──────────────────────────────────────────────────────────────
/// ThemeExtension que expone los tokens de color de shadcn/ui Neutral,
/// tanto para el modo oscuro como el claro.
///
/// Acceso en cualquier widget:
///   final c = context.colors;
///   Container(color: c.card, ...)
///
/// Los radios y box-shadows también viven aquí porque cambian entre temas.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  // ── Superficie ─────────────────────────────────────────────────────────────
  final Color background;
  final Color card;
  final Color cardElevated;   // card en hover / elevado
  final Color sidebar;
  final Color popover;

  // ── Bordes ─────────────────────────────────────────────────────────────────
  final Color border;
  final Color ring;           // focus ring

  // ── Texto ──────────────────────────────────────────────────────────────────
  final Color foreground;
  final Color fgSecondary;
  final Color fgTertiary;
  final Color mutedFg;        // alias semántico de fgSecondary

  // ── Controles ──────────────────────────────────────────────────────────────
  final Color muted;          // fondo de inputs, hover de rows
  final Color primary;        // bg de botón primario
  final Color primaryFg;      // texto sobre botón primario
  final Color secondary;      // bg de botón secondary
  final Color secondaryFg;
  final Color accent;
  final Color accentFg;
  final Color input;

  // ── Semánticos de estado ───────────────────────────────────────────────────
  final Color success;
  final Color successFg;
  final Color successMuted;
  final Color successBorder;

  final Color warning;
  final Color warningFg;
  final Color warningMuted;
  final Color warningBorder;

  final Color destructive;
  final Color destructiveFg;
  final Color destructiveMuted;
  final Color destructiveBorder;

  final Color overtime;
  final Color overtimeFg;
  final Color overtimeMuted;
  final Color overtimeBorder;

  // ── Geometría (misma en ambos temas) ──────────────────────────────────────
  static const double radius   = 8.0;
  static const double radiusSm = 6.0;
  static const double radiusLg = 10.0;
  static const double radiusXl = 12.0;

  // ── Sombras ────────────────────────────────────────────────────────────────
  final BoxShadow shadow;
  final BoxShadow shadowMd;

  const AppColors({
    required this.background,
    required this.card,
    required this.cardElevated,
    required this.sidebar,
    required this.popover,
    required this.border,
    required this.ring,
    required this.foreground,
    required this.fgSecondary,
    required this.fgTertiary,
    required this.mutedFg,
    required this.muted,
    required this.primary,
    required this.primaryFg,
    required this.secondary,
    required this.secondaryFg,
    required this.accent,
    required this.accentFg,
    required this.input,
    required this.success,
    required this.successFg,
    required this.successMuted,
    required this.successBorder,
    required this.warning,
    required this.warningFg,
    required this.warningMuted,
    required this.warningBorder,
    required this.destructive,
    required this.destructiveFg,
    required this.destructiveMuted,
    required this.destructiveBorder,
    required this.overtime,
    required this.overtimeFg,
    required this.overtimeMuted,
    required this.overtimeBorder,
    required this.shadow,
    required this.shadowMd,
  });

  // ── ThemeExtension API ────────────────────────────────────────────────────

  @override
  AppColors copyWith({
    Color? background, Color? card, Color? cardElevated, Color? sidebar,
    Color? popover, Color? border, Color? ring, Color? foreground,
    Color? fgSecondary, Color? fgTertiary, Color? mutedFg, Color? muted,
    Color? primary, Color? primaryFg, Color? secondary, Color? secondaryFg,
    Color? accent, Color? accentFg, Color? input,
    Color? success, Color? successFg, Color? successMuted, Color? successBorder,
    Color? warning, Color? warningFg, Color? warningMuted, Color? warningBorder,
    Color? destructive, Color? destructiveFg, Color? destructiveMuted, Color? destructiveBorder,
    Color? overtime, Color? overtimeFg, Color? overtimeMuted, Color? overtimeBorder,
    BoxShadow? shadow, BoxShadow? shadowMd,
  }) => AppColors(
    background:        background        ?? this.background,
    card:              card              ?? this.card,
    cardElevated:      cardElevated      ?? this.cardElevated,
    sidebar:           sidebar           ?? this.sidebar,
    popover:           popover           ?? this.popover,
    border:            border            ?? this.border,
    ring:              ring              ?? this.ring,
    foreground:        foreground        ?? this.foreground,
    fgSecondary:       fgSecondary       ?? this.fgSecondary,
    fgTertiary:        fgTertiary        ?? this.fgTertiary,
    mutedFg:           mutedFg           ?? this.mutedFg,
    muted:             muted             ?? this.muted,
    primary:           primary           ?? this.primary,
    primaryFg:         primaryFg         ?? this.primaryFg,
    secondary:         secondary         ?? this.secondary,
    secondaryFg:       secondaryFg       ?? this.secondaryFg,
    accent:            accent            ?? this.accent,
    accentFg:          accentFg          ?? this.accentFg,
    input:             input             ?? this.input,
    success:           success           ?? this.success,
    successFg:         successFg         ?? this.successFg,
    successMuted:      successMuted      ?? this.successMuted,
    successBorder:     successBorder     ?? this.successBorder,
    warning:           warning           ?? this.warning,
    warningFg:         warningFg         ?? this.warningFg,
    warningMuted:      warningMuted      ?? this.warningMuted,
    warningBorder:     warningBorder     ?? this.warningBorder,
    destructive:       destructive       ?? this.destructive,
    destructiveFg:     destructiveFg     ?? this.destructiveFg,
    destructiveMuted:  destructiveMuted  ?? this.destructiveMuted,
    destructiveBorder: destructiveBorder ?? this.destructiveBorder,
    overtime:          overtime          ?? this.overtime,
    overtimeFg:        overtimeFg        ?? this.overtimeFg,
    overtimeMuted:     overtimeMuted     ?? this.overtimeMuted,
    overtimeBorder:    overtimeBorder    ?? this.overtimeBorder,
    shadow:            shadow            ?? this.shadow,
    shadowMd:          shadowMd          ?? this.shadowMd,
  );

  /// Interpolación para las animaciones de cambio de tema.
  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    BoxShadow s(BoxShadow a, BoxShadow b) => BoxShadow.lerp(a, b, t)!;
    return AppColors(
      background:        c(background,        other.background),
      card:              c(card,              other.card),
      cardElevated:      c(cardElevated,      other.cardElevated),
      sidebar:           c(sidebar,           other.sidebar),
      popover:           c(popover,           other.popover),
      border:            c(border,            other.border),
      ring:              c(ring,              other.ring),
      foreground:        c(foreground,        other.foreground),
      fgSecondary:       c(fgSecondary,       other.fgSecondary),
      fgTertiary:        c(fgTertiary,        other.fgTertiary),
      mutedFg:           c(mutedFg,           other.mutedFg),
      muted:             c(muted,             other.muted),
      primary:           c(primary,           other.primary),
      primaryFg:         c(primaryFg,         other.primaryFg),
      secondary:         c(secondary,         other.secondary),
      secondaryFg:       c(secondaryFg,       other.secondaryFg),
      accent:            c(accent,            other.accent),
      accentFg:          c(accentFg,          other.accentFg),
      input:             c(input,             other.input),
      success:           c(success,           other.success),
      successFg:         c(successFg,         other.successFg),
      successMuted:      c(successMuted,      other.successMuted),
      successBorder:     c(successBorder,     other.successBorder),
      warning:           c(warning,           other.warning),
      warningFg:         c(warningFg,         other.warningFg),
      warningMuted:      c(warningMuted,      other.warningMuted),
      warningBorder:     c(warningBorder,     other.warningBorder),
      destructive:       c(destructive,       other.destructive),
      destructiveFg:     c(destructiveFg,     other.destructiveFg),
      destructiveMuted:  c(destructiveMuted,  other.destructiveMuted),
      destructiveBorder: c(destructiveBorder, other.destructiveBorder),
      overtime:          c(overtime,          other.overtime),
      overtimeFg:        c(overtimeFg,        other.overtimeFg),
      overtimeMuted:     c(overtimeMuted,     other.overtimeMuted),
      overtimeBorder:    c(overtimeBorder,    other.overtimeBorder),
      shadow:            s(shadow,            other.shadow),
      shadowMd:          s(shadowMd,          other.shadowMd),
    );
  }
}

// ── Instancias concretas ───────────────────────────────────────────────────────

final appColorsDark = AppColors(
  // Superficie
  background:   const Color(0xFF0A0A0A),
  card:         const Color(0xFF171717),
  cardElevated: const Color(0xFF1C1C1C),
  sidebar:      const Color(0xFF171717),
  popover:      const Color(0xFF171717),
  // Bordes
  border:       const Color(0xFF262626),
  ring:         const Color(0xFFA3A3A3),
  // Texto
  foreground:   const Color(0xFFFAFAFA),
  fgSecondary:  const Color(0xFFA3A3A3),
  fgTertiary:   const Color(0xFF525252),
  mutedFg:      const Color(0xFFA3A3A3),
  // Controles
  muted:        const Color(0xFF262626),
  primary:      const Color(0xFFFAFAFA),
  primaryFg:    const Color(0xFF171717),
  secondary:    const Color(0xFF262626),
  secondaryFg:  const Color(0xFFFAFAFA),
  accent:       const Color(0xFF262626),
  accentFg:     const Color(0xFFFAFAFA),
  input:        const Color(0xFF262626),
  // Success
  success:       const Color(0xFF4ADE80),
  successFg:     const Color(0xFF052E16),
  successMuted:  const Color(0xFF14532D),
  successBorder: const Color(0xFF166534),
  // Warning
  warning:       const Color(0xFFFBBF24),
  warningFg:     const Color(0xFF451A03),
  warningMuted:  const Color(0xFF431407),
  warningBorder: const Color(0xFF92400E),
  // Destructive
  destructive:       const Color(0xFFEF4444),
  destructiveFg:     const Color(0xFFFAFAFA),
  destructiveMuted:  const Color(0xFF450A0A),
  destructiveBorder: const Color(0xFF7F1D1D),
  // Overtime
  overtime:       const Color(0xFFA78BFA),
  overtimeFg:     const Color(0xFF2E1065),
  overtimeMuted:  const Color(0xFF2E1065),
  overtimeBorder: const Color(0xFF4C1D95),
  // Sombras
  shadow:   BoxShadow(color: const Color(0xFF000000).withOpacity(0.30), blurRadius: 8,  offset: const Offset(0, 2)),
  shadowMd: BoxShadow(color: const Color(0xFF000000).withOpacity(0.40), blurRadius: 16, offset: const Offset(0, 4)),
);

final appColorsLight = AppColors(
  // Superficie
  background:   const Color(0xFFFFFFFF),
  card:         const Color(0xFFFFFFFF),
  cardElevated: const Color(0xFFF9F9F9),
  sidebar:      const Color(0xFFFAFAFA),
  popover:      const Color(0xFFFFFFFF),
  // Bordes
  border:       const Color(0xFFE5E5E5),
  ring:         const Color(0xFF0A0A0A),
  // Texto
  foreground:   const Color(0xFF0A0A0A),
  fgSecondary:  const Color(0xFF525252),
  fgTertiary:   const Color(0xFFA3A3A3),
  mutedFg:      const Color(0xFF737373),
  // Controles
  muted:        const Color(0xFFF5F5F5),
  primary:      const Color(0xFF171717),
  primaryFg:    const Color(0xFFFAFAFA),
  secondary:    const Color(0xFFF5F5F5),
  secondaryFg:  const Color(0xFF171717),
  accent:       const Color(0xFFF5F5F5),
  accentFg:     const Color(0xFF171717),
  input:        const Color(0xFFE5E5E5),
  // Success
  success:       const Color(0xFF16A34A),
  successFg:     const Color(0xFFF0FDF4),
  successMuted:  const Color(0xFFDCFCE7),
  successBorder: const Color(0xFFBBF7D0),
  // Warning
  warning:       const Color(0xFFD97706),
  warningFg:     const Color(0xFFFFFBEB),
  warningMuted:  const Color(0xFFFEF3C7),
  warningBorder: const Color(0xFFFDE68A),
  // Destructive
  destructive:       const Color(0xFFDC2626),
  destructiveFg:     const Color(0xFFFFF1F2),
  destructiveMuted:  const Color(0xFFFFE4E6),
  destructiveBorder: const Color(0xFFFECACA),
  // Overtime
  overtime:       const Color(0xFF7C3AED),
  overtimeFg:     const Color(0xFFF5F3FF),
  overtimeMuted:  const Color(0xFFEDE9FE),
  overtimeBorder: const Color(0xFFDDD6FE),
  // Sombras
  shadow:   BoxShadow(color: const Color(0xFF000000).withOpacity(0.06), blurRadius: 8,  offset: const Offset(0, 1)),
  shadowMd: BoxShadow(color: const Color(0xFF000000).withOpacity(0.10), blurRadius: 16, offset: const Offset(0, 4)),
);

// ── Extension helper ───────────────────────────────────────────────────────────
/// Acceso rápido desde cualquier widget:
///   final c = context.colors;
extension AppColorsX on BuildContext {
  AppColors get colors =>
      FluentTheme.of(this).extension<AppColors>() ?? appColorsDark;
}