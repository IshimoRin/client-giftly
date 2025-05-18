// lib/pages/favorites_page.dart
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Настройки',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
      ),

      body: const Center(
        child: Text('Настройки', style: TextStyle(fontFamily: 'Inter')),
      ),
    );
  }
}
