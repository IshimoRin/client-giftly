// lib/pages/favorites_page.dart
import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Изранное',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
      ),

      body: const Center(
        child: Text('Избраные товары', style: TextStyle(fontFamily: 'Inter')),
      ),
    );
  }
}
