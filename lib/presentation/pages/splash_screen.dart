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
      body: Stack(
        children: [
          // Фоновая картинка на весь экран
          Image.asset(
            'assets/images/splash.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Текст "Gifty" по центру
          const Center(
            child: Text(
              'Giftly',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
