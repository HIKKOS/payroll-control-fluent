import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:nomina_control/core/theme/app_colors.dart';
import 'package:nomina_control/features/device/presentation/bloc/device_bloc.dart';
import 'package:nomina_control/features/session/domain/entities/saved_session.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../device/presentation/pages/device_connection_page.dart';
import '../../../device/presentation/pages/device_shell_page.dart';
import '../bloc/startup_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          serviceLocator<StartupBloc>()..add(const StartupCheckRequested()),
      child: const _SplashBody(),
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody();

  @override
  Widget build(BuildContext context) {
    return BlocListener<StartupBloc, StartupState>(
      listener: (context, state) async {
        switch (state) {
          case StartupDone(:final session):
            serviceLocator.registerSingleton<SavedSession>(session);
            Navigator.of(context).pushReplacement(FluentPageRoute(
                builder: (_) => const DeviceShellPage(offlineMode: false,),
            ));
            return;
          case StartupDoneOffline _:
            Navigator.of(context).pushReplacement(FluentPageRoute(
              builder: (_) => const DeviceShellPage(offlineMode: true),
            ));
            return;
          case StartupLoginRequired _:
            Navigator.of(context).pushReplacement(FluentPageRoute(
              builder: (_) => const DeviceConnectionPage(),
            ));
            return;
          default:
            break;
        }
      },
      child: ScaffoldPage(
        content: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(radiusLg),
                  border: Border.all(color: context.colors.border),
                  boxShadow: [context.colors.shadowMd],
                ),
                child:   Icon(LucideIcons.fingerprintPattern,
                    size: 26, color: context.colors.foreground),
              ),
              const SizedBox(height: 18),
                Text('NóminaControl',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: context.colors.foreground,
                      letterSpacing: -0.3)),
              const SizedBox(height: 28),
              // Spinner + mensaje
              BlocBuilder<StartupBloc, StartupState>(
                builder: (_, state) => state is StartupChecking
                    ?  Column(mainAxisSize: MainAxisSize.min, children: [
                        SizedBox(
                            width: 18,
                            height: 18,
                            child: ProgressRing(
                                strokeWidth: 2,
                                activeColor: context.colors.mutedFg)),
                  const   SizedBox(height: 10),
                       Text('Verificando conexión…',
                            style: TextStyle(
                                fontSize: 12, color: context.colors.mutedFg)),
                      ])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
