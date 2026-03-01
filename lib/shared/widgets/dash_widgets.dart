import 'package:fluent_ui/fluent_ui.dart';
import 'package:nomina_control/core/theme/app_theme.dart';

// ─── ShadCard ────────────────────────────────────────────────────────────────
/// Card con exactamente los tokens de shadcn: bg card, border, radius 8px,
/// shadow sutil. Sin gradientes ni colores neón.
class ShadCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool highlighted;
  final bool hoverable;
  final VoidCallback? onTap;

  const ShadCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.highlighted = false,
    this.hoverable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _ShadCardContent(
      padding: padding,
      color: color,
      highlighted: highlighted,
      hoverable: hoverable,
      onTap: onTap,
      child: child,
    );
  }
}

class _ShadCardContent extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool highlighted;
  final bool hoverable;
  final VoidCallback? onTap;

  const _ShadCardContent({
    required this.child,
    required this.padding,
    this.color,
    required this.highlighted,
    required this.hoverable,
    this.onTap,
  });

  @override
  State<_ShadCardContent> createState() => _ShadCardContentState();
}

class _ShadCardContentState extends State<_ShadCardContent> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final base = widget.color ?? ShadNeutral.card;
    final bg = _hovered && widget.hoverable ? ShadNeutral.cardElevated : base;
    final borderColor = widget.highlighted
        ? ShadNeutral.n400
        : (_hovered && widget.hoverable
            ? ShadNeutral.n700
            : ShadNeutral.border);

    return MouseRegion(
      cursor:
          widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) {
        if (widget.hoverable) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (widget.hoverable) setState(() => _hovered = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(ShadNeutral.radius),
            border: Border.all(color: borderColor),
            boxShadow: [ShadNeutral.shadow],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ─── ShadBadge ───────────────────────────────────────────────────────────────
enum ShadBadgeVariant { success, warning, destructive, neutral, overtime }

class ShadBadge extends StatelessWidget {
  final String label;
  final ShadBadgeVariant variant;
  final IconData? icon;
  final bool sm;

  const ShadBadge({
    super.key,
    required this.label,
    required this.variant,
    this.icon,
    this.sm = false,
  });

  @override
  Widget build(BuildContext context) {
    final (fg, bg, bdr) = switch (variant) {
      ShadBadgeVariant.success => (
          ShadNeutral.success,
          ShadNeutral.successMuted,
          ShadNeutral.successBorder
        ),
      ShadBadgeVariant.warning => (
          ShadNeutral.warning,
          ShadNeutral.warningMuted,
          ShadNeutral.warningBorder
        ),
      ShadBadgeVariant.destructive => (
          ShadNeutral.destructive,
          ShadNeutral.destructiveMuted,
          ShadNeutral.destructiveBorder
        ),
      ShadBadgeVariant.overtime => (
          ShadNeutral.overtime,
          ShadNeutral.overtimeMuted,
          ShadNeutral.overtimeBorder
        ),
      ShadBadgeVariant.neutral => (
          ShadNeutral.mutedFg,
          ShadNeutral.muted,
          ShadNeutral.border
        ),
    };

    final vPad = sm ? 2.0 : 4.0;
    final hPad = sm ? 7.0 : 10.0;
    final fs = sm ? 10.0 : 11.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(ShadNeutral.radius),
        border: Border.all(color: bdr),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: sm ? 10 : 12, color: fg),
            SizedBox(width: sm ? 3 : 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fs,
              fontWeight: FontWeight.w500,
              color: fg,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ShadLabel ───────────────────────────────────────────────────────────────
/// Etiqueta de campo estilo shadcn: pequeña, gris media, peso medio.
class ShadLabel extends StatelessWidget {
  final String text;

  const ShadLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: ShadNeutral.fgSecondary,
        letterSpacing: 0.1,
      ),
    );
  }
}

// ─── ShadSectionHeader ───────────────────────────────────────────────────────
class ShadSectionHeader extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? trailing;

  const ShadSectionHeader({
    super.key,
    required this.title,
    this.description,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: ShadNeutral.foreground,
                  letterSpacing: -0.4,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 3),
                Text(
                  description!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ShadNeutral.mutedFg,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 16), trailing!],
      ],
    );
  }
}

