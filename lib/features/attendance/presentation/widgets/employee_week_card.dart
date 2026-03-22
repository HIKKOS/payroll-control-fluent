import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:nomina_control/shared/widgets/dash_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/day_attendance.dart';
import '../../domain/entities/week_attendance.dart';

class EmployeeWeekCard extends StatelessWidget {
  final WeekAttendance week;
  final VoidCallback? onTap;

  const EmployeeWeekCard({super.key, required this.week, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c        = context.colors;
    final initials = week.userName.trim().split(' ')
        .take(2).map((w) => (w as String)[0].toUpperCase()).join();

    return ShadCard(
      hoverable: true,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header: avatar + nombre + badge bono ─────────────────────────────
        Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: c.muted,
              borderRadius: BorderRadius.circular(AppColors.radiusSm),
              border: Border.all(color: c.border),
            ),
            child: Center(child: Text(initials,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: c.foreground))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(week.userName, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                      color: c.foreground)),
              Text('${week.completeDays}/${week.expectedWorkDays} días',
                  style: TextStyle(fontSize: 11, color: c.mutedFg)),
            ],
          )),
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

        // ── Mini calendario L–V ───────────────────────────────────────────────
        _WeekDayRow(days: week.days),

        const SizedBox(height: 12),

        // ── Footer: overtime total + razón de no-bono + fin de semana ────────
        Row(children: [
          // Overtime total (L–V + fin de semana)
          if (week.totalOvertimeMinutes > 0) ...[
            Icon(LucideIcons.clock3, size: 11, color: c.overtime),
            const SizedBox(width: 4),
            Text('+${week.overtimeFormatted}',
                style: TextStyle(fontSize: 11, color: c.overtime,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 6),
          ],

          // Pill de fin de semana — solo si trabajó sáb/dom
          if (week.weekendDays.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: c.overtime.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppColors.radiusSm),
                border: Border.all(color: c.overtime.withOpacity(0.25)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(LucideIcons.calendarClock, size: 9, color: c.overtime),
                const SizedBox(width: 3),
                Text('FDS', style: TextStyle(
                  fontSize: 9, color: c.overtime, fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                )),
              ]),
            ),
            const SizedBox(width: 6),
          ],

          Expanded(child: week.qualifiesForBonus
              ? Text('Puntualidad completa',
              style: TextStyle(fontSize: 10, color: c.mutedFg))
              : Text(_failMsg(week.bonusFailReason),
              style: TextStyle(fontSize: 10, color: c.mutedFg),
              overflow: TextOverflow.ellipsis)),

          Icon(LucideIcons.chevronRight, size: 13, color: c.fgTertiary),
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

// ── Mini calendario L–V ───────────────────────────────────────────────────────
class _WeekDayRow extends StatelessWidget {
  final List<DayAttendance> days;
  const _WeekDayRow({required this.days});

  @override
  Widget build(BuildContext context) {
    // Filtramos nonWorkday — en la tarjeta solo mostramos días laborables
    final workDays = days
        .where((d) => d.status != DayStatus.nonWorkday && d.status != DayStatus.weekend)
        .toList();
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
    final c   = context.colors;
    final lbl = DateFormat('E', 'es_MX').format(day.date)
        .substring(0, 2).toUpperCase();

    final (color, icon) = switch (day.status) {
      DayStatus.complete when day.isPunctualEntry && day.isPunctualExit =>
        (context.colors.success, LucideIcons.circleCheck),
      DayStatus.complete =>
        (context.colors.warning, LucideIcons.circleAlert),
      DayStatus.missingEntry || DayStatus.missingExit =>
        (context.colors.warning, LucideIcons.circleMinus),
      DayStatus.absent =>
        (context.colors.destructive, LucideIcons.circleX),
      DayStatus.future =>
        (context.colors.fgTertiary, LucideIcons.circle),
      _ => (context.colors.fgTertiary, LucideIcons.circle),
    };

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppColors.radiusSm),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
      const SizedBox(height: 4),
      Text(lbl, style: TextStyle(
        fontSize: 10, fontWeight: FontWeight.w500,
        color: day.status == DayStatus.future ? c.fgTertiary : c.mutedFg,
      )),
      // Overtime del día (L–V)
      if (day.overtimeMinutes > 0)
        Text('+${day.overtimeMinutes}m',
            style: TextStyle(fontSize: 9, color: c.overtime)),
    ]);
  }
}