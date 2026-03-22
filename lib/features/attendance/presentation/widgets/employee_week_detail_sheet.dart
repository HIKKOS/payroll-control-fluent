import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:nomina_control/core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/dash_widgets.dart';
import '../../../settings/domain/entities/work_schedule_config.dart';
import '../../domain/entities/day_attendance.dart';
import '../../domain/entities/week_attendance.dart';

// ─── Punto de entrada ─────────────────────────────────────────────────────────

class EmployeeWeekDetailSheet {
  static void show(
      BuildContext context,
      WeekAttendance week,
      WorkScheduleConfig config,
      ) {
    final c = context.colors;
    showDialog(
      context: context,
      builder: (_) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 680),
        style: ContentDialogThemeData(
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.all(Radius.circular(AppColors.radiusXl)),
            border: Border.fromBorderSide(BorderSide(color: c.border)),
          ),
          titlePadding:   const EdgeInsets.fromLTRB(24, 24, 24, 0),
          bodyPadding:    const EdgeInsets.fromLTRB(24, 12, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        ),
        title:   _DialogHeader(week: week),
        content: _TabbedBody(week: week, config: config),
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

// ─── Header (común a los dos tabs) ───────────────────────────────────────────

class _DialogHeader extends StatelessWidget {
  final WeekAttendance week;
  const _DialogHeader({required this.week});

  @override
  Widget build(BuildContext context) {
    final c        = context.colors;
    final initials = week.userName.trim().split(' ')
        .take(2).map((w) => (w as String)[0].toUpperCase()).join();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        // Avatar
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: c.muted,
            borderRadius: BorderRadius.circular(AppColors.radius),
            border: Border.all(color: c.border),
          ),
          child: Center(child: Text(initials,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: c.foreground))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(week.userName, style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: c.foreground)),
            Text('${week.completeDays} / ${week.expectedWorkDays} días L–V',
                style: TextStyle(fontSize: 12, color: c.mutedFg)),
          ],
        )),
        // Badge bono
        ShadBadge(
          label: week.qualifiesForBonus ? 'Bono ✓' : 'Sin bono',
          variant: week.qualifiesForBonus
              ? ShadBadgeVariant.success : ShadBadgeVariant.destructive,
          icon: week.qualifiesForBonus ? LucideIcons.award : LucideIcons.circleX,
        ),
        // Badge overtime total
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

// ─── Cuerpo con tabs ──────────────────────────────────────────────────────────

class _TabbedBody extends StatefulWidget {
  final WeekAttendance week;
  final WorkScheduleConfig config;
  const _TabbedBody({required this.week, required this.config});

  @override
  State<_TabbedBody> createState() => _TabbedBodyState();
}

class _TabbedBodyState extends State<_TabbedBody> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Selector de tabs ────────────────────────────────────────────────────
      Row(children: [
        _TabChip(
          label: 'Semana laboral',
          icon:  LucideIcons.calendarDays,
          active: _tab == 0,
          onTap: () => setState(() => _tab = 0),
        ),
        const SizedBox(width: 6),
        _TabChip(
          label: 'Por horas',
          icon:  LucideIcons.clock4,
          active: _tab == 1,
          onTap: () => setState(() => _tab = 1),
        ),
      ]),
      const SizedBox(height: 14),

      // ── Contenido del tab activo ────────────────────────────────────────────
      Expanded(
        child: _tab == 0
            ? _WorkweekTab(week: widget.week, config: widget.config)
            : _HourlyTab(week: widget.week),
      ),
    ]);
  }
}

// ─── Chip de tab ─────────────────────────────────────────────────────────────

class _TabChip extends StatelessWidget {
  final String   label;
  final IconData icon;
  final bool     active;
  final VoidCallback onTap;
  const _TabChip({
    required this.label, required this.icon,
    required this.active, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:        active ? c.foreground : c.muted,
          borderRadius: BorderRadius.circular(AppColors.radius),
          border:       Border.all(color: active ? c.foreground : c.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12,
              color: active ? c.primaryFg : c.mutedFg),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500,
            color: active ? c.primaryFg : c.mutedFg,
          )),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 1 — Semana laboral (vista original, sin cambios de lógica)
// ═══════════════════════════════════════════════════════════════════════════════

class _WorkweekTab extends StatelessWidget {
  final WeekAttendance week;
  final WorkScheduleConfig config;
  const _WorkweekTab({required this.week, required this.config});

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final c       = context.colors;
    final timeFmt = DateFormat('HH:mm');
    final dayFmt  = DateFormat('EEE d MMM', 'es_MX');
    final workDays = week.days
        .where((d) =>
    d.status != DayStatus.nonWorkday &&
        d.status != DayStatus.weekend)
        .toList();

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Horario de referencia
        Row(children: [
          Icon(LucideIcons.clock4, size: 12, color: c.mutedFg),
          const SizedBox(width: 6),
          Text(
            'Horario: ${_fmt(config.workStartTime)} – ${_fmt(config.workEndTime)}'
                '  ·  Gracia: ${config.graceMinutes}min / ${config.exitGraceMinutes}min',
            style: TextStyle(fontSize: 11, color: c.mutedFg),
          ),
        ]),
        const SizedBox(height: 14),

