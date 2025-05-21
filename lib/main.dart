import 'package:flutter/material.dart';
import 'presentation/pages/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giftly',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}