import 'package:flutter/material.dart';
import 'dart:async';
import 'login_page.dart'; // замените на ваш реальный путь

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Задержка 3 секунды, потом переход на LoginPage
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // или другой цвет
      body: Center(child: Image.asset('assets/images/splash.png')),
    );
  }
}
