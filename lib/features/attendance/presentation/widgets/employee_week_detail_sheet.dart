import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:nomina_control/core/theme/app_colors.dart';
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
        style:   ContentDialogThemeData(
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: const BorderRadius.all(Radius.circular(radiusXl)),
            border: Border.fromBorderSide(BorderSide(color: context.colors.border)),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          bodyPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
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
            color: context.colors.muted,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: context.colors.border),
          ),
          child: Center(child: Text(initials,
            style:   TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: context.colors.foreground))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, children: [
          Text(week.userName,
            style:   TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                color: context.colors.foreground)),
          Text('${week.completeDays} / ${week.expectedWorkDays} días completos',
            style:   TextStyle(fontSize: 12, color: context.colors.mutedFg)),
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
          Icon(LucideIcons.clock4, size: 12, color: context.colors.mutedFg),
        const SizedBox(width: 6),
        Text(
          'Horario: ${_fmt(config.workStartTime)} – ${_fmt(config.workEndTime)}'
          '  ·  Gracia: ${config.graceMinutes}min entrada / ${config.exitGraceMinutes}min salida',
          style:   TextStyle(fontSize: 11, color: context.colors.mutedFg),
        ),
      ]),
      const SizedBox(height: 14),

      // Tabla
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.border),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Column(children: [
          // Cabecera
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration:   BoxDecoration(
              color: context.colors.muted,
              borderRadius:const  BorderRadius.only(
                topLeft: Radius.circular(radius),
                topRight: Radius.circular(radius),
              ),
            ),
            child: const Row(children: [
                SizedBox(width: 26),
                SizedBox(width: 10),
              Expanded(flex: 3, child: TH(text :'Día')),
              Expanded(flex: 2, child: TH(text :'Entrada', center: true)),
              Expanded(flex: 2, child: TH(text :'Salida',  center: true)),
              Expanded(flex: 2, child: TH(text :'Extra',   center: true)),
              Expanded(flex: 2, child: TH(text :'Estado',  right: true)),
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

}

class TH extends StatelessWidget {

  final String text;
  final bool center;
  final bool right;

  const TH({super.key, required this.text,   this.center = false,   this.right = false});
  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: center ? TextAlign.center : right ? TextAlign.right : TextAlign.left,
        style:   TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
            color: context.colors.mutedFg, letterSpacing: 0.2));
  }
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
    final (iconData, iconColor, badgeLabel, badgeVariant) = _meta(context);

    final rowBg = switch (day.status) {
      DayStatus.absent => context.colors.destructiveMuted.withOpacity(0.3),
      DayStatus.missingEntry || DayStatus.missingExit => context.colors.warningMuted.withOpacity(0.3),
      DayStatus.complete when !day.isPunctualEntry || !day.isPunctualExit =>
        context.colors.warningMuted.withOpacity(0.15),
      _ => Colors.transparent,
    };

    final _radius = isLast
        ? const BorderRadius.only(
            bottomLeft: Radius.circular(radius),
            bottomRight: Radius.circular(radius))
        : BorderRadius.zero;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: rowBg, borderRadius: _radius,
        border: isLast ? null :   Border(
            bottom: BorderSide(color: context.colors.border, width: 0.5)),
      ),
      child: Row(children: [
        Icon(iconData, size: 14, color: iconColor),
        const SizedBox(width: 10),
        Expanded(flex: 3, child: Text(
          _cap(dayFmt.format(day.date)),
          style:   TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
              color: context.colors.foreground))),
        Expanded(flex: 2, child: _TimeVal(
          time: day.entryTime != null ? timeFmt.format(day.entryTime!) : '—',
          ok: day.isPunctualEntry, hasTime: day.entryTime != null)),
        Expanded(flex: 2, child: _TimeVal(
          time: day.exitTime != null ? timeFmt.format(day.exitTime!) : '—',
          ok: day.isPunctualExit, hasTime: day.exitTime != null)),
        Expanded(flex: 2, child: day.overtimeMinutes > 0
          ? Text('+${day.overtimeMinutes}m', textAlign: TextAlign.center,
              style:   TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                  color: context.colors.overtime))
          :   Text('—', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: context.colors.fgTertiary))),
        Expanded(flex: 2, child: Align(alignment: Alignment.centerRight,
          child: ShadBadge(label: badgeLabel, variant: badgeVariant, sm: true))),
      ]),
    );
  }

  (IconData, Color, String, ShadBadgeVariant) _meta(BuildContext context) => switch (day.status) {
    DayStatus.complete when day.isPunctualEntry && day.isPunctualExit =>
      (LucideIcons.circleCheck, context.colors.success, 'OK', ShadBadgeVariant.success),
    DayStatus.complete when !day.isPunctualEntry && !day.isPunctualExit =>
      (LucideIcons.circleAlert, context.colors.warning, 'Tardanza+salida', ShadBadgeVariant.warning),
    DayStatus.complete when !day.isPunctualEntry =>
      (LucideIcons.circleAlert, context.colors.warning, 'Tardanza', ShadBadgeVariant.warning),
    DayStatus.complete =>
      (LucideIcons.circleAlert, context.colors.warning, 'Salida early', ShadBadgeVariant.warning),
    DayStatus.missingEntry =>
      (LucideIcons.circleMinus, context.colors.warning, 'Sin entrada', ShadBadgeVariant.warning),
    DayStatus.missingExit =>
      (LucideIcons.circleMinus, context.colors.warning, 'Sin salida', ShadBadgeVariant.warning),
    DayStatus.absent =>
      (LucideIcons.circleX, context.colors.destructive, 'Ausente', ShadBadgeVariant.destructive),
    _ => (LucideIcons.circle, context.colors.fgTertiary, 'Pendiente', ShadBadgeVariant.neutral),
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
        ? context.colors.fgTertiary
        : ok ? context.colors.foreground : context.colors.warning;
    return Text(time, textAlign: TextAlign.center,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color,
          fontFeatures: const [FontFeature.tabularFigures()]));
  }
}
