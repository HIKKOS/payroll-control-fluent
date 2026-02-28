import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/day_attendance.dart';
import '../../domain/entities/week_attendance.dart';
import '../../../settings/domain/entities/work_schedule_config.dart';

/// Bottom sheet que muestra el detalle completo de la semana de un empleado,
/// con información de cada día: hora de entrada, salida, overtime, puntualidad.
class EmployeeWeekDetailSheet extends StatelessWidget {
  final WeekAttendance week;
  final WorkScheduleConfig config;

  const EmployeeWeekDetailSheet({
    super.key,
    required this.week,
    required this.config,
  });

  static void show(
    BuildContext context,
    WeekAttendance week,
    WorkScheduleConfig config,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EmployeeWeekDetailSheet(week: week, config: config),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFmt = DateFormat('HH:mm');
    final dayFmt = DateFormat('EEEE d MMM', 'es_MX');
    final scheduledStart = _durationToTimeString(config.workStartTime);
    final scheduledEnd   = _durationToTimeString(config.workEndTime);
    final workDays = week.days.where((d) => d.status != DayStatus.nonWorkday).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle ────────────────────────────────────────────────────
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header empleado ───────────────────────────────────────────
            Text(week.userName,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Horario: $scheduledStart – $scheduledEnd  '
              '| Gracia: ${config.graceMinutes}min',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // ── Chips resumen ─────────────────────────────────────────────
            Wrap(
              spacing: 8, runSpacing: 4,
              children: [
                _SummaryChip(
                  label: week.qualifiesForBonus ? 'Bono ✓' : 'Sin bono',
                  color: week.qualifiesForBonus ? Colors.green : Colors.red,
                  icon: week.qualifiesForBonus
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                ),
                if (week.totalOvertimeMinutes > 0)
                  _SummaryChip(
                    label: 'Extra: ${week.overtimeFormatted}',
                    color: Colors.orange,
                    icon: Icons.access_time_filled,
                  ),
                _SummaryChip(
                  label: '${week.completeDays}/${week.expectedWorkDays} días',
                  color: Colors.blue,
                  icon: Icons.calendar_today,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            // ── Lista de días ─────────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                controller: controller,
                itemCount: workDays.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final day = workDays[i];
                  return _DayDetailRow(
                    day: day,
                    dayFmt: dayFmt,
                    timeFmt: timeFmt,
                    config: config,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _durationToTimeString(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _DayDetailRow extends StatelessWidget {
  final DayAttendance day;
  final DateFormat dayFmt;
  final DateFormat timeFmt;
  final WorkScheduleConfig config;

  const _DayDetailRow({
    required this.day,
    required this.dayFmt,
    required this.timeFmt,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget statusIcon;
    Color rowColor = Colors.transparent;

    switch (day.status) {
      case DayStatus.complete:
        final ok = day.isPunctualEntry && day.isPunctualExit;
        statusIcon = Icon(
          ok ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
          color: ok ? Colors.green : Colors.orange,
          size: 20,
        );
        if (!ok) rowColor = Colors.orange.shade50;
        break;
      case DayStatus.missingEntry:
      case DayStatus.missingExit:
        statusIcon = const Icon(Icons.remove_circle, color: Colors.orange, size: 20);
        rowColor = Colors.orange.shade50;
        break;
      case DayStatus.absent:
        statusIcon = const Icon(Icons.cancel, color: Colors.red, size: 20);
        rowColor = Colors.red.shade50;
        break;
      case DayStatus.future:
        statusIcon = Icon(Icons.schedule, color: Colors.grey.shade400, size: 20);
        break;
      default:
        statusIcon = const SizedBox.shrink();
    }

    return Container(
      color: rowColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          statusIcon,
          const SizedBox(width: 12),

          // ── Fecha ──────────────────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Text(
              _capitalize(dayFmt.format(day.date)),
              style: theme.textTheme.bodyMedium,
            ),
          ),

          // ── Entrada ────────────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: _TimeCell(
              label: 'Entrada',
              time: day.entryTime != null ? timeFmt.format(day.entryTime!) : '--:--',
              isPunctual: day.isPunctualEntry,
              hasTime: day.entryTime != null,
            ),
          ),

          // ── Salida ─────────────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: _TimeCell(
              label: 'Salida',
              time: day.exitTime != null ? timeFmt.format(day.exitTime!) : '--:--',
              isPunctual: day.isPunctualExit,
              hasTime: day.exitTime != null,
            ),
          ),

          // ── Horas extra ────────────────────────────────────────────────
          if (day.overtimeMinutes > 0)
            Text(
              '+${day.overtimeMinutes}m',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _TimeCell extends StatelessWidget {
  final String label;
  final String time;
  final bool isPunctual;
  final bool hasTime;

  const _TimeCell({
    required this.label,
    required this.time,
    required this.isPunctual,
    required this.hasTime,
  });

  @override
  Widget build(BuildContext context) {
    final color = !hasTime
        ? Colors.grey
        : isPunctual
            ? Colors.black87
            : Colors.orange.shade800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 9, color: Colors.grey)),
        Text(
          time,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _SummaryChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      avatar: Icon(icon, size: 14, color: color),
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.4)),
    );
  }
}