        // Tabla L–V
        _WorkdayTable(days: workDays, timeFmt: timeFmt, dayFmt: dayFmt),

        // Sección fin de semana
        if (week.weekendDays.isNotEmpty) ...[
          const SizedBox(height: 20),
          _WeekendSection(
              days: week.weekendDays, timeFmt: timeFmt, dayFmt: dayFmt),
        ],
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 2 — Por horas
// ═══════════════════════════════════════════════════════════════════════════════

class _HourlyTab extends StatelessWidget {
  final WeekAttendance week;
  const _HourlyTab({required this.week});

  @override
  Widget build(BuildContext context) {
    final c       = context.colors;
    final timeFmt = DateFormat('HH:mm');
    final dayFmt  = DateFormat('EEE d MMM', 'es_MX');
    final attended = week.allAttendedDays;

    if (attended.isEmpty) {
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.calendarX2, size: 32, color: c.fgTertiary),
          const SizedBox(height: 12),
          Text('Sin registros esta semana',
              style: TextStyle(fontSize: 13, color: c.mutedFg)),
        ],
      ));
    }

    // Total de minutos trabajados en días con entrada+salida
    final totalMinutes = attended
        .where((d) => d.entryTime != null && d.exitTime != null)
        .fold<int>(0, (s, d) {
      if (d.isWeekend) return s + d.overtimeMinutes; // ya es duración total
      // Para L–V: duración real entrada→salida (no el overtime)
      return s + d.exitTime!.difference(d.entryTime!).inMinutes;
    });

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Tabla de días asistidos
      Expanded(child: _HourlyTable(
        days:    attended,
        timeFmt: timeFmt,
        dayFmt:  dayFmt,
      )),

      // Pie con total acumulado
      const SizedBox(height: 12),
      const ShadDivider(),
      const SizedBox(height: 10),
      _HourlyTotals(
        totalMinutes: totalMinutes,
        daysCount:    attended.length,
      ),
    ]);
  }
}

// ─── Tabla por horas ──────────────────────────────────────────────────────────

