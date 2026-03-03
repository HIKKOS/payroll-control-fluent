import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nomina_control/core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/dash_widgets.dart';
import '../bloc/device_bloc.dart';

/// Body de empleados que vive dentro del NavigationView.
/// Ya no es una página independiente — es un widget cuerpo del shell.
class DeviceUsersBody extends StatelessWidget {
  const DeviceUsersBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceBloc, DeviceState>(
      builder: (context, state) {
        if (state is DeviceUsersLoading || state is DeviceInitial) {
          return const Center(child: ProgressRing());
        }
        if (state is DeviceError) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(FluentIcons.error_badge, size: 48, color: context.colors.destructive),
              const SizedBox(height: 16),
              Text(state.message, style:   TextStyle(color: context.colors.mutedFg)),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.read<DeviceBloc>().add(const DeviceUsersLoadRequested()),
                child: const Text('Reintentar'),
              ),
            ]),
          );
        }
        if (state is DeviceUsersLoaded) {
          return _UsersGrid(users: state.users);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _UsersGrid extends StatefulWidget {
  final List users;
  const _UsersGrid({required this.users});

  @override
  State<_UsersGrid> createState() => _UsersGridState();
}

class _UsersGridState extends State<_UsersGrid> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.users.where((u) {
      final q = _search.toLowerCase();
      return q.isEmpty ||
          u.name.toLowerCase().contains(q) ||
          u.registration.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ──────────────────────────────────────────────────────────
        ShadSectionHeader(
          title: 'Empleados',

          trailing: Row(children: [
            SizedBox(
              width: 240,
              child: TextBox(
                placeholder: 'Buscar por nombre o registro…',
                prefix:   Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(FluentIcons.search, size: 13, color: context.colors.muted),
                ),
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            Tooltip(
              message: 'Actualizar',
              child: IconButton(
                icon:   Icon(FluentIcons.refresh, size: 16, color: context.colors.mutedFg),
                onPressed: () => context.read<DeviceBloc>().add(const DeviceUsersLoadRequested()),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 24),

        // ── Grid ─────────────────────────────────────────────────────────────
        if (filtered.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                _search.isEmpty ? 'Sin empleados registrados' : 'Sin resultados para "$_search"',
                style:   TextStyle(color: context.colors.muted, fontSize: 13),
              ),
            ),
          )
        else
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossCount = (constraints.maxWidth / 220).floor().clamp(2, 6);
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _UserCard(user: filtered[i]),
                );
              },
            ),
          ),
      ]),
    );
  }
}

class _UserCard extends StatefulWidget {
  final dynamic user;
  const _UserCard({required this.user});

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final initials = widget.user.name.isNotEmpty
        ? widget.user.name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : '?';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // color: _hovered ? ShadNeutral.bg3 : AppColors.bg2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            // color: _hovered ? AppColors.cyan.withOpacity(0.5) : AppColors.bgBorder,
          ),
          boxShadow: _hovered
              ? [/*BoxShadow(color: AppColors.cyanGlow, blurRadius: 8)*/]
              : [],
        ),
        child: Row(children: [
          // Avatar con iniciales
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              // color: AppColors.cyanGlow,
              borderRadius: BorderRadius.circular(8),
              // border: Border.all(color: AppColors.cyan.withOpacity(0.5)),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  // color: AppColors.cyan, letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(
                widget.user.name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, /*color: AppColors.textPrimary*/),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                widget.user.registration.isNotEmpty ? '#${widget.user.registration}' : 'ID: ${widget.user.id}',
                style: const TextStyle(fontSize: 11, /*color: AppColors.textSecondary*/),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}