import 'package:flutter/material.dart';
import 'package:nomina_control/features/device/presentation/pages/device_connection_page.dart';
import 'injection_container.dart';

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
    return MaterialApp(
      title: 'Control de Nómina',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const DeviceConnectionPage(),
    );
  }
}