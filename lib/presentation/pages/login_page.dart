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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService().login(
        email: emailController.text.trim(),
        password: passwordController.text,
        role: _isSellerLogin ? UserRole.seller : UserRole.customer,
      );

      if (mounted) {
        if (user.role == UserRole.seller) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SellerHomePage(user: user),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(user: user),
            ),
          );
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вход выполнен успешно'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
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
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Color(0xFF9191E9), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: Text(
                    _isSellerLogin ? 'Войти как покупатель' : 'Войти как продавец',
                    style: TextStyle(
                      color: Color(0xFF9191E9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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
