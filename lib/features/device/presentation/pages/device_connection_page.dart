import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/device_bloc.dart';
import 'device_users_page.dart';

/// Pantalla donde el usuario ingresa la IP, puerto, login y contraseña
/// del dispositivo ControlID para conectarse.
class DeviceConnectionPage extends StatelessWidget {
  const DeviceConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<DeviceBloc>(),
      child: const _DeviceConnectionView(),
    );
  }
}

class _DeviceConnectionView extends StatefulWidget {
  const _DeviceConnectionView();

  @override
  State<_DeviceConnectionView> createState() => _DeviceConnectionViewState();
}

class _DeviceConnectionViewState extends State<_DeviceConnectionView> {
  final _formKey = GlobalKey<FormState>();

  final _hostController     = TextEditingController(text: '127.0.0.1');
  final _portController     = TextEditingController(text: '3001');
  final _loginController    = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<DeviceBloc>().add(
      DeviceAuthRequested(
        host:     _hostController.text.trim(),
        port:     int.tryParse(_portController.text.trim()),
        login:    _loginController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<DeviceBloc, DeviceState>(
        listener: (context, state) {
          if (state is DeviceAuthenticated) {
            // Navegamos reemplazando la ruta para que no haya "back" al login
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DeviceUsersPage()),
            );
          }
          if (state is DeviceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is DeviceAuthenticating;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Encabezado ──────────────────────────────────────
                      const Icon(
                        Icons.fingerprint,
                        size: 72,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Conectar dispositivo',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingresa los datos de acceso del ControlID en tu red local.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // ── Host ────────────────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _hostController,
                              decoration: const InputDecoration(
                                labelText: 'IP / Host',
                                hintText: '192.168.1.100',
                                prefixIcon: Icon(Icons.router_outlined),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.url,
                              enabled: !isLoading,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Ingresa la IP del dispositivo';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _portController,
                              decoration: const InputDecoration(
                                labelText: 'Puerto',
                                hintText: '80',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              enabled: !isLoading,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Requerido';
                                if (int.tryParse(v.trim()) == null) return 'Inválido';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Login ───────────────────────────────────────────
                      TextFormField(
                        controller: _loginController,
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          hintText: 'admin',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        enabled: !isLoading,
                        validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Ingresa el usuario' : null,
                      ),
                      const SizedBox(height: 16),

                      // ── Password ────────────────────────────────────────
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        enabled: !isLoading,
                        validator: (v) =>
                        (v == null || v.isEmpty) ? 'Ingresa la contraseña' : null,
                      ),
                      const SizedBox(height: 32),

                      // ── Botón ───────────────────────────────────────────
                      FilledButton.icon(
                        onPressed: isLoading ? null : () => _submit(context),
                        icon: isLoading
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(Icons.login),
                        label: Text(isLoading ? 'Conectando…' : 'Conectar'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}