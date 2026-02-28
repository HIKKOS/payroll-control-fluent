import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/day_attendance.dart';
import '../../domain/entities/week_attendance.dart';

class EmployeeWeekCard extends StatelessWidget {
  final WeekAttendance week;
  final VoidCallback? onTap;

  const EmployeeWeekCard({
    super.key,
    required this.week,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bonusColor = week.qualifiesForBonus ? Colors.green.shade700 : Colors.red.shade700;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Text(
                      week.userName.isNotEmpty ? week.userName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          week.userName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${week.completeDays} / ${week.expectedWorkDays} días completos',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  // ── Badge bono ─────────────────────────────────────────────
                  _BonusBadge(week: week),
                ],
              ),

              const SizedBox(height: 16),

              // ── Mini calendario semanal ───────────────────────────────────
              _WeekDayRow(days: week.days),

              const SizedBox(height: 12),

              // ── Horas extra ───────────────────────────────────────────────
              if (week.totalOvertimeMinutes > 0)
                Row(
                  children: [
                    Icon(Icons.access_time_filled,
                        size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Tiempo extra: ${week.overtimeFormatted}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

              // ── Razón pérdida de bono ─────────────────────────────────────
              if (!week.qualifiesForBonus)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 14, color: bonusColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _bonusFailMessage(week.bonusFailReason),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: bonusColor),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _bonusFailMessage(BonusFailReason reason) {
    switch (reason) {
      case BonusFailReason.incompleteDays:
        return 'Días faltantes o registros incompletos';
      case BonusFailReason.lateEntry:
        return 'Llegó tarde al menos un día';
      case BonusFailReason.earlyExit:
        return 'Salió antes de tiempo al menos un día';
      case BonusFailReason.multiple:
        return 'Múltiples incumplimientos';
      case BonusFailReason.none:
        return '';
    }
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _BonusBadge extends StatelessWidget {
  final WeekAttendance week;

  const _BonusBadge({required this.week});

  @override
  Widget build(BuildContext context) {
    final qualifies = week.qualifiesForBonus;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: qualifies ? Colors.green.shade50 : Colors.red.shade50,
        border: Border.all(
          color: qualifies ? Colors.green.shade300 : Colors.red.shade300,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            qualifies ? Icons.star_rounded : Icons.star_border_rounded,
            size: 14,
            color: qualifies ? Colors.green.shade700 : Colors.red.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            qualifies ? 'Bono ✓' : 'Sin bono',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: qualifies ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekDayRow extends StatelessWidget {
  final List<DayAttendance> days;

  const _WeekDayRow({required this.days});

  @override
  Widget build(BuildContext context) {
    final workDays = days.where((d) => d.status != DayStatus.nonWorkday).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: workDays.map((day) => _DayDot(day: day)).toList(),
    );
  }
}

class _DayDot extends StatelessWidget {
  final DayAttendance day;

  const _DayDot({required this.day});

  @override
  Widget build(BuildContext context) {
    final dayLabel = DateFormat('E', 'es_MX').format(day.date).substring(0, 2).toUpperCase();

    Color color;
    IconData icon;

    switch (day.status) {
      case DayStatus.complete:
        final allGood = day.isPunctualEntry && day.isPunctualExit;
        color = allGood ? Colors.green : Colors.orange;
        icon = allGood ? Icons.check_circle : Icons.warning_amber_rounded;
        break;
      case DayStatus.missingEntry:
      case DayStatus.missingExit:
        color = Colors.orange.shade700;
        icon = Icons.remove_circle_outline;
        break;
      case DayStatus.absent:
        color = Colors.red.shade400;
        icon = Icons.cancel_outlined;
        break;
      case DayStatus.future:
        color = Colors.grey.shade300;
        icon = Icons.circle_outlined;
        break;
      case DayStatus.nonWorkday:
        color = Colors.transparent;
        icon = Icons.circle_outlined;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 2),
        Text(
          dayLabel,
          style: TextStyle(
            fontSize: 10,
            color: day.status == DayStatus.future ? Colors.grey : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (day.overtimeMinutes > 0)
          Text(
            '+${day.overtimeMinutes}m',
            style: TextStyle(fontSize: 9, color: Colors.orange.shade700),
          ),
      ],
    );
  }
}