// ─── ShadStatCard ────────────────────────────────────────────────────────────
/// Tarjeta de métrica compacta. Sin gradientes — solo tipo, número y label.
class ShadStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const ShadStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ShadNeutral.radiusSm),
              border: Border.all(color: accentColor.withOpacity(0.2)),
            ),
            child: Icon(icon, size: 16, color: accentColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: ShadNeutral.mutedFg,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── ShadInput wrapper ───────────────────────────────────────────────────────
/// Campo de texto estilo shadcn: fondo card, border neutral-800, radius 8px.
class ShadInputField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? error;
  final bool obscure;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const ShadInputField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.prefixIcon,
    this.suffix,
    this.error,
    this.obscure = false,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShadLabel(label),
        const SizedBox(height: 6),
        TextBox(
          controller: controller,
          placeholder: placeholder,
          obscureText: obscure,
          enabled: enabled,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          prefix: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(prefixIcon, size: 14, color: ShadNeutral.mutedFg),
                )
              : null,
          suffix: suffix,
          style: const TextStyle(
            fontSize: 13,
            color: ShadNeutral.foreground,
          ),
          placeholderStyle: const TextStyle(
            fontSize: 13,
            color: ShadNeutral.fgTertiary,
          ),
          decoration: WidgetStatePropertyAll(BoxDecoration(
            color: ShadNeutral.card,
            borderRadius: BorderRadius.circular(ShadNeutral.radius),
            border: Border.all(
              color:
                  error != null ? ShadNeutral.destructive : ShadNeutral.border,
            ),
          )),
        ),
        if (error != null) ...[
          const SizedBox(height: 5),
          Text(
            error!,
            style: const TextStyle(
              fontSize: 11,
              color: ShadNeutral.destructive,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── ShadDivider ─────────────────────────────────────────────────────────────
class ShadDivider extends StatelessWidget {
  final double? indent;

  const ShadDivider({super.key, this.indent});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      style: DividerThemeData(
          thickness: 1,
          decoration: BoxDecoration(
            color: ShadNeutral.border,
          )),
    );
  }
}

// ─── ShadPrimaryButton ───────────────────────────────────────────────────────
/// Botón primario shadcn: fondo blanco (neutral-50), texto negro, radius 8px.
class ShadPrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;

  const ShadPrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.height = 38,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: FilledButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.isDisabled || s.isPressed
                ? ShadNeutral.n200
                : s.isHovered
                    ? ShadNeutral.n100
                    : ShadNeutral.primary,
          ),
          foregroundColor: WidgetStateProperty.all(ShadNeutral.primaryFg),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ShadNeutral.radius)),
          ),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: ProgressRing(
                    strokeWidth: 2, activeColor: ShadNeutral.primaryFg),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 14, color: ShadNeutral.primaryFg),
                    const SizedBox(width: 7),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ShadNeutral.primaryFg,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── ShadSecondaryButton ─────────────────────────────────────────────────────
class ShadSecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  const ShadSecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Button(
        style: ButtonStyle(

          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.isHovered ? ShadNeutral.accent : ShadNeutral.secondary,
          ),

          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(side:const
            BorderSide(color: ShadNeutral.border),
                borderRadius: BorderRadius.circular(ShadNeutral.radius)),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: ShadNeutral.mutedFg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: ShadNeutral.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ShadIconButton ──────────────────────────────────────────────────────────
class ShadIconButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  const ShadIconButton({
    super.key,
    required this.icon,
    this.tooltip,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final btn = IconButton(
      icon: Icon(icon, size: 15, color: color ?? ShadNeutral.mutedFg),
      onPressed: onPressed,
    );
    if (tooltip != null) return Tooltip(message: tooltip!, child: btn);
    return btn;
  }
}
