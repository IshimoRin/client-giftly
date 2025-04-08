import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Поля ввода для регистрации
            TextField(
              key: const Key('emailFieldRegister'),
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              key: const Key('passwordFieldRegister'),
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              key: const Key('confirmPasswordField'),
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // Кнопка регистрации
            ElevatedButton(
              key: const Key('registerButton'),
              onPressed: () {
                // Логика регистрации
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
