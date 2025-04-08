import 'dart:async';
import '../../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<bool> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 2)); // Симуляция задержки
    return email == 'user@example.com' && password == 'password123';
  }
}
