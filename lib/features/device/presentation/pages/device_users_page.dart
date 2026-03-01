import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/dash_widgets.dart';
import '../bloc/device_bloc.dart';

class DeviceUsersBody extends StatelessWidget {
  const DeviceUsersBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceBloc, DeviceState>(
      builder: (ctx, state) {
        if (state is DeviceUsersLoading || state is DeviceInitial) {
          return const Center(child: ProgressRing());
        }
        if (state is DeviceError) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.wifiOff, size: 40, color: ShadNeutral.mutedFg),
            const SizedBox(height: 14),
            Text(state.message,
                style: const TextStyle(color: ShadNeutral.mutedFg, fontSize: 13)),
            const SizedBox(height: 18),
            ShadSecondaryButton(
              label: 'Reintentar', icon: LucideIcons.refreshCw,
              onPressed: () => ctx.read<DeviceBloc>().add(const DeviceUsersLoadRequested()),
            ),
          ]));
        }
        if (state is DeviceUsersLoaded) return _UsersGrid(users: state.users);
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
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.users.where((u) {
      final q = _q.toLowerCase();
      return q.isEmpty ||
          u.name.toLowerCase().contains(q) ||
          u.registration.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ShadSectionHeader(
          title: 'Empleados',
          description: '${widget.users.length} registrados en el dispositivo',
          trailing: Row(children: [
            SizedBox(
              width: 220,
              child: TextBox(
                placeholder: 'Buscar…',
                prefix: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(LucideIcons.search, size: 13, color: ShadNeutral.mutedFg)),
                onChanged: (v) => setState(() => _q = v),
                style: const TextStyle(fontSize: 12, color: ShadNeutral.foreground),
                decoration: WidgetStatePropertyAll(BoxDecoration(
                  color: ShadNeutral.card,
                  borderRadius: BorderRadius.circular(ShadNeutral.radius),
                  border: Border.all(color: ShadNeutral.border),
                )),
              ),
            ),
            const SizedBox(width: 8),
            ShadIconButton(
              icon: LucideIcons.refreshCw, tooltip: 'Actualizar',
              onPressed: () => context.read<DeviceBloc>().add(const DeviceUsersLoadRequested()),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        if (filtered.isEmpty)
          Expanded(child: Center(child: Text(
            _q.isEmpty ? 'Sin empleados' : 'Sin resultados para "$_q"',
            style: const TextStyle(color: ShadNeutral.mutedFg, fontSize: 13),
          )))
        else
          Expanded(child: LayoutBuilder(builder: (_, c) {
            final cols = (c.maxWidth / 210).floor().clamp(2, 6);
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols, mainAxisSpacing: 8,
                crossAxisSpacing: 8, childAspectRatio: 2.8,
              ),
              itemCount: filtered.length,
              itemBuilder: (_, i) => _UserCard(user: filtered[i]),
            );
          })),
      ]),
    );
  }
}

class _UserCard extends StatelessWidget {
  final dynamic user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = user.name.trim().split(' ')
        .take(2).map((w) => (w as String)[0].toUpperCase()).join();

    return ShadCard(
      hoverable: true,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        // Avatar
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: ShadNeutral.muted,
            borderRadius: BorderRadius.circular(ShadNeutral.radiusSm),
            border: Border.all(color: ShadNeutral.border),
          ),
          child: Center(child: Text(initials,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: ShadNeutral.foreground))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(user.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                  color: ShadNeutral.foreground),
              overflow: TextOverflow.ellipsis),
            Text(
              user.registration.isNotEmpty ? '#${user.registration}' : 'ID ${user.id}',
              style: const TextStyle(fontSize: 11, color: ShadNeutral.mutedFg)),
          ],
        )),
      ]),
    );
  }
}
