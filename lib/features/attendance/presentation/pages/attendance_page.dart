import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/dash_widgets.dart';
import '../../../../injection_container.dart';
import '../../../device/domain/entities/device_user.dart';
import '../bloc/attendance_bloc.dart';
import '../widgets/employee_week_card.dart';
import '../widgets/employee_week_detail_sheet.dart';
import '../widgets/week_selector_widget.dart';

class AttendancePage extends StatelessWidget {
  final List<DeviceUser> users;
  const AttendancePage({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<AttendanceBloc>(param1: users)
        ..add(const AttendanceLoadCurrentWeek()),
      child: const _AttendanceBody(),
    );
  }
}

class _AttendanceBody extends StatelessWidget {
  const _AttendanceBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceSyncSuccess) {
          displayInfoBar(context,
            builder: (ctx, close) => InfoBar(
              title: const Text('Descarga completada'),
              content: Text('${state.totalRecords} registros guardados localmente.'),
              severity: InfoBarSeverity.success,
              onClose: close,
            ),
          );
        }
        if (state is AttendanceError) {
          displayInfoBar(context,
            builder: (ctx, close) => InfoBar(
              title: const Text('Error'),
              content: Text(state.message),
              severity: InfoBarSeverity.error,
              onClose: close,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AttendanceLoading || state is AttendanceInitial) {
          return const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ProgressRing(),
              SizedBox(height: 16),
              Text('Cargando registros…', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ]),
          );
        }

        if (state is AttendanceSyncing) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const ProgressRing(),
              const SizedBox(height: 16),
              Text(state.message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ]),
          );
        }

        if (state is AttendanceLoaded) {
          return _LoadedLayout(state: state);
        }

        if (state is AttendanceError) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(FluentIcons.error_badge, size: 48, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(state.message, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.read<AttendanceBloc>().add(const AttendanceLoadCurrentWeek()),
                child: const Text('Reintentar'),
              ),
            ]),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _LoadedLayout extends StatelessWidget {
  final AttendanceLoaded state;
  const _LoadedLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    final withBonus = state.weekData.where((w) => w.qualifiesForBonus).length;
    final total     = state.weekData.length;
    final withExtra = state.weekData.where((w) => w.totalOvertimeMinutes > 0).length;
    final absent    = state.weekData.where((w) => w.completeDays == 0).length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
          shrinkWrap: true,
            children: [
        //
        // // ── Header con selector de semana ──────────────────────────────────
        Row(children: [
          Expanded(
            child: SectionHeader(
              title: 'Semana laboral',
              subtitle: state.isCurrentWeek ? 'Semana en curso' : 'Semana histórica',
            ),
          ),


          // Badge "datos locales"
          if (state.isLocalData)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: StatusBadge(
                label: 'Datos locales',
                variant: BadgeVariant.neutral,
                icon: FluentIcons.offline_storage,
              ),
            ),

          // Selector de semana
          WeekSelectorWidget(
            selectedStart: state.weekStart,
            selectedEnd: state.weekEnd,
            config: state.config,
            onWeekSelected: (s, e) => context.read<AttendanceBloc>().add(
              AttendanceWeekSelected(weekStart: s, weekEnd: e),
            ),
          ),

          const SizedBox(width: 12),

          // Botón sync local
          Tooltip(
            message: 'Descargar accesos localmente',
            child: Button(
              onPressed: () => context.read<AttendanceBloc>().add(const AttendanceSyncLocalRequested()),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(FluentIcons.download, size: 14),
                SizedBox(width: 6),
                Text('Sync local', style: TextStyle(fontSize: 12)),
              ]),
            ),
          ),

          const SizedBox(width: 8),

          // Refresh
          Tooltip(
            message: 'Actualizar',
            child: IconButton(
              icon: const Icon(FluentIcons.refresh, size: 15, color: AppColors.textSecondary),
              onPressed: () => context.read<AttendanceBloc>().add(
                AttendanceWeekSelected(weekStart: state.weekStart, weekEnd: state.weekEnd),
              ),
            ),
          ),
        ]),

        const SizedBox(height: 20),

        // ── KPI tiles ──────────────────────────────────────────────────────
        Row(children: [
          StatTile(label: 'Con bono', value: '$withBonus / $total', accentColor: AppColors.success, icon: FluentIcons.skype_check),
          const SizedBox(width: 12),
          StatTile(label: 'Sin bono', value: '${total - withBonus}', accentColor: AppColors.danger, icon: FluentIcons.skype_minus),
          const SizedBox(width: 12),
          StatTile(label: 'Horas extra', value: '$withExtra emp.', accentColor: AppColors.overtime, icon: FluentIcons.clock),
          const SizedBox(width: 12),
          StatTile(label: 'Ausencias totales', value: '$absent emp.', accentColor: AppColors.warning, icon: FluentIcons.calendar),
        ]),

        const SizedBox(height: 20),

        // ── Lista de empleados ──────────────────────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = (constraints.maxWidth / 340).floor().clamp(1, 4);
            return GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 210,
              ),
              itemCount: state.weekData.length,
              itemBuilder: (_, i) {
                final week = state.weekData[i];
                return EmployeeWeekCard(
                  week: week,
                  onTap: () => EmployeeWeekDetailSheet.show(context, week, state.config),
                );
              },
            );
          },
        ),
      ]),
    );
  }
}