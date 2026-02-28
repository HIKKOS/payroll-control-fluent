import 'package:fluent_ui/fluent_ui.dart';
import 'package:nomina_control/core/theme/app_theme.dart';


// ── DashCard ─────────────────────────────────────────────────────────────────
/// Contenedor base de superficies elevadas con borde sutil y esquinas suaves.
/// Reemplaza al Card de Material en todo el proyecto.
class DashCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double borderRadius;
  final bool highlighted; // borde cian cuando está seleccionado

  const DashCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.borderRadius = 10,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.bg2,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: highlighted ? AppColors.cyan : AppColors.bgBorder,
          width: highlighted ? 1.5 : 1,
        ),
        boxShadow: highlighted
            ? [BoxShadow(color: AppColors.cyanGlow, blurRadius: 12, spreadRadius: 1)]
            : const [],
      ),
      child: child,
    );
  }
}

// ── StatusBadge ───────────────────────────────────────────────────────────────
enum BadgeVariant { success, warning, danger, neutral, overtime }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final IconData? icon;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.label,
    required this.variant,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (variant) {
      BadgeVariant.success  => (AppColors.success,  AppColors.successBg),
      BadgeVariant.warning  => (AppColors.warning,  AppColors.warningBg),
      BadgeVariant.danger   => (AppColors.danger,   AppColors.dangerBg),
      BadgeVariant.overtime => (AppColors.overtime, AppColors.overtimeBg),
      BadgeVariant.neutral  => (AppColors.textSecondary, AppColors.bg3),
    };

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 11 : 13, color: fg),
            SizedBox(width: compact ? 4 : 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── SectionHeader ─────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ── DotIndicator ─────────────────────────────────────────────────────────────
/// Punto de estado pulsante (para días en el mini-calendario).
class DotIndicator extends StatelessWidget {
  final Color color;
  final double size;
  final bool pulse;

  const DotIndicator({
    super.key,
    required this.color,
    this.size = 8,
    this.pulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: pulse
            ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6, spreadRadius: 1)]
            : null,
      ),
    );
  }
}

// ── StatTile ─────────────────────────────────────────────────────────────────
/// Pequeño tile de métrica para el header del dashboard.
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;
  final IconData icon;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DashCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}