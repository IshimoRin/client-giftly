import '../../domain/models/user.dart';
import '../../domain/models/user_role.dart';

class AuthService {
  Future<User> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    // TODO: Реализовать реальную аутентификацию через API
    // Сейчас возвращаем тестового пользователя
    await Future.delayed(const Duration(seconds: 1)); // Имитация задержки сети
    
    return User(
      id: '1',
      email: email,
      name: role == UserRole.seller ? 'Тестовый продавец' : 'Тестовый покупатель',
      role: role,
    );
  }

  Future<void> logout() async {
    // TODO: Реализовать выход через API
    await Future.delayed(const Duration(milliseconds: 500));
  }
} 