import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import '../../../settings/domain/entities/work_schedule_config.dart';
import '../../domain/entities/week_range_helper.dart';

class WeekSelectorWidget extends StatelessWidget {
  final DateTime selectedStart;
  final DateTime selectedEnd;
  final WorkScheduleConfig config;
  final void Function(DateTime, DateTime) onWeekSelected;

  const WeekSelectorWidget({
    super.key,
    required this.selectedStart,
    required this.selectedEnd,
    required this.config,
    required this.onWeekSelected,
  });

  @override
  Widget build(BuildContext context) {
    final weeks = WeekRangeHelper.recentWeeks(config.copyWith(weekEndDay: DateTime.sunday), count: 12);
    final fmt   = DateFormat('d MMM', 'es_MX');

    final idx = weeks.indexWhere((w) =>
        w.start.year  == selectedStart.year &&
        w.start.month == selectedStart.month &&
        w.start.day   == selectedStart.day);

    return ComboBox<int>(
      value: idx >= 0 ? idx : 0,
      items: weeks.asMap().entries.map((e) {
        final i = e.key; final w = e.value;
        return ComboBoxItem<int>(
          value: i,
          child: Text(
            i == 0
                ? 'Esta semana · ${fmt.format(w.start)} – ${fmt.format(w.end)}'
                : '${fmt.format(w.start)} – ${fmt.format(w.end)}',
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
      onChanged: (i) {
        if (i == null) return;
        onWeekSelected(weeks[i].start, weeks[i].end);
      },
    );
  }
}
