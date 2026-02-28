import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/dash_widgets.dart';
import '../../../../injection_container.dart';
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

  @override
  State<_ConnectionView> createState() => _ConnectionViewState();
}

class _ConnectionViewState extends State<_ConnectionView> {
  final _hostController     = TextEditingController(text: '127.0.0.1');
  final _portController     = TextEditingController(text: "3001");
  final _loginController    = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'admin');
  bool _obscurePassword     = true;
  String? _hostError;
  String? _loginError;
  String? _passwordError;

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _hostError     = _hostController.text.trim().isEmpty ? 'Ingresa la IP del dispositivo' : null;
      _loginError    = _loginController.text.trim().isEmpty ? 'Ingresa el usuario' : null;
      _passwordError = _passwordController.text.isEmpty ? 'Ingresa la contraseña' : null;
    });
    return _hostError == null && _loginError == null && _passwordError == null;
  }

  void _submit(BuildContext context) {
    if (!_validate()) return;
    context.read<DeviceBloc>().add(DeviceAuthRequested(
      host:     _hostController.text.trim(),
      port:     int.tryParse(_portController.text.trim()) ?? 80,
      login:    _loginController.text.trim(),
      password: _passwordController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeviceBloc, DeviceState>(
      listener: (context, state) {
        if (state is DeviceAuthenticated) {
          Navigator.of(context).pushReplacement(
            FluentPageRoute(builder: (_) => const DeviceShellPage()),
          );
        }
        if (state is DeviceError) {
          displayInfoBar(context,
            builder: (ctx, close) => InfoBar(
              title: const Text('Error de conexión'),
              content: Text(state.message),
              severity: InfoBarSeverity.error,
              onClose: close,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is DeviceAuthenticating;
        return ScaffoldPage(
          content: Stack(children: [
            Positioned.fill(child: CustomPaint(painter: _GridPainter())),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center, radius: 1.2,
                    colors: [Colors.transparent, AppColors.bg0.withOpacity(0.85)],
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.cyanGlow,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cyan, width: 1.5),
                        ),
                        child: const Icon(FluentIcons.fingerprint, color: AppColors.cyan, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('NóminaControl', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                        Text('Sistema de Control de Asistencia', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      ]),
                    ]),
                    const SizedBox(height: 40),
                    DashCard(
                      padding: const EdgeInsets.all(28),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Conectar dispositivo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Ingresa los datos del ControlID en tu red local', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 24),
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(flex: 3, child: _Field(label: 'IP / Host', placeholder: '192.168.1.100', controller: _hostController, errorText: _hostError, icon: FluentIcons.plug_connected, enabled: !isLoading)),
                          const SizedBox(width: 12),
                          Expanded(child: _Field(label: 'Puerto', placeholder: '80', controller: _portController, icon: FluentIcons.network_tower, enabled: !isLoading)),
                        ]),
                        const SizedBox(height: 16),
                        _Field(label: 'Usuario', placeholder: 'admin', controller: _loginController, errorText: _loginError, icon: FluentIcons.contact, enabled: !isLoading),
                        const SizedBox(height: 16),
                        _Field(
                          label: 'Contraseña', placeholder: '••••••••',
                          controller: _passwordController, errorText: _passwordError,
                          icon: FluentIcons.lock, obscure: _obscurePassword, enabled: !isLoading,
                          onSubmitted: (_) => _submit(context),
                          suffix: IconButton(
                            icon: Icon(_obscurePassword ? FluentIcons.red_eye : FluentIcons.hide3, size: 14, color: AppColors.textSecondary),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity, height: 42,
                          child: FilledButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith((s) => s.isDisabled ? AppColors.bg3 : AppColors.cyan),
                              foregroundColor: WidgetStateProperty.all(AppColors.bg0),
                            ),
                            onPressed: isLoading ? null : () => _submit(context),
                            child: isLoading
                                ? const SizedBox(width: 18, height: 18, child: ProgressRing(strokeWidth: 2))
                                : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(FluentIcons.plug_connected, size: 16),
                              SizedBox(width: 8),
                              Text('Conectar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            ]),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    Center(child: Text('ControlID Flex  ·  HTTP API', style: TextStyle(fontSize: 11, color: AppColors.textTertiary, letterSpacing: 0.5))),
                  ],
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final String? errorText;
  final IconData icon;
  final bool obscure;
  final bool enabled;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  const _Field({required this.label, required this.placeholder, required this.controller, required this.icon, this.errorText, this.obscure = false, this.enabled = true, this.suffix, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.3)),
      const SizedBox(height: 6),
      TextBox(
        controller: controller, placeholder: placeholder,
        obscureText: obscure, enabled: enabled, onSubmitted: onSubmitted,
        prefix: Padding(padding: const EdgeInsets.only(left: 10), child: Icon(icon, size: 14, color: AppColors.textTertiary)),
        suffix: suffix,
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        decoration: WidgetStatePropertyAll<BoxDecoration>(BoxDecoration(
          color: AppColors.bg3, borderRadius: BorderRadius.circular(6),
          border: Border.all(color: errorText != null ? AppColors.danger : AppColors.bgBorder),
        ),
      )),
      if (errorText != null)
        Padding(padding: const EdgeInsets.only(top: 4), child: Text(errorText!, style: const TextStyle(fontSize: 11, color: AppColors.danger))),
    ]);
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.bgBorder.withOpacity(0.4)..strokeWidth = 0.5;
    const step = 48.0;
    for (double x = 0; x < size.width; x += step) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += step) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}