class _HourlyTable extends StatelessWidget {
  final List<DayAttendance> days;
  final DateFormat dayFmt;
  final DateFormat timeFmt;
  const _HourlyTable({
    required this.days, required this.dayFmt, required this.timeFmt,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(AppColors.radius),
      ),
      child: Column(children: [
        // Cabecera
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: c.muted,
            borderRadius: const BorderRadius.only(
              topLeft:  Radius.circular(AppColors.radius),
              topRight: Radius.circular(AppColors.radius),
            ),
          ),
          child: Row(children: [
            const SizedBox(width: 36),
            Expanded(flex: 3, child: _th(context, 'Día')),
            Expanded(flex: 2, child: _th(context, 'Entrada', center: true)),
            Expanded(flex: 2, child: _th(context, 'Salida',  center: true)),
            Expanded(flex: 2, child: _th(context, 'Horas',   right: true)),
          ]),
        ),
        // Filas — hacemos scroll solo de esta tabla
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            itemBuilder: (_, i) => _HourlyRow(
              day:     days[i],
              dayFmt:  dayFmt,
              timeFmt: timeFmt,
              isLast:  i == days.length - 1,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _th(BuildContext context, String t,
      {bool center = false, bool right = false}) {
    final c = context.colors;
    return Text(t,
        textAlign: center ? TextAlign.center : right ? TextAlign.right : TextAlign.left,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
            color: c.mutedFg, letterSpacing: 0.2));
  }
}

// ─── Fila de la vista por horas ───────────────────────────────────────────────

class _HourlyRow extends StatelessWidget {
  final DayAttendance day;
  final DateFormat dayFmt;
  final DateFormat timeFmt;
  final bool isLast;
  const _HourlyRow({
    required this.day, required this.dayFmt,
    required this.timeFmt, required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    // Duración real trabajada (entrada → salida)
    final int workedMinutes;
    if (day.entryTime != null && day.exitTime != null) {
      workedMinutes = day.isWeekend
          ? day.overtimeMinutes                              // ya es duración total
          : day.exitTime!.difference(day.entryTime!).inMinutes;
    } else {
      workedMinutes = -1; // señal de "incompleto"
    }

    // Color de fila: fin de semana con tinte leve, incompleto con tinte warning
    final rowBg = day.isWeekend
        ? c.overtime.withOpacity(0.04)
        : workedMinutes < 0
        ? c.warningMuted.withOpacity(0.15)
        : Colors.transparent;

    final borderRadius = isLast
        ? const BorderRadius.only(
        bottomLeft:  Radius.circular(AppColors.radius),
        bottomRight: Radius.circular(AppColors.radius))
        : BorderRadius.zero;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: rowBg, borderRadius: borderRadius,
        border: isLast ? null : Border(
            bottom: BorderSide(color: c.border, width: 0.5)),
      ),
      child: Row(children: [
        // Icono: fin de semana vs día normal con registro completo vs incompleto
        Icon(
          day.isWeekend
              ? LucideIcons.calendarClock
              : workedMinutes < 0
              ? LucideIcons.circleMinus
              : LucideIcons.circleCheck,
          size: 14,
          color: day.isWeekend
              ? c.overtime
              : workedMinutes < 0 ? c.warning : c.success,
        ),
        const SizedBox(width: 10),

        // Nombre del día
        Expanded(flex: 3, child: Text(
            _cap(dayFmt.format(day.date)),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                color: c.foreground))),

        // Entrada
        Expanded(flex: 2, child: Text(
            day.entryTime != null ? timeFmt.format(day.entryTime!) : '—',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                color: day.entryTime != null ? c.foreground : c.fgTertiary,
                fontFeatures: const [FontFeature.tabularFigures()]))),

        // Salida
        Expanded(flex: 2, child: Text(
            day.exitTime != null ? timeFmt.format(day.exitTime!) : '—',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                color: day.exitTime != null ? c.foreground : c.fgTertiary,
                fontFeatures: const [FontFeature.tabularFigures()]))),

        // Horas trabajadas
        Expanded(flex: 2, child: Text(
          workedMinutes >= 0 ? _fmtDuration(workedMinutes) : '—',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: workedMinutes >= 0
                ? (day.isWeekend ? c.overtime : c.foreground)
                : c.fgTertiary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        )),
      ]),
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─── Total semanal ────────────────────────────────────────────────────────────

class _HourlyTotals extends StatelessWidget {
  final int totalMinutes;
  final int daysCount;
  const _HourlyTotals({required this.totalMinutes, required this.daysCount});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final h   = totalMinutes ~/ 60;
    final min = totalMinutes  % 60;
    // Promedio diario (solo días con horas completas ya están en totalMinutes)
    final avgMin = daysCount > 0 ? totalMinutes ~/ daysCount : 0;

    return Row(children: [
      // Total
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Total semanal',
            style: TextStyle(fontSize: 10, color: c.mutedFg,
                fontWeight: FontWeight.w500, letterSpacing: 0.2)),
        const SizedBox(height: 2),
        Text(
          '${h}h ${min.toString().padLeft(2, '0')}m',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
              color: c.foreground, letterSpacing: -0.4,
              fontFeatures: const [FontFeature.tabularFigures()]),
        ),
      ]),
      const SizedBox(width: 28),
      // Días asistidos
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Días con registro',
            style: TextStyle(fontSize: 10, color: c.mutedFg,
                fontWeight: FontWeight.w500, letterSpacing: 0.2)),
        const SizedBox(height: 2),
        Text('$daysCount día${daysCount == 1 ? '' : 's'}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                color: c.foreground, letterSpacing: -0.4)),
      ]),
      const SizedBox(width: 28),
      // Promedio diario
      if (daysCount > 0)
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Promedio/día',
              style: TextStyle(fontSize: 10, color: c.mutedFg,
                  fontWeight: FontWeight.w500, letterSpacing: 0.2)),
          const SizedBox(height: 2),
          Text(_fmtDuration(avgMin),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                  color: c.mutedFg, letterSpacing: -0.4,
                  fontFeatures: const [FontFeature.tabularFigures()])),
        ]),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Widgets del Tab 1 (extraídos del detail sheet anterior — sin cambios)
// ═══════════════════════════════════════════════════════════════════════════════

