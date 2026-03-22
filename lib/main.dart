import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nomina_control/core/theme/app_theme.dart';
import 'package:nomina_control/core/theme/cubit/theme_cubit.dart';
import 'injection_container.dart';
import 'features/session/presentation/pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar el contenedor de dependencias antes de arrancar la UI
  await initDependencies();

  runApp(const NominaControlApp());
}

class NominaControlApp extends StatelessWidget {
  const NominaControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // ThemeCubit vive en la raíz — por encima de FluentApp.
      // Todos los widgets del árbol pueden leer y cambiar el tema.
        create: (_) => serviceLocator<ThemeCubit>(),
        child: BlocBuilder<ThemeCubit, AppThemeMode>(
          builder: (context, mode) {
            return FluentApp(
              title: 'Control de accesos',
              debugShowCheckedModeBanner: false,
              theme: mode == AppThemeMode.light
                  ? buildDarkTheme()
                  : buildLightTheme(),
              home: const SplashPage(),
            );
          },
        ));
  }
}
