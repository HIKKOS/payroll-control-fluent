import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:nomina_control/shared/widgets/dash_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/dash_widgets.dart';
import '../../domain/entities/day_attendance.dart';
import '../../domain/entities/week_attendance.dart';

class EmployeeWeekCard extends StatefulWidget {
  final WeekAttendance week;
  final VoidCallback? onTap;

  const EmployeeWeekCard({super.key, required this.week, this.onTap});

  @override
  State<EmployeeWeekCard> createState() => _EmployeeWeekCardState();
}

class _EmployeeWeekCardState extends State<EmployeeWeekCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final week = widget.week;
    final initials = week.userName.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.bg3 : AppColors.bg2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered
                  ? (week.qualifiesForBonus ? AppColors.success.withOpacity(0.6) : AppColors.danger.withOpacity(0.4))
                  : AppColors.bgBorder,
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: AppColors.cyanGlow, blurRadius: 10)]
                : [],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.cyanGlow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cyan.withOpacity(0.4)),
                ),
                child: Center(
                  child: Text(initials, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.cyan)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(week.userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                Text('${week.completeDays}/${week.expectedWorkDays} días', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ])),
              // Bono badge
              StatusBadge(
                label: week.qualifiesForBonus ? 'Bono ✓' : 'Sin bono',
                variant: week.qualifiesForBonus ? BadgeVariant.success : BadgeVariant.danger,
                icon: week.qualifiesForBonus ? FluentIcons.skype_check : FluentIcons.skype_minus,
                compact: true,
              ),
            ]),

            const SizedBox(height: 14),

            // ── Mini calendario de días ──────────────────────────────────────
            _WeekDayBar(days: week.days),

            const SizedBox(height: 12),

            // ── Footer: horas extra + razón de pérdida ────────────────────
            Row(children: [
              if (week.totalOvertimeMinutes > 0) ...[
                const Icon(FluentIcons.clock, size: 12, color: AppColors.overtime),
                const SizedBox(width: 4),
                Text('+${week.overtimeFormatted}', style: const TextStyle(fontSize: 11, color: AppColors.overtime, fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
              ],
              if (!week.qualifiesForBonus)
                Expanded(
                  child: Text(
                    _failMsg(week.bonusFailReason),
                    style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const Expanded(child: Text('Puntualidad completa', style: TextStyle(fontSize: 10, color: AppColors.textTertiary))),
            ]),
          ]),
        ),
      ),
    );
  }

  String _failMsg(BonusFailReason r) => switch (r) {
    BonusFailReason.incompleteDays => 'Falta(n) día(s) o registro(s)',
    BonusFailReason.lateEntry      => 'Tardanza en entrada',
    BonusFailReason.earlyExit      => 'Salida anticipada',
    BonusFailReason.multiple       => 'Múltiples incumplimientos',
    BonusFailReason.none           => '',
  };
}

// ── _WeekDayBar ───────────────────────────────────────────────────────────────
class _WeekDayBar extends StatelessWidget {
  final List<DayAttendance> days;
  const _WeekDayBar({required this.days});

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
    final label = DateFormat('E', 'es_MX').format(day.date).substring(0, 2).toUpperCase();

    final (color, icon) = switch (day.status) {
      DayStatus.complete when day.isPunctualEntry && day.isPunctualExit =>
      (AppColors.success, FluentIcons.check_mark),
      DayStatus.complete =>
      (AppColors.warning, FluentIcons.warning),
      DayStatus.missingEntry || DayStatus.missingExit =>
      (AppColors.warning, FluentIcons.remove),
      DayStatus.absent =>
      (AppColors.danger, FluentIcons.cancel),
      DayStatus.future =>
      (AppColors.textDisabled, FluentIcons.circle_half_full),
      _ => (AppColors.textDisabled, FluentIcons.circle_half_full),
    };

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Icon(icon, size: 13, color: color),
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: day.status == DayStatus.future ? AppColors.textDisabled : AppColors.textSecondary)),
      if (day.overtimeMinutes > 0)
        Text('+${day.overtimeMinutes}m', style: const TextStyle(fontSize: 9, color: AppColors.overtime)),
    ]);
  }
}