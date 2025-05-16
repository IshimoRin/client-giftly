import 'package:flutter/material.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Вход',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: 28,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),

                const Text(
                  'Добро пожаловать в Giftly',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 22),
                ),

                // email
                const SizedBox(height: 40),
                _buildInputField(
                  controller: emailController,
                  hintText: 'Email',
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Введите email'
                              : null,
                ),
                // пароль
                const SizedBox(height: 16),
                _buildInputField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Введите пароль'
                              : null,
                ),

                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Забыли пароль?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Вход...')));

                      // Переход на главную страницу
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomePage()),
                        );
                      });
                    }
                  },
                  child: const Text('Войти'),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Нет аккаунта?',
                        style: TextStyle(color: Color(0xFFB3B3B3)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Зарегистрироваться',
                          style: TextStyle(
                            color: Colors.black,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(-2, 4),
          ),
        ],
        borderRadius: BorderRadius.zero,
      ),

      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFB3B3B3),
            fontFamily: 'Inter',
          ),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
      ),
    );
  }
}
