import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/dash_widgets.dart';
import '../../../settings/domain/entities/work_schedule_config.dart';
import '../../domain/entities/day_attendance.dart';
import '../../domain/entities/week_attendance.dart';

class EmployeeWeekDetailSheet {
  static void show(BuildContext context, WeekAttendance week, WorkScheduleConfig config) {
    showDialog(
      context: context,
      builder: (_) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 660, maxHeight: 540),
        style: const ContentDialogThemeData(
          decoration: BoxDecoration(
            color: ShadNeutral.card,
            borderRadius: BorderRadius.all(Radius.circular(ShadNeutral.radiusXl)),
            border: Border.fromBorderSide(BorderSide(color: ShadNeutral.border)),
          ),
          titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 0),
          bodyPadding: EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: EdgeInsets.fromLTRB(24, 0, 24, 20),
        ),
        title: _DialogHeader(week: week),
        content: _DialogBody(week: week, config: config),
        actions: [
          ShadSecondaryButton(
            label: 'Cerrar',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _DialogHeader extends StatelessWidget {
  final WeekAttendance week;
  const _DialogHeader({required this.week});

  @override
  Widget build(BuildContext context) {
    final initials = week.userName.trim().split(' ')
        .take(2).map((w) => w[0].toUpperCase()).join();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        // Avatar
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: ShadNeutral.muted,
            borderRadius: BorderRadius.circular(ShadNeutral.radius),
            border: Border.all(color: ShadNeutral.border),
          ),
          child: Center(child: Text(initials,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: ShadNeutral.foreground))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, children: [
          Text(week.userName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                color: ShadNeutral.foreground)),
          Text('${week.completeDays} / ${week.expectedWorkDays} días completos',
            style: const TextStyle(fontSize: 12, color: ShadNeutral.mutedFg)),
        ])),
        // Badges
        ShadBadge(
          label: week.qualifiesForBonus ? 'Bono ✓' : 'Sin bono',
          variant: week.qualifiesForBonus ? ShadBadgeVariant.success : ShadBadgeVariant.destructive,
          icon: week.qualifiesForBonus ? LucideIcons.award : LucideIcons.circleX,
        ),
        if (week.totalOvertimeMinutes > 0) ...[
          const SizedBox(width: 6),
          ShadBadge(
            label: '+${week.overtimeFormatted}',
            variant: ShadBadgeVariant.overtime,
            icon: LucideIcons.clock,
          ),
        ],
      ]),
      const SizedBox(height: 16),
      const ShadDivider(),
    ]);
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _DialogBody extends StatelessWidget {
  final WeekAttendance week;
  final WorkScheduleConfig config;
  const _DialogBody({required this.week, required this.config});

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final timeFmt  = DateFormat('HH:mm');
    final dayFmt   = DateFormat('EEE d MMM', 'es_MX');
    final workDays = week.days.where((d) => d.status != DayStatus.nonWorkday).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Horario info
      Row(children: [
        const Icon(LucideIcons.clock4, size: 12, color: ShadNeutral.mutedFg),
        const SizedBox(width: 6),
        Text(
          'Horario: ${_fmt(config.workStartTime)} – ${_fmt(config.workEndTime)}'
          '  ·  Gracia: ${config.graceMinutes}min entrada / ${config.exitGraceMinutes}min salida',
          style: const TextStyle(fontSize: 11, color: ShadNeutral.mutedFg),
        ),
      ]),
      const SizedBox(height: 14),

      // Tabla
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: ShadNeutral.border),
          borderRadius: BorderRadius.circular(ShadNeutral.radius),
        ),
        child: Column(children: [
          // Cabecera
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: ShadNeutral.muted,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ShadNeutral.radius),
                topRight: Radius.circular(ShadNeutral.radius),
              ),
            ),
            child: Row(children: [
              const SizedBox(width: 26),
              const SizedBox(width: 10),
              Expanded(flex: 3, child: _th('Día')),
              Expanded(flex: 2, child: _th('Entrada', center: true)),
              Expanded(flex: 2, child: _th('Salida',  center: true)),
              Expanded(flex: 2, child: _th('Extra',   center: true)),
              Expanded(flex: 2, child: _th('Estado',  right: true)),
            ]),
          ),
          // Filas
          ...workDays.asMap().entries.map((e) => _DayRow(
            day: e.value,
            dayFmt: dayFmt,
            timeFmt: timeFmt,
            isLast: e.key == workDays.length - 1,
          )),
        ]),
      ),
    ]);
  }

  Widget _th(String t, {bool center = false, bool right = false}) => Text(t,
    textAlign: center ? TextAlign.center : right ? TextAlign.right : TextAlign.left,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
        color: ShadNeutral.mutedFg, letterSpacing: 0.2));
}

