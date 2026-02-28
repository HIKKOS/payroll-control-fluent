import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:nomina_control/shared/widgets/dash_widgets.dart';
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
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 560),
        title: _SheetHeader(week: week),
        content: _SheetBody(week: week, config: config),
        actions: [
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppColors.bg3)),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar', style: TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final WeekAttendance week;
  const _SheetHeader({required this.week});

  @override
  Widget build(BuildContext context) {
    final initials = week.userName.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join();
    return Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.cyanGlow, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cyan.withOpacity(0.5)),
        ),
        child: Center(child: Text(initials, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.cyan))),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(week.userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text('${week.completeDays} / ${week.expectedWorkDays} días completos', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ])),
      // Chips resumen
      if (week.qualifiesForBonus)
        const StatusBadge(label: 'Bono ✓', variant: BadgeVariant.success, icon: FluentIcons.skype_check)
      else
        const StatusBadge(label: 'Sin bono', variant: BadgeVariant.danger, icon: FluentIcons.skype_minus),
      const SizedBox(width: 8),
      if (week.totalOvertimeMinutes > 0)
        StatusBadge(label: '+${week.overtimeFormatted}', variant: BadgeVariant.overtime, icon: FluentIcons.clock),
    ]);
  }
}

class _SheetBody extends StatelessWidget {
  final WeekAttendance week;
  final WorkScheduleConfig config;
  const _SheetBody({required this.week, required this.config});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    final dayFmt  = DateFormat('EEEE d MMM', 'es_MX');
    final workDays = week.days.where((d) => d.status != DayStatus.nonWorkday).toList();
    final schStart = _fmtDuration(config.workStartTime);
    final schEnd   = _fmtDuration(config.workEndTime);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Info de horario
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(children: [
          const Icon(FluentIcons.clock, size: 13, color: AppColors.textTertiary),
          const SizedBox(width: 6),
          Text('Horario: $schStart – $schEnd  ·  Gracia entrada: ${config.graceMinutes}min  ·  Gracia salida: ${config.exitGraceMinutes}min',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ),

      // Tabla de días
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.bgBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(children: [
          // Encabezado tabla
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.bg3,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            child: Row(children: [
              const SizedBox(width: 28),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: Text('Día', style: _headerStyle())),
              Expanded(flex: 2, child: Text('Entrada', style: _headerStyle(), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('Salida', style: _headerStyle(), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('Extra', style: _headerStyle(), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('Estado', style: _headerStyle(), textAlign: TextAlign.right)),
            ]),
          ),

          // Filas de días
          ...workDays.asMap().entries.map((e) {
            final i = e.key;
            final day = e.value;
            final isLast = i == workDays.length - 1;
            return _DayRow(day: day, dayFmt: dayFmt, timeFmt: timeFmt, isLast: isLast, config: config);
          }),
        ]),
      ),
    ]);
  }

  TextStyle _headerStyle() => const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5);
  String _fmtDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _DayRow extends StatelessWidget {
  final DayAttendance day;
  final DateFormat dayFmt;
  final DateFormat timeFmt;
  final WorkScheduleConfig config;
  final bool isLast;
  const _DayRow({required this.day, required this.dayFmt, required this.timeFmt, required this.config, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusIcon, statusLabel) = _status();
    final rowBg = switch (day.status) {
      DayStatus.absent => AppColors.dangerBg,
      DayStatus.missingEntry || DayStatus.missingExit => AppColors.warningBg,
      DayStatus.complete when !day.isPunctualEntry || !day.isPunctualExit => AppColors.warningBg,
      _ => Colors.transparent,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: rowBg,
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.bgBorder, width: 0.5)),
        borderRadius: isLast ? const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)) : null,
      ),
      child: Row(children: [
        Icon(statusIcon, size: 14, color: statusColor),
        const SizedBox(width: 12),
        Expanded(flex: 3, child: Text(
          _capitalize(dayFmt.format(day.date)),
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        )),
        Expanded(flex: 2, child: _TimeCell(
          time: day.entryTime != null ? timeFmt.format(day.entryTime!) : '—',
          isPunctual: day.isPunctualEntry,
          hasTime: day.entryTime != null,
        )),
        Expanded(flex: 2, child: _TimeCell(
          time: day.exitTime != null ? timeFmt.format(day.exitTime!) : '—',
          isPunctual: day.isPunctualExit,
          hasTime: day.exitTime != null,
        )),
        Expanded(flex: 2, child: day.overtimeMinutes > 0
            ? Text('+${day.overtimeMinutes}m', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.overtime, fontWeight: FontWeight.w600))
            : const Text('—', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
        ),
        Expanded(flex: 2, child: Align(
          alignment: Alignment.centerRight,
          child: StatusBadge(label: statusLabel, variant: _variant(), compact: true),
        )),
      ]),
    );
  }

  (Color, IconData, String) _status() => switch (day.status) {
    DayStatus.complete when day.isPunctualEntry && day.isPunctualExit => (AppColors.success, FluentIcons.check_mark, 'OK'),
    DayStatus.complete when !day.isPunctualEntry && !day.isPunctualExit => (AppColors.warning, FluentIcons.warning, 'Tardanza + salida'),
    DayStatus.complete when !day.isPunctualEntry => (AppColors.warning, FluentIcons.warning, 'Tardanza'),
    DayStatus.complete => (AppColors.warning, FluentIcons.warning, 'Salida early'),
    DayStatus.missingEntry => (AppColors.warning, FluentIcons.remove, 'Sin entrada'),
    DayStatus.missingExit  => (AppColors.warning, FluentIcons.remove, 'Sin salida'),
    DayStatus.absent       => (AppColors.danger, FluentIcons.cancel, 'Ausente'),
    DayStatus.future       => (AppColors.textDisabled, FluentIcons.circle_half_full, 'Pendiente'),
    _                      => (AppColors.textDisabled, FluentIcons.circle_half_full, '—'),
  };

  BadgeVariant _variant() => switch (day.status) {
    DayStatus.complete when day.isPunctualEntry && day.isPunctualExit => BadgeVariant.success,
    DayStatus.absent => BadgeVariant.danger,
    DayStatus.future => BadgeVariant.neutral,
    _ => BadgeVariant.warning,
  };

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _TimeCell extends StatelessWidget {
  final String time;
  final bool isPunctual;
  final bool hasTime;
  const _TimeCell({required this.time, required this.isPunctual, required this.hasTime});

  @override
  Widget build(BuildContext context) {
    final color = !hasTime ? AppColors.textTertiary : isPunctual ? AppColors.textPrimary : AppColors.warning;
    return Text(time, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color, fontFeatures: const [FontFeature.tabularFigures()]));
  }
}