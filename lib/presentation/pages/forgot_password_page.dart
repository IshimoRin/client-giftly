import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  InputDecoration inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFFB3B3B3),
        fontStyle: FontStyle.italic,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget shadowedField({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Восстановить пароль',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            shadowedField(
              child: TextField(
                decoration: inputDecoration('Введите Ваш номер телефона'),
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'На указанный номер телефона будет\nотправлено SMS-сообщение с кодом подтверждения',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFFB3B3B3)),
              ),
            ),
            shadowedField(child: TextField(decoration: inputDecoration('Код'))),
            shadowedField(
              child: TextField(
                obscureText: true,
                decoration: inputDecoration('Новый пароль'),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Сохранено')));
              },
              child: const SizedBox(
                width: double.infinity,
                child: Center(child: Text('Сохранить')),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Отправить код ещё раз',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
