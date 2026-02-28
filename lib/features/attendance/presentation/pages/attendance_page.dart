import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../device/domain/entities/device_user.dart';
import '../../../device/presentation/pages/device_connection_page.dart';
import '../../../settings/domain/entities/work_schedule_config.dart';
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
      child: const _AttendanceView(),
    );
  }
}

class _AttendanceView extends StatelessWidget {
  const _AttendanceView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semana laboral'),
        actions: [
          // ── Botón sync local ────────────────────────────────────────────
          BlocBuilder<AttendanceBloc, AttendanceState>(
            builder: (context, state) {
              if (state is AttendanceSyncing) {
                return const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return IconButton(
                tooltip: 'Descargar accesos localmente',
                icon: const Icon(Icons.download_outlined),
                onPressed: () => context
                    .read<AttendanceBloc>()
                    .add(const AttendanceSyncLocalRequested()),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceSyncSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✓ ${state.totalRecords} registros descargados localmente.',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is AttendanceError && state.requiresReconnect) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const DeviceConnectionPage()),
              (_) => false,
            );
          }
          if (state is AttendanceError && !state.requiresReconnect) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          // ── Loading ────────────────────────────────────────────────────
          if (state is AttendanceLoading || state is AttendanceInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Loaded ─────────────────────────────────────────────────────
          if (state is AttendanceLoaded) {
            return _LoadedBody(state: state);
          }

          // ── Syncing ────────────────────────────────────────────────────
          if (state is AttendanceSyncing) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(state.message),
                ],
              ),
            );
          }

          // ── Error ──────────────────────────────────────────────────────
          if (state is AttendanceError) {
            return _ErrorBody(message: state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final AttendanceLoaded state;

  const _LoadedBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AttendanceBloc>().add(
              AttendanceWeekSelected(
                weekStart: state.weekStart,
                weekEnd: state.weekEnd,
              ),
            );
      },
      child: CustomScrollView(
        slivers: [
          // ── Selector de semana ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.date_range,
                          color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: WeekSelectorWidget(
                          selectedStart: state.weekStart,
                          selectedEnd: state.weekEnd,
                          config: state.config,
                          onWeekSelected: (start, end) =>
                              context.read<AttendanceBloc>().add(
                                    AttendanceWeekSelected(
                                      weekStart: start,
                                      weekEnd: end,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Banner de datos locales ────────────────────────────────────
          if (state.isLocalData)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.offline_pin,
                          size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Mostrando datos descargados localmente',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Resumen general ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _WeekSummaryHeader(state: state),
          ),

          // ── Lista de empleados ─────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final weekData = state.weekData[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: EmployeeWeekCard(
                      week: weekData,
                      onTap: () => EmployeeWeekDetailSheet.show(
                        context,
                        weekData,
                        state.config,
                      ),
                    ),
                  );
                },
                childCount: state.weekData.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekSummaryHeader extends StatelessWidget {
  final AttendanceLoaded state;

  const _WeekSummaryHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalUsers = state.weekData.length;
    final withBonus  = state.weekData.where((w) => w.qualifiesForBonus).length;
    final withExtra  = state.weekData.where((w) => w.totalOvertimeMinutes > 0).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _StatPill(
            label: 'Con bono',
            value: '$withBonus/$totalUsers',
            color: Colors.green,
            icon: Icons.star_rounded,
          ),
          const SizedBox(width: 8),
          _StatPill(
            label: 'Con extra',
            value: '$withExtra',
            color: Colors.orange,
            icon: Icons.access_time_filled,
          ),
          const Spacer(),
          if (state.isCurrentWeek)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Semana actual',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;

  const _ErrorBody({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context
                  .read<AttendanceBloc>()
                  .add(const AttendanceLoadCurrentWeek()),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
