import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'customer/home_page.dart';
import 'seller/seller_home_page.dart';
import '../../domain/models/user.dart';
import '../../domain/models/user_role.dart';
import '../../data/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function(User)? onLoginSuccess;

  const LoginPage({
    super.key,
    this.onLoginSuccess,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSellerLogin = false;
  String? _errorMessage;

  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('timeout')) {
      return 'Превышено время ожидания ответа от сервера. Проверьте интернет-соединение.';
    } else if (errorString.contains('неверный логин или пароль')) {
      return 'Неверный email или пароль';
    } else if (errorString.contains('зарегистрированы')) {
      // Изменяем формат сообщения о роли
      final message = error.toString().replaceAll('Exception: ', '');
      return message.replaceAll('Вы зарегистрированы как ', 'Вы зарегистрированы ');
    } else if (errorString.contains('connection refused')) {
      return 'Не удалось подключиться к серверу. Проверьте интернет-соединение.';
    } else {
      return 'Произошла ошибка при входе';
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Debug: Начинаем процесс входа');
      print('Debug: Email: ${emailController.text.trim()}');
      print('Debug: Роль: ${_isSellerLogin ? 'seller' : 'customer'}');

      final user = await AuthService().login(
        email: emailController.text.trim(),
        password: passwordController.text,
        role: _isSellerLogin ? UserRole.seller : UserRole.customer,
      );

      print('Debug: Вход выполнен успешно');
      print('Debug: Роль пользователя: ${user.role}');

      if (mounted) {
        if (user.role == UserRole.seller) {
          print('Debug: Перенаправляем на страницу продавца');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SellerHomePage(user: user),
            ),
          );
        } else {
          print('Debug: Перенаправляем на страницу покупателя');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(user: user),
            ),
          );
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Вход выполнен успешно'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final userFriendlyMessage = _getUserFriendlyErrorMessage(e);
        setState(() {
          _errorMessage = userFriendlyMessage;
          // Очищаем поле пароля только если это не ошибка роли
          if (!userFriendlyMessage.contains('зарегистрированы')) {
            passwordController.clear();
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: const Text(
            'Вход',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Привет, Giftly! 👋 ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          fontSize: 23,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Color(0xFF9191E9), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите email';
                    }
                    if (!value.contains('@')) {
                      return 'Введите корректный email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Пароль',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: _errorMessage != null ? Colors.red.shade300 : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: _errorMessage != null ? Colors.red.shade400 : Color(0xFF9191E9),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: _errorMessage != null ? Colors.red.shade50 : Colors.grey.shade50,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите пароль';
                    }
                    if (value.length < 6) {
                      return 'Пароль должен быть не менее 6 символов';
                    }
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!_errorMessage!.contains('зарегистрированы')) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Проверьте правильность введенного логина и пароля',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Забыли пароль?',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF9191E9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Войти',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isSellerLogin = !_isSellerLogin;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Color(0xFF9191E9)),
                    backgroundColor: _isSellerLogin ? Color(0xFF9191E9).withOpacity(0.1) : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSellerLogin ? Icons.store : Icons.person,
                        color: Color(0xFF9191E9),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isSellerLogin ? 'Войти как продавец' : 'Войти как покупатель',
                        style: TextStyle(
                          color: Color(0xFF9191E9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_isSellerLogin) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF9191E9),
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ещё нет аккаунта? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Зарегистрироваться',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
