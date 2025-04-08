import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'login_page.dart'; // Не забудь импортировать LoginPage

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      hintStyle: const TextStyle(
        color: Color(0xFFB3B3B3),
        fontStyle: FontStyle.italic,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );

    Widget buildInput(String hintText, {bool obscure = false}) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(4),
        ),
        child: TextField(
          obscureText: obscure,
          decoration: inputDecoration.copyWith(hintText: hintText),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Регистрация',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            buildInput('Phone Number'),
            buildInput('Email'),
            buildInput('Password', obscure: true),
            buildInput('Name'),
            buildInput('Role'),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {},
              child: const Text('Создать аккаунт'),
            ),
            const SizedBox(height: 16),
            Center(
              child: RichText(
                text: TextSpan(
                  text: 'Уже есть аккаунт? ',
                  style: const TextStyle(color: Color(0xFFB3B3B3)),
                  children: [
                    TextSpan(
                      text: 'Войти',
                      style: const TextStyle(
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => LoginPage()),
                              );
                            },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
