import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:nomina_control/core/theme/app_colors.dart';
import 'package:nomina_control/core/theme/cubit/theme_cubit.dart';

// ─── ShadCard ────────────────────────────────────────────────────────────────
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
    return _ShadCardInner(
      padding: padding,
      color: color,
      highlighted: highlighted,
      hoverable: hoverable,
      onTap: onTap,
      child: child,
    );
  }
}

class _ShadCardInner extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool highlighted;
  final bool hoverable;
  final VoidCallback? onTap;

  const _ShadCardInner({
    required this.child,
    required this.padding,
    this.color,
    required this.highlighted,
    required this.hoverable,
    this.onTap,
  });

  @override
  State<_ShadCardInner> createState() => _ShadCardInnerState();
}

class _ShadCardInnerState extends State<_ShadCardInner> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final base = widget.color ?? c.card;
    final bg = _hovered && widget.hoverable ? c.cardElevated : base;
    final borderColor = widget.highlighted
        ? c.ring
        : (_hovered && widget.hoverable ? c.border : c.border);

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
            borderRadius: BorderRadius.circular(AppColors.radius),
            border: Border.all(color: borderColor),
            boxShadow: [c.shadow],
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
    final c = context.colors;
    final (fg, bg, bdr) = switch (variant) {
      ShadBadgeVariant.success => (c.success, c.successMuted, c.successBorder),
      ShadBadgeVariant.warning => (c.warning, c.warningMuted, c.warningBorder),
      ShadBadgeVariant.destructive => (
          c.destructive,
          c.destructiveMuted,
          c.destructiveBorder
        ),
      ShadBadgeVariant.overtime => (
          c.overtime,
          c.overtimeMuted,
          c.overtimeBorder
        ),
      ShadBadgeVariant.neutral => (c.mutedFg, c.muted, c.border),
    };

    final vPad = sm ? 2.0 : 4.0;
    final hPad = sm ? 7.0 : 10.0;
    final fs = sm ? 10.0 : 11.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(color: bdr),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: sm ? 10 : 12, color: fg),
          SizedBox(width: sm ? 3 : 5),
        ],
        Text(label,
            style: TextStyle(
              fontSize: fs,
              fontWeight: FontWeight.w500,
              color: fg,
              letterSpacing: 0.1,
            )),
      ]),
    );
  }
}

// ─── ShadLabel ───────────────────────────────────────────────────────────────
class ShadLabel extends StatelessWidget {
  final String text;

  const ShadLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: context.colors.fgSecondary,
          letterSpacing: 0.1,
        ),
      );
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
    final c = context.colors;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: c.foreground,
                letterSpacing: -0.4,
              )),
          if (description != null) ...[
            const SizedBox(height: 3),
            Text(description!,
                style: TextStyle(
                  fontSize: 13,
                  color: c.mutedFg,
                  fontWeight: FontWeight.w400,
                )),
          ],
        ],
      )),
      if (trailing != null) ...[const SizedBox(width: 16), trailing!],
    ]);
  }
}

// ─── ShadStatCard ────────────────────────────────────────────────────────────
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
    final c = context.colors;
    return ShadCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppColors.radiusSm),
            border: Border.all(color: accentColor.withOpacity(0.2)),
          ),
          child: Icon(icon, size: 16, color: accentColor),
        ),
        const SizedBox(width: 12),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                    letterSpacing: -0.5,
                  )),
              Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    color: c.mutedFg,
                    fontWeight: FontWeight.w400,
                  )),
            ]),
      ]),
    );
  }
}

// ─── ShadInputField ──────────────────────────────────────────────────────────
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
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                child: Icon(prefixIcon, size: 14, color: c.mutedFg),
              )
            : null,
        suffix: suffix,
        style: TextStyle(fontSize: 13, color: c.foreground),
        placeholderStyle: TextStyle(fontSize: 13, color: c.fgTertiary),
        decoration: WidgetStatePropertyAll(BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(AppColors.radius),
          border: Border.all(
            color: error != null ? c.destructive : c.border,
          ),
        )),
      ),
      if (error != null) ...[
        const SizedBox(height: 5),
        Text(error!, style: TextStyle(fontSize: 11, color: c.destructive)),
      ],
    ]);
  }
}

// ─── ShadDivider ─────────────────────────────────────────────────────────────
class ShadDivider extends StatelessWidget {
  final double? indent;

  const ShadDivider({super.key, this.indent});

  @override
  Widget build(BuildContext context) => Divider(
          style: DividerThemeData(
        decoration: BoxDecoration(
          color: context.colors.border,
        ),
        thickness: 1,
      ));
}

// ─── ShadPrimaryButton ───────────────────────────────────────────────────────
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
    final c = context.colors;
    return SizedBox(
      height: height,
      child: FilledButton(
        style: ButtonStyle(
          backgroundColor:
              WidgetStateProperty.resolveWith((s) => s.isDisabled || s.isPressed
                  ? c.primary.withOpacity(0.7)
                  : s.isHovered
                      ? c.primary.withOpacity(0.9)
                      : c.primary),
          foregroundColor: WidgetStateProperty.all(c.primaryFg),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radius),
          )),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? SizedBox(
                width: 14,
                height: 14,
                child: ProgressRing(strokeWidth: 2, activeColor: c.primaryFg))
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    if (icon != null) ...[
                      Icon(icon, size: 14, color: c.primaryFg),
                      const SizedBox(width: 7),
                    ],
                    Text(label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: c.primaryFg,
                        )),
                  ]),
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
    final c = context.colors;
    return SizedBox(
      height: 36,
      child: Button(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
              (s) => s.isHovered ? c.accent : c.secondary),


          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            side:
            BorderSide(color: c.border),
            borderRadius: BorderRadius.circular(AppColors.radius),
          )),
        ),
        onPressed: onPressed,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: c.mutedFg),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: c.foreground,
              )),
        ]),
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
      icon: Icon(icon, size: 15, color: color ?? context.colors.mutedFg),
      onPressed: onPressed,
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }
}

// ─── ThemeToggleButton ───────────────────────────────────────────────────────
/// Botón de toggle de tema listo para usar en cualquier AppBar o Settings.
/// Solo necesita acceso al ThemeCubit vía context.read.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: isDark ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro',
      child: IconButton(
        icon: Icon(
          isDark ? LucideIcons.sun : LucideIcons.moon,
          size: 15,
          color: c.mutedFg,
        ),
        onPressed: () {
          // Lee el cubit desde el contexto — no importa dónde esté el widget
          context.read<ThemeCubit>().toggle();
        },
      ),
    );
  }
}
