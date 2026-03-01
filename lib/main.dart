import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nomina_control/core/theme/app_theme.dart';
import 'package:nomina_control/features/device/presentation/bloc/device_bloc.dart';
import 'package:nomina_control/features/device/presentation/pages/device_connection_page.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar el contenedor de dependencias antes de arrancar la UI
  await initDependencies();


  runApp(MultiBlocProvider(providers:[
      BlocProvider(
      create: (_) => serviceLocator<DeviceBloc>(),),
  ], child: const NominaControlApp()
  )
  );
}

class NominaControlApp extends StatelessWidget {
  const NominaControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'NóminaControl',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const DeviceConnectionPage(),
    );
  }
}