class _WorkdayTable extends StatelessWidget {
  final List<DayAttendance> days;
  final DateFormat dayFmt;
  final DateFormat timeFmt;
  const _WorkdayTable({
    required this.days, required this.dayFmt, required this.timeFmt,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(AppColors.radius),
      ),
      child: Column(children: [
        // Cabecera
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: c.muted,
            borderRadius: const BorderRadius.only(
              topLeft:  Radius.circular(AppColors.radius),
              topRight: Radius.circular(AppColors.radius),
            ),
          ),
          child: Row(children: [
            const SizedBox(width: 36),
            _th(context, 'Día',     flex: 3),
            _th(context, 'Entrada', flex: 2, center: true),
            _th(context, 'Salida',  flex: 2, center: true),
            _th(context, 'Extra',   flex: 2, center: true),
            _th(context, 'Estado',  flex: 2, right: true),
          ]),
        ),
        ...days.asMap().entries.map((e) => _WorkdayRow(
          day:     e.value,
          dayFmt:  dayFmt,
          timeFmt: timeFmt,
          isLast:  e.key == days.length - 1,
        )),
      ]),
    );
  }

  Widget _th(BuildContext context, String t,
      {int flex = 1, bool center = false, bool right = false}) {
    final c = context.colors;
    return Expanded(flex: flex, child: Text(t,
        textAlign: center ? TextAlign.center : right ? TextAlign.right : TextAlign.left,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
            color: c.mutedFg, letterSpacing: 0.2)));
  }
}

class _WorkdayRow extends StatelessWidget {
  final DayAttendance day;
  final DateFormat dayFmt;
  final DateFormat timeFmt;
  final bool isLast;
  const _WorkdayRow({
    required this.day, required this.dayFmt,
    required this.timeFmt, required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (iconData, iconColor, badgeLabel, badgeVariant) = _meta(c);

    final rowBg = switch (day.status) {
      DayStatus.absent =>
          c.destructiveMuted.withOpacity(0.3),
      DayStatus.missingEntry || DayStatus.missingExit =>
          c.warningMuted.withOpacity(0.3),
      DayStatus.complete when !day.isPunctualEntry || !day.isPunctualExit =>
          c.warningMuted.withOpacity(0.15),
      _ => Colors.transparent,
    };

    final borderRadius = isLast
        ? const BorderRadius.only(
        bottomLeft:  Radius.circular(AppColors.radius),
        bottomRight: Radius.circular(AppColors.radius))
        : BorderRadius.zero;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: rowBg, borderRadius: borderRadius,
        border: isLast ? null : Border(
            bottom: BorderSide(color: c.border, width: 0.5)),
      ),
      child: Row(children: [
        Icon(iconData, size: 14, color: iconColor),
        const SizedBox(width: 10),
        Expanded(flex: 3, child: Text(
            _cap(dayFmt.format(day.date)),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                color: c.foreground))),
        Expanded(flex: 2, child: _TimeVal(
            time:    day.entryTime != null ? timeFmt.format(day.entryTime!) : '—',
            ok:      day.isPunctualEntry,
            hasTime: day.entryTime != null)),
        Expanded(flex: 2, child: _TimeVal(
            time:    day.exitTime != null ? timeFmt.format(day.exitTime!) : '—',
            ok:      day.isPunctualExit,
            hasTime: day.exitTime != null)),
        Expanded(flex: 2, child: day.overtimeMinutes > 0
            ? Text('+${day.overtimeMinutes}m', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                color: c.overtime))
            : Text('—', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: c.fgTertiary))),
        Expanded(flex: 2, child: Align(
            alignment: Alignment.centerRight,
            child: ShadBadge(label: badgeLabel, variant: badgeVariant, sm: true))),
      ]),
    );
  }

  (IconData, Color, String, ShadBadgeVariant) _meta(AppColors c) =>
      switch (day.status) {
        DayStatus.complete when day.isPunctualEntry && day.isPunctualExit =>
        (LucideIcons.circleCheck, c.success,     'OK',            ShadBadgeVariant.success),
        DayStatus.complete when !day.isPunctualEntry && !day.isPunctualExit =>
        (LucideIcons.circleAlert,  c.warning,     'Tardanza+sal.', ShadBadgeVariant.warning),
        DayStatus.complete when !day.isPunctualEntry =>
        (LucideIcons.circleAlert,  c.warning,     'Tardanza',      ShadBadgeVariant.warning),
        DayStatus.complete =>
        (LucideIcons.circleAlert,  c.warning,     'Salida early',  ShadBadgeVariant.warning),
        DayStatus.missingEntry =>
        (LucideIcons.circleMinus,  c.warning,     'Sin entrada',   ShadBadgeVariant.warning),
        DayStatus.missingExit =>
        (LucideIcons.circleMinus,  c.warning,     'Sin salida',    ShadBadgeVariant.warning),
        DayStatus.absent =>
        (LucideIcons.circleX,      c.destructive, 'Ausente',       ShadBadgeVariant.destructive),
        _ =>
        (LucideIcons.circle,       c.fgTertiary,  'Pendiente',     ShadBadgeVariant.neutral),
      };

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _WeekendSection extends StatelessWidget {
  final List<DayAttendance> days;
  final DateFormat dayFmt;
  final DateFormat timeFmt;
  const _WeekendSection({
    required this.days, required this.dayFmt, required this.timeFmt,
  });

  @override
  Widget build(BuildContext context) {
    final c        = context.colors;
    final totalMin = days.fold<int>(0, (s, d) => s + d.overtimeMinutes);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(LucideIcons.calendarClock, size: 13, color: c.overtime),
        const SizedBox(width: 7),
        Text('Fin de semana', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: c.foreground)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: c.overtime.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppColors.radiusSm),
            border: Border.all(color: c.overtime.withOpacity(0.25)),
          ),
          child: Text('+${_fmtDuration(totalMin)} extra',
              style: TextStyle(fontSize: 11, color: c.overtime,
                  fontWeight: FontWeight.w500)),
        ),
        const Spacer(),
        Text('No afecta al bono',
            style: TextStyle(fontSize: 10, color: c.fgTertiary,
                fontStyle: FontStyle.italic)),
      ]),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: c.overtime.withOpacity(0.20)),
          borderRadius: BorderRadius.circular(AppColors.radius),
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: c.overtime.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft:  Radius.circular(AppColors.radius),
                topRight: Radius.circular(AppColors.radius),
              ),
            ),
            child: Row(children: [
              const SizedBox(width: 36),
              Expanded(flex: 3, child: Text('Día',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: c.mutedFg))),
              Expanded(flex: 2, child: Text('Entrada', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: c.mutedFg))),
              Expanded(flex: 2, child: Text('Salida', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: c.mutedFg))),
              Expanded(flex: 2, child: Text('Total', textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: c.mutedFg))),
            ]),
          ),
          ...days.asMap().entries.map((e) => _WeekendRow(
            day:     e.value,
            dayFmt:  dayFmt,
            timeFmt: timeFmt,
            isLast:  e.key == days.length - 1,
          )),
        ]),
      ),
    ]);
  }
}

