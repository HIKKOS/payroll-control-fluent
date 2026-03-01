import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/dash_widgets.dart';
import '../../domain/entities/day_attendance.dart';
import '../../domain/entities/week_attendance.dart';

class EmployeeWeekCard extends StatelessWidget {
  final WeekAttendance week;
  final VoidCallback? onTap;

  const EmployeeWeekCard({super.key, required this.week, this.onTap});

  @override
  Widget build(BuildContext context) {
    final initials = week.userName.trim().split(' ')
        .take(2).map((w) => w[0].toUpperCase()).join();

    return ShadCard(
      hoverable: true,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ──────────────────────────────────────────────────────────
        Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: ShadNeutral.muted,
              borderRadius: BorderRadius.circular(ShadNeutral.radiusSm),
              border: Border.all(color: ShadNeutral.border),
            ),
            child: Center(child: Text(initials,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: ShadNeutral.foreground))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, children: [
            Text(week.userName, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                  color: ShadNeutral.foreground)),
            Text('${week.completeDays}/${week.expectedWorkDays} días',
              style: const TextStyle(fontSize: 11, color: ShadNeutral.mutedFg)),
          ])),
          // Badge bono
          ShadBadge(
            label: week.qualifiesForBonus ? 'Bono ✓' : 'Sin bono',
            variant: week.qualifiesForBonus
                ? ShadBadgeVariant.success
                : ShadBadgeVariant.destructive,
            icon: week.qualifiesForBonus ? LucideIcons.award : LucideIcons.circleX,
            sm: true,
          ),
        ]),

        const SizedBox(height: 14),
        const ShadDivider(),
        const SizedBox(height: 12),

        // ── Días de la semana ────────────────────────────────────────────────
        _WeekDayRow(days: week.days),

        const SizedBox(height: 12),

        // ── Footer ───────────────────────────────────────────────────────────
        Row(children: [
          if (week.totalOvertimeMinutes > 0) ...[
            const Icon(LucideIcons.clock3, size: 11, color: ShadNeutral.overtime),
            const SizedBox(width: 4),
            Text('+${week.overtimeFormatted}',
              style: const TextStyle(fontSize: 11, color: ShadNeutral.overtime,
                  fontWeight: FontWeight.w500)),
            const SizedBox(width: 10),
          ],
          if (!week.qualifiesForBonus)
            Expanded(child: Text(_failMsg(week.bonusFailReason),
              style: const TextStyle(fontSize: 10, color: ShadNeutral.mutedFg),
              overflow: TextOverflow.ellipsis))
          else
            const Expanded(child: Text('Puntualidad completa',
              style: TextStyle(fontSize: 10, color: ShadNeutral.mutedFg))),

          // Flecha "ver detalle"
          const Icon(LucideIcons.chevronRight, size: 13, color: ShadNeutral.fgTertiary),
        ]),
      ]),
    );
  }

  String _failMsg(BonusFailReason r) => switch (r) {
    BonusFailReason.incompleteDays => 'Día(s) faltantes o incompletos',
    BonusFailReason.lateEntry      => 'Tardanza en entrada',
    BonusFailReason.earlyExit      => 'Salida anticipada',
    BonusFailReason.multiple       => 'Múltiples incumplimientos',
    BonusFailReason.none           => '',
  };
}

// ── Mini calendario ───────────────────────────────────────────────────────────
class _WeekDayRow extends StatelessWidget {
  final List<DayAttendance> days;
  const _WeekDayRow({required this.days});

  @override
  Widget build(BuildContext context) {
    final workDays = days.where((d) => d.status != DayStatus.nonWorkday).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: workDays.map((d) => _DayCell(day: d)).toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DayAttendance day;
  const _DayCell({required this.day});

  @override
  Widget build(BuildContext context) {
    final lbl = DateFormat('E', 'es_MX').format(day.date).substring(0, 2).toUpperCase();

    final (color, icon) = switch (day.status) {
      DayStatus.complete when day.isPunctualEntry && day.isPunctualExit =>
        (ShadNeutral.success, LucideIcons.circleCheck),
      DayStatus.complete =>
        (ShadNeutral.warning, LucideIcons.circleAlert),
      DayStatus.missingEntry || DayStatus.missingExit =>
        (ShadNeutral.warning, LucideIcons.circleMinus),
      DayStatus.absent =>
        (ShadNeutral.destructive, LucideIcons.circleX),
      DayStatus.future =>
        (ShadNeutral.fgTertiary, LucideIcons.circle),
      _ => (ShadNeutral.fgTertiary, LucideIcons.circle),
    };

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(ShadNeutral.radiusSm),
          border: Border.all(color: color.withAlpha(180)),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
      const SizedBox(height: 4),
      Text(lbl, style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w500,
          color: day.status == DayStatus.future
              ? ShadNeutral.fgTertiary : ShadNeutral.mutedFg)),
      if (day.overtimeMinutes > 0)
        Text('+${day.overtimeMinutes}m',
          style: const TextStyle(fontSize: 9, color: ShadNeutral.overtime)),
    ]);
  }
}
