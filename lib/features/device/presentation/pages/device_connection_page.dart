import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:nomina_control/core/theme/app_colors.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/dash_widgets.dart';
import '../../../../injection_container.dart';
import '../../../session/domain/entities/saved_session.dart';
import '../../../session/domain/repositories/session_repository.dart';
import '../bloc/device_bloc.dart';
import 'device_shell_page.dart';

class DeviceConnectionPage extends StatelessWidget {
  const DeviceConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<DeviceBloc>(),
      child: const _ConnectionView(),
    );
  }
}

class _ConnectionView extends StatefulWidget {
  const _ConnectionView();
  @override State<_ConnectionView> createState() => _ConnectionViewState();
}

class _ConnectionViewState extends State<_ConnectionView> {
  final _hostCtrl  = TextEditingController(text: '127.0.0.1');
  final _portCtrl  = TextEditingController(text: '3001');
  final _loginCtrl = TextEditingController(text: 'admin');
  final _passCtrl  = TextEditingController(text: 'admin');
  bool _obscure    = true;
  String? _hostErr, _loginErr, _passErr;

  @override
  void dispose() {
    _hostCtrl.dispose(); _portCtrl.dispose();
    _loginCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _hostErr  = _hostCtrl.text.trim().isEmpty  ? 'Requerido' : null;
      _loginErr = _loginCtrl.text.trim().isEmpty ? 'Requerido' : null;
      _passErr  = _passCtrl.text.isEmpty         ? 'Requerido' : null;
    });
    return _hostErr == null && _loginErr == null && _passErr == null;
  }

  void _submit(BuildContext ctx) {
    if (!_validate()) return;
    ctx.read<DeviceBloc>().add(DeviceAuthRequested(
      host:     _hostCtrl.text.trim(),
      port:     int.tryParse(_portCtrl.text.trim()) ?? 80,
      login:    _loginCtrl.text.trim(),
      password: _passCtrl.text,
    ));
  }

  Future<void> _onAuthenticated(BuildContext ctx) async {
    // Persistir credenciales para el arranque inteligente futuro
    await serviceLocator<SessionRepository>().saveSession(SavedSession(
      host:        _hostCtrl.text.trim(),
      port:        int.tryParse(_portCtrl.text.trim()) ?? 80,
      login:       _loginCtrl.text.trim(),
      password:    _passCtrl.text,
      lastLoginAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    ));
    if (!ctx.mounted) return;
    Navigator.of(ctx).pushReplacement(
      FluentPageRoute(builder: (_) => const DeviceShellPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeviceBloc, DeviceState>(
      listener: (ctx, state) {
        if (state is DeviceAuthenticated) _onAuthenticated(ctx);
        if (state is DeviceError) {
          displayInfoBar(ctx, builder: (_, close) => InfoBar(
            title: const Text('Error de conexión'),
            content: Text(state.message),
            severity: InfoBarSeverity.error,
            onClose: close,
          ));
        }
      },
      builder: (ctx, state) {
        final loading = state is DeviceAuthenticating;
        return ScaffoldPage(
          content: Center(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: context.colors.card,
                        borderRadius: BorderRadius.circular(radius),
                        border: Border.all(color: context.colors.border),
                      ),
                      child:   Icon(LucideIcons.fingerprintPattern, size: 18,
                          color: context.colors.foreground),
                    ),
                    const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('NóminaControl', style: TextStyle(fontSize: 18,
                          fontWeight: FontWeight.w600, color: context.colors.foreground,
                          letterSpacing: -0.3)),
                      Text('Control de Asistencia',
                          style: TextStyle(fontSize: 12, color: context.colors.mutedFg)),
                    ]),
                  ]),
                  const SizedBox(height: 32),

                  ShadCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Conectar dispositivo', style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600,
                          color: context.colors.foreground)),
                      const SizedBox(height: 4),
                        Text('Datos del ControlID en tu red local',
                          style: TextStyle(fontSize: 12, color: context.colors.mutedFg)),
                      const SizedBox(height: 20),
                      const ShadDivider(),
                      const SizedBox(height: 20),

                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(flex: 3, child: ShadInputField(
                          label: 'IP / Host', placeholder: '192.168.1.100',
                          controller: _hostCtrl, prefixIcon: LucideIcons.server,
                          error: _hostErr, enabled: !loading,
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: ShadInputField(
                          label: 'Puerto', placeholder: '80',
                          controller: _portCtrl, enabled: !loading,
                        )),
                      ]),
                      const SizedBox(height: 14),
                      ShadInputField(
                        label: 'Usuario', placeholder: 'admin',
                        controller: _loginCtrl, prefixIcon: LucideIcons.user,
                        error: _loginErr, enabled: !loading,
                      ),
                      const SizedBox(height: 14),
                      ShadInputField(
                        label: 'Contraseña', placeholder: '••••••••',
                        controller: _passCtrl, prefixIcon: LucideIcons.lock,
                        obscure: _obscure, error: _passErr, enabled: !loading,
                        onSubmitted: (_) => _submit(ctx),
                        suffix: IconButton(
                          icon: Icon(
                            _obscure ? LucideIcons.eye : LucideIcons.eyeOff,
                            size: 13, color: context.colors.mutedFg,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ShadPrimaryButton(
                          label: 'Conectar',
                          icon: LucideIcons.plugZap,
                          onPressed: loading ? null : () => _submit(ctx),
                          loading: loading,
                          height: 40,
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                    Center(child: Text('ControlID Flex · HTTP API',
                      style: TextStyle(fontSize: 11, color: context.colors.fgTertiary))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
