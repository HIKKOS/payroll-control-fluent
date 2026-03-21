import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:nomina_control/core/theme/app_colors.dart';
import 'package:nomina_control/features/device/domain/entities/device_user.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../attendance/presentation/pages/attendance_page.dart';
import '../../../session/domain/repositories/session_repository.dart';
import '../bloc/device_bloc.dart';
import 'device_connection_page.dart';
import 'device_users_page.dart';

class DeviceShellPage extends StatefulWidget {
  /// [offlineMode] = true cuando no se pudo alcanzar el dispositivo al arrancar.
  /// El shell funciona pero solo muestra datos de Drift.
  final bool offlineMode;

  const DeviceShellPage({super.key, this.offlineMode = false});

  @override
  State<DeviceShellPage> createState() => _DeviceShellPageState();
}

class _DeviceShellPageState extends State<DeviceShellPage> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<DeviceBloc>()
        ..add(widget.offlineMode
            ? const DeviceOfflineLoadRequested()
            : const DeviceUsersLoadRequested()),
      child: BlocConsumer<DeviceBloc, DeviceState>(
        listener: (ctx, state) {
          if (state is DeviceLoggedOut) {
            serviceLocator<SessionRepository>().clearSession();
            Navigator.of(ctx).pushAndRemoveUntil(
              FluentPageRoute(builder: (_) => const DeviceConnectionPage()),
              (_) => false,
            );
          }
          // Si expira la sesión estando online, también borrar y redirigir
          if (state is DeviceError && state.requiresReconnect) {
            serviceLocator<SessionRepository>().clearSession();
            Navigator.of(ctx).pushAndRemoveUntil(
              FluentPageRoute(builder: (_) => const DeviceConnectionPage()),
              (_) => false,
            );
          }
        },
        builder: (ctx, state) {
          final users =
              state is DeviceUsersLoaded ? state.users : <DeviceUser>[];
          final isOffline = widget.offlineMode ||
              (state is DeviceUsersLoaded && state.fromCache);

          return NavigationView(
            titleBar: TitleBar(
              title: const SizedBox.shrink(),
              endHeader: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  // ── Badge de estado de red ──────────────────────────────
                  _ConnectionBadge(offline: isOffline),
                  if (!isOffline) const SizedBox(width: 8),
                  // Logout solo disponible online
                  if (!isOffline)
                    Tooltip(
                      message: 'Cerrar sesión',
                      child: IconButton(
                        icon: Icon(LucideIcons.logOut,
                            size: 15, color: context.colors.mutedFg),
                        onPressed: () => ctx
                            .read<DeviceBloc>()
                            .add(const DeviceLogoutRequested()),
                      ),
                    ),
                ]),
              ),
            ),
            pane: NavigationPane(
              selected: _idx,
              onChanged: (i) => setState(() => _idx = i),
              displayMode: PaneDisplayMode.compact,
              size: const NavigationPaneSize(openWidth: 210, compactWidth: 50),
              header: SizedBox(
                height: 20,
                child: Row(children: [
                  Icon(LucideIcons.fingerprintPattern,
                      size: 13, color: context.colors.foreground),
                  const SizedBox(width: 9),
                  Flexible(
                      child: Text('Control de accesos',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: context.colors.foreground),
                          overflow: TextOverflow.ellipsis)),
                ]),
              ),
              items: [
                PaneItem(
                  icon: const Icon(LucideIcons.calendarDays),
                  title: const Text('Semana laboral'),
                  infoBadge: users.isNotEmpty
                      ? InfoBadge(source: Text('${users.length}'))
                      : null,
                  body: users.isEmpty
                      ? const Center(child: ProgressRing())
                      : AttendancePage(
                          users: users,
                          isOffline: isOffline,
                        ),
                ),
                PaneItem(
                  icon: const Icon(LucideIcons.users),
                  title: const Text('Empleados'),
                  body: const DeviceUsersBody(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Badge de conexión ──────────────────────────────────────────────────────────
class _ConnectionBadge extends StatelessWidget {
  final bool offline;

  const _ConnectionBadge({required this.offline});

  @override
  Widget build(BuildContext context) {
    if (offline) {
      return Row(
        spacing: 8,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.warningMuted,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: context.colors.warningBorder),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(LucideIcons.wifiOff,
                  size: 11, color: context.colors.warning),
              const SizedBox(width: 5),
              Text('Sin conexión · datos locales',
                  style: TextStyle(
                      fontSize: 11,
                      color: context.colors.warning,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
          IconButton(
            icon: const Icon(LucideIcons.refreshCcw),
            onPressed: () {
              // Forzar recarga online (si es posible)
              // Esto es útil si el dispositivo se inició offline pero luego se conectó.
              // O si hubo un error temporal en la conexión.
              // El bloc decidirá si puede cargar online o no.
              context.read<DeviceBloc>().add(const DeviceUsersLoadRequested());
            },
          )
        ],
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.successMuted,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: context.colors.successBorder),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
                color: context.colors.success, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text('Conectado',
            style: TextStyle(
                fontSize: 11,
                color: context.colors.success,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