class _WeekendRow extends StatelessWidget {
  final DayAttendance day;
  final DateFormat dayFmt;
  final DateFormat timeFmt;
  final bool isLast;
  const _WeekendRow({
    required this.day, required this.dayFmt,
    required this.timeFmt, required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final c          = context.colors;
    final borderRadius = isLast
        ? const BorderRadius.only(
        bottomLeft:  Radius.circular(AppColors.radius),
        bottomRight: Radius.circular(AppColors.radius))
        : BorderRadius.zero;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: isLast ? null : Border(
            bottom: BorderSide(color: c.overtime.withOpacity(0.15), width: 0.5)),
      ),
      child: Row(children: [
        Icon(LucideIcons.calendarClock, size: 14, color: c.overtime),
        const SizedBox(width: 10),
        Expanded(flex: 3, child: Text(
            _cap(dayFmt.format(day.date)),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c.foreground))),
        Expanded(flex: 2, child: Text(
            day.entryTime != null ? timeFmt.format(day.entryTime!) : '—',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c.foreground,
                fontFeatures: const [FontFeature.tabularFigures()]))),
        Expanded(flex: 2, child: Text(
            day.exitTime != null ? timeFmt.format(day.exitTime!) : '—',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c.foreground,
                fontFeatures: const [FontFeature.tabularFigures()]))),
        Expanded(flex: 2, child: Text(
            '+${_fmtDuration(day.overtimeMinutes)}',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.overtime))),
      ]),
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─── Valor de tiempo con color de puntualidad ─────────────────────────────────
class _TimeVal extends StatelessWidget {
  final String time;
  final bool ok;
  final bool hasTime;
  const _TimeVal({required this.time, required this.ok, required this.hasTime});

  @override
  Widget build(BuildContext context) {
    final c     = context.colors;
    final color = !hasTime ? c.fgTertiary : ok ? c.foreground : c.warning;
    return Text(time, textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color,
            fontFeatures: const [FontFeature.tabularFigures()]));
  }
}

// ─── Helper ───────────────────────────────────────────────────────────────────
String _fmtDuration(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes  % 60;
  if (h == 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}