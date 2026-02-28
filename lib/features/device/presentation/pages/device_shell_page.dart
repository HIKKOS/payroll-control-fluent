import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nomina_control/features/device/domain/entities/device_user.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../attendance/presentation/pages/attendance_page.dart';
import '../bloc/device_bloc.dart';
import 'device_connection_page.dart';
import 'device_users_page.dart';

/// Shell principal de la app tras autenticarse.
/// Usa [NavigationView] con panel lateral compacto expandible —
/// el patrón correcto para dashboards desktop en Fluent UI.
class DeviceShellPage extends StatefulWidget {
  const DeviceShellPage({super.key});

  @override
  State<DeviceShellPage> createState() => _DeviceShellPageState();
}

class _DeviceShellPageState extends State<DeviceShellPage> {
  int _selectedIndex = 0;

  // Los índices deben coincidir con el orden de [NavigationView.pane.items]
  static const int _usersIndex = 0;
  static const int _attendanceIndex = 1;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          serviceLocator<DeviceBloc>()..add(const DeviceUsersLoadRequested()),
      child: BlocConsumer<DeviceBloc, DeviceState>(
        listener: (context, state) {
          if (state is DeviceLoggedOut) {
            Navigator.of(context).pushAndRemoveUntil(
              FluentPageRoute(builder: (_) => const DeviceConnectionPage()),
              (_) => false,
            );
          }
        },
        builder: (context, state) {
          final users =
              state is DeviceUsersLoaded ? state.users : const <DeviceUser>[];

          return NavigationView(
            titleBar: TitleBar(
              // Sin título en el appbar — el panel lateral lleva la marca
              title: const SizedBox.shrink(),

              endHeader: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // ── Indicador de conexión ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.success.withOpacity(0.6),
                                    blurRadius: 4)
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('Conectado',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // ── Botón logout ───────────────────────────────────────
                    Tooltip(
                      message: 'Cerrar sesión',
                      child: IconButton(
                        icon: const Icon(FluentIcons.sign_out,
                            size: 16, color: AppColors.textSecondary),
                        onPressed: () => context
                            .read<DeviceBloc>()
                            .add(const DeviceLogoutRequested()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pane: NavigationPane(
              selected: _selectedIndex,
              onChanged: (i) => setState(() => _selectedIndex = i),
              displayMode: PaneDisplayMode.compact,
              size: const NavigationPaneSize(openWidth: 220, compactWidth: 52),
              header: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.cyanGlow,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.cyan, width: 1),
                      ),
                      child: const Icon(FluentIcons.fingerprint,
                          color: AppColors.cyan, size: 15),
                    ),
                    const SizedBox(width: 10),
                    const Flexible(
                      child: Text(
                        'NóminaControl',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              items: [
                PaneItem(
                  icon: const Icon(FluentIcons.people),
                  title: const Text('Empleados'),
                  body: const DeviceUsersBody(),
                ),
                PaneItem(
                  icon: const Icon(FluentIcons.calendar_week),
                  title: const Text('Semana laboral'),
                  body: users.isEmpty
                      ? const _LoadingBody()
                      : AttendancePage(users: users),
                  infoBadge: users.isNotEmpty
                      ? InfoBadge(
                          source: Text('${users.length}'),
                        )
                      : null,
                ),
              ],
              footerItems: [
                PaneItemSeparator(),
                PaneItem(
                  icon: const Icon(FluentIcons.settings),
                  title: const Text('Configuración'),
                  body: const _SettingsPlaceholder(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProgressRing(),
          SizedBox(height: 16),
          Text('Cargando empleados…',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SettingsPlaceholder extends StatelessWidget {
  const _SettingsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Configuración — próximamente',
          style: TextStyle(color: AppColors.textSecondary)),
    );
  }
}