// ── Fila de día ────────────────────────────────────────────────────────────────
class _DayRow extends StatelessWidget {
  final DayAttendance day;
  final DateFormat dayFmt;
  final DateFormat timeFmt;
  final bool isLast;
  const _DayRow({required this.day, required this.dayFmt,
      required this.timeFmt, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final (iconData, iconColor, badgeLabel, badgeVariant) = _meta();

    final rowBg = switch (day.status) {
      DayStatus.absent => ShadNeutral.destructiveMuted.withOpacity(0.3),
      DayStatus.missingEntry || DayStatus.missingExit => ShadNeutral.warningMuted.withOpacity(0.3),
      DayStatus.complete when !day.isPunctualEntry || !day.isPunctualExit =>
        ShadNeutral.warningMuted.withOpacity(0.15),
      _ => Colors.transparent,
    };

    final radius = isLast
        ? const BorderRadius.only(
            bottomLeft: Radius.circular(ShadNeutral.radius),
            bottomRight: Radius.circular(ShadNeutral.radius))
        : BorderRadius.zero;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: rowBg, borderRadius: radius,
        border: isLast ? null : const Border(
            bottom: BorderSide(color: ShadNeutral.border, width: 0.5)),
      ),
      child: Row(children: [
        Icon(iconData, size: 14, color: iconColor),
        const SizedBox(width: 10),
        Expanded(flex: 3, child: Text(
          _cap(dayFmt.format(day.date)),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
              color: ShadNeutral.foreground))),
        Expanded(flex: 2, child: _TimeVal(
          time: day.entryTime != null ? timeFmt.format(day.entryTime!) : '—',
          ok: day.isPunctualEntry, hasTime: day.entryTime != null)),
        Expanded(flex: 2, child: _TimeVal(
          time: day.exitTime != null ? timeFmt.format(day.exitTime!) : '—',
          ok: day.isPunctualExit, hasTime: day.exitTime != null)),
        Expanded(flex: 2, child: day.overtimeMinutes > 0
          ? Text('+${day.overtimeMinutes}m', textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                  color: ShadNeutral.overtime))
          : const Text('—', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: ShadNeutral.fgTertiary))),
        Expanded(flex: 2, child: Align(alignment: Alignment.centerRight,
          child: ShadBadge(label: badgeLabel, variant: badgeVariant, sm: true))),
      ]),
    );
  }

  (IconData, Color, String, ShadBadgeVariant) _meta() => switch (day.status) {
    DayStatus.complete when day.isPunctualEntry && day.isPunctualExit =>
      (LucideIcons.circleCheck, ShadNeutral.success, 'OK', ShadBadgeVariant.success),
    DayStatus.complete when !day.isPunctualEntry && !day.isPunctualExit =>
      (LucideIcons.circleAlert, ShadNeutral.warning, 'Tardanza+salida', ShadBadgeVariant.warning),
    DayStatus.complete when !day.isPunctualEntry =>
      (LucideIcons.circleAlert, ShadNeutral.warning, 'Tardanza', ShadBadgeVariant.warning),
    DayStatus.complete =>
      (LucideIcons.circleAlert, ShadNeutral.warning, 'Salida early', ShadBadgeVariant.warning),
    DayStatus.missingEntry =>
      (LucideIcons.circleMinus, ShadNeutral.warning, 'Sin entrada', ShadBadgeVariant.warning),
    DayStatus.missingExit =>
      (LucideIcons.circleMinus, ShadNeutral.warning, 'Sin salida', ShadBadgeVariant.warning),
    DayStatus.absent =>
      (LucideIcons.circleX, ShadNeutral.destructive, 'Ausente', ShadBadgeVariant.destructive),
    _ => (LucideIcons.circle, ShadNeutral.fgTertiary, 'Pendiente', ShadBadgeVariant.neutral),
  };

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _TimeVal extends StatelessWidget {
  final String time;
  final bool ok;
  final bool hasTime;
  const _TimeVal({required this.time, required this.ok, required this.hasTime});

  @override
  Widget build(BuildContext context) {
    final color = !hasTime
        ? ShadNeutral.fgTertiary
        : ok ? ShadNeutral.foreground : ShadNeutral.warning;
    return Text(time, textAlign: TextAlign.center,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color,
          fontFeatures: const [FontFeature.tabularFigures()]));
  }
}
