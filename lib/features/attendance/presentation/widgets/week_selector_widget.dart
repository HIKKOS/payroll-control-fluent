import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import '../../../settings/domain/entities/work_schedule_config.dart';
import '../../domain/usecases/week_range_helper.dart';

class WeekSelectorWidget extends StatelessWidget {
  final DateTime selectedStart;
  final DateTime selectedEnd;
  final WorkScheduleConfig config;
  final void Function(DateTime start, DateTime end) onWeekSelected;

  const WeekSelectorWidget({
    super.key,
    required this.selectedStart,
    required this.selectedEnd,
    required this.config,
    required this.onWeekSelected,
  });

  @override
  Widget build(BuildContext context) {
    final weeks = WeekRangeHelper.recentWeeks(config, count: 12);
    final fmt = DateFormat('d MMM', 'es_MX');

    final selectedIdx = weeks.indexWhere((w) =>
    w.start.year == selectedStart.year &&
        w.start.month == selectedStart.month &&
        w.start.day == selectedStart.day);

    final items = weeks.asMap().entries.map((e) {
      final i = e.key;
      final w = e.value;
      final label = i == 0
          ? 'Esta semana · ${fmt.format(w.start)} – ${fmt.format(w.end)}'
          : '${fmt.format(w.start)} – ${fmt.format(w.end)}';
      return ComboBoxItem<int>(value: i, child: Text(label, style: const TextStyle(fontSize: 12)));
    }).toList();

    return ComboBox<int>(
      value: selectedIdx >= 0 ? selectedIdx : 0,
      items: items,
      onChanged: (idx) {
        if (idx == null) return;
        final w = weeks[idx];
        onWeekSelected(w.start, w.end);
      },
    );
  }
}