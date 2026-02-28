import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/device_user.dart';
import '../bloc/device_bloc.dart';
import 'device_connection_page.dart';

/// Pantalla que muestra los usuarios registrados en el ControlID.
/// Se carga automáticamente al montarse y soporta pull-to-refresh.
class DeviceUsersPage extends StatelessWidget {
  const DeviceUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Reutilizamos el mismo BLoC singleton del repositorio para mantener
    // la sesión activa. Lo proveemos de nuevo por si la página se abre
    // en un contexto diferente.
    return BlocProvider(
      create: (_) => serviceLocator<DeviceBloc>()..add(const DeviceUsersLoadRequested()),
      child: const _DeviceUsersView(),
    );
  }
}

class _DeviceUsersView extends StatelessWidget {
  const _DeviceUsersView();

  void _logout(BuildContext context) {
    context.read<DeviceBloc>().add(const DeviceLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios en dispositivo'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => context
                .read<DeviceBloc>()
                .add(const DeviceUsersLoadRequested()),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: BlocConsumer<DeviceBloc, DeviceState>(
        listener: (context, state) {
          // Sesión expirada o logout → regresamos a la pantalla de conexión
          if (state is DeviceLoggedOut ||
              (state is DeviceError && state.requiresReconnect)) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const DeviceConnectionPage(),
              ),
                  (_) => false,
            );
          }
          if (state is DeviceError && !state.requiresReconnect) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DeviceUsersLoading || state is DeviceLoggingOut) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DeviceUsersLoaded) {
            return _UsersList(users: state.users);
          }

          if (state is DeviceError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<DeviceBloc>()
                  .add(const DeviceUsersLoadRequested()),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ── Widgets internos ─────────────────────────────────────────────────────────

class _UsersList extends StatelessWidget {
  final List<DeviceUser> users;

  const _UsersList({required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay usuarios registrados en el dispositivo.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // El BLoC no tiene contexto aquí; usamos el callback del widget padre
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _UserTile(user: users[index]),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final DeviceUser user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade100,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Registro: ${user.registration.isNotEmpty ? user.registration : "—"}'),
        trailing: Text(
          '#${user.id}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}