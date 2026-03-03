import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:nomina_control/shared/widgets/dash_widgets.dart';
import '../../../../core/theme/app_theme.dart';
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
      listener: (ctx, state) {
        if (state is AttendanceSyncSuccess) {
          displayInfoBar(ctx,
              builder: (c, close) => InfoBar(
                    title: const Text('Sync completado'),
                    content: Text(
                        '${state.totalRecords} registros guardados localmente.'),
                    severity: InfoBarSeverity.success,
                    onClose: close,
                  ));
        }
        if (state is AttendanceError) {
          displayInfoBar(ctx,
              builder: (c, close) => InfoBar(
                    title: const Text('Error'),
                    content: Text(state.message),
                    severity: InfoBarSeverity.error,
                    onClose: close,
                  ));
        }
      },
      builder: (ctx, state) {
        if (state is AttendanceLoading || state is AttendanceInitial) {
          return const Center(child: ProgressRing());
        }
        if (state is AttendanceSyncing) {
          return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            const ProgressRing(),
            const SizedBox(height: 16),
            Text(state.message,
                style:
                    const TextStyle(color: ShadNeutral.mutedFg, fontSize: 13)),
          ]));
        }
        if (state is AttendanceLoaded) return _LoadedLayout(state: state);
        if (state is AttendanceError) {
          return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.serverOff,
                size: 40, color: ShadNeutral.mutedFg),
            const SizedBox(height: 14),
            Text(state.message,
                style: const TextStyle(color: ShadNeutral.mutedFg)),
            const SizedBox(height: 18),
            ShadSecondaryButton(
              label: 'Reintentar',
              icon: LucideIcons.refreshCw,
              onPressed: () => ctx
                  .read<AttendanceBloc>()
                  .add(const AttendanceLoadCurrentWeek()),
            ),
          ]));
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
    String query = "";

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ──────────────────────────────────────────────────────────
        ShadSectionHeader(
          title: 'Semana laboral',
          description:
              state.isCurrentWeek ? 'Semana en curso' : 'Semana histórica',
          trailing: Row(children: [
            if (state.isLocalData)
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: ShadBadge(
                  label: 'Datos locales',
                  variant: ShadBadgeVariant.neutral,
                  icon: LucideIcons.hardDrive,
                ),
              ),
            WeekSelectorWidget(
              selectedStart: state.weekStart,
              selectedEnd: state.weekEnd,
              config: state.config,
              onWeekSelected: (s, e) => context.read<AttendanceBloc>().add(
                    AttendanceWeekSelected(weekStart: s, weekEnd: e),
                  ),
            ),
            const SizedBox(width: 8),
            ShadSecondaryButton(
              label: 'Sync local',
              icon: LucideIcons.cloudDownload,
              onPressed: () => context
                  .read<AttendanceBloc>()
                  .add(const AttendanceSyncLocalRequested()),
            ),
            const SizedBox(width: 6),
            ShadIconButton(
              icon: LucideIcons.refreshCw,
              tooltip: 'Actualizar',
              onPressed: () => context.read<AttendanceBloc>().add(
                  AttendanceWeekSelected(
                      weekStart: state.weekStart, weekEnd: state.weekEnd)),
            ),
          ]),
        ),

        const SizedBox(height: 20),
        Expanded(
          child: StatefulBuilder(builder: (context, setState) {
            final filtered = state.weekData.where((weekAtt) {
              final u = weekAtt.userName;
              return u.isEmpty || u.toLowerCase().contains(query);
            }).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize:  MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Mostrando solo usuarios activos",
                            style: TextStyle(
                              fontSize: 16,
                            )),
                        const SizedBox(width: 12),
                        Tooltip(message: state.hideAbsences
                            ? 'Se están ocultando los usuarios que no tuvieron registros en la semana seleccionada.'
                            : 'Mostrando todos los usuarios, incluyendo los que no tuvieron registros en la semana seleccionada.',child: const Icon(LucideIcons.info, size: 14, color: ShadNeutral.mutedFg)),
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.3,
                      child: TextBox(
                        placeholder: 'Buscar…',
                        prefix: const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(LucideIcons.search,
                                size: 13, color: ShadNeutral.mutedFg)),
                        onChanged: (v) => setState(() => query = v),
                        style: const TextStyle(
                            fontSize: 12, color: ShadNeutral.foreground),
                        decoration: WidgetStatePropertyAll(BoxDecoration(
                          color: ShadNeutral.card,
                          borderRadius:
                              BorderRadius.circular(ShadNeutral.radius),
                          border: Border.all(color: ShadNeutral.border),
                        )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Grid de empleados ────────────────────────────────────────────────
                Expanded(child: LayoutBuilder(builder: (_, c) {
                  final cols = (c.maxWidth / 320).floor().clamp(1, 4);
                  if (filtered.isEmpty) {
                    return SizedBox(
                      width: c.maxWidth,
                      child: Column(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                query.isEmpty
                                    ? LucideIcons.timerOff
                                    : LucideIcons.search,
                                size: 80,
                                color: ShadNeutral.mutedFg),
                            Text(
                              query.isEmpty
                                  ? 'No hay registros'
                                  : 'Sin resultados para "$query"',
                              style: const TextStyle(
                                  color: ShadNeutral.mutedFg, fontSize: 24),
                            ),
                          ]),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 210,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final w = filtered[i];
                      return EmployeeWeekCard(
                        week: w,
                        onTap: () => EmployeeWeekDetailSheet.show(
                            context, w, state.config),
                      );
                    },
                  );
                })),
              ],
            );
          }),
        ),
        // ── KPIs ────────────────────────────────────────────────────────────
      ]),
    );
  }
}
