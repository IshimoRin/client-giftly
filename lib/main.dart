import 'package:flutter/material.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/pages/login_page.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'data/services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация AppMetrica
  await AppMetrica.activate(AppMetricaConfig('e8af4d86-f666-4858-be1c-fe67a70ca143'));
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
