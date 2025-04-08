import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/login_bloc.dart';
import '../viewmodels/login_event.dart';
import '../viewmodels/login_state.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(LoginUseCase(AuthRepositoryImpl())),
      child: Scaffold(
        appBar: AppBar(title: Text('Login')),
        body: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            if (state.status == LoginStatus.success) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              });
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  if (state.status == LoginStatus.loading)
                    CircularProgressIndicator(),
                  if (state.status == LoginStatus.failure)
                    Text(
                      state.error ?? '',
                      style: TextStyle(color: Colors.red),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      final email = emailController.text;
                      final password = passwordController.text;
                      context.read<LoginBloc>().add(
                        LoginSubmitted(email, password),
                      );
                    },
                    child: Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: const Text('Create an Account'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
