import '../../domain/models/user.dart';
import '../../domain/models/user_role.dart';
import '../../config/api_config.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<User> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      print('Debug: Отправляем запрос на вход для email: $email');
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Превышено время ожидания ответа от сервера');
        },
      );

      print('Debug: Статус ответа: ${response.statusCode}');
      print('Debug: Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];
        
        if (userData == null) {
          print('Debug: Данные пользователя не найдены в ответе: $data');
          throw Exception('Ошибка: сервер не вернул данные пользователя');
        }

        final userId = userData['id']?.toString();
        if (userId == null || userId.isEmpty) {
          print('Debug: ID пользователя не найден в ответе: $userData');
          throw Exception('Ошибка: сервер не вернул идентификатор пользователя');
        }

        final token = data['token'];
        if (token == null || token.isEmpty) {
          throw Exception('Ошибка: сервер не вернул токен авторизации');
        }

        print('Debug: Сохраняем данные в SharedPreferences');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_id', userId);
        await prefs.setString('user_email', userData['email'] ?? email);
        
        // Формируем полное имя из first_name и last_name
        final firstName = userData['first_name'] ?? '';
        final lastName = userData['last_name'] ?? '';
        final fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
        await prefs.setString('user_name', fullName);
        
        await prefs.setString('user_role', role.toString());
        await prefs.setString('user_phone', userData['phone'] ?? '');
        if (userData['birth_date'] != null) {
          await prefs.setString('user_birth_date', userData['birth_date']);
        }

        print('Debug: Проверяем сохраненные данные:');
        print('Debug: token: ${prefs.getString('token')}');
        print('Debug: user_id: ${prefs.getString('user_id')}');
        print('Debug: user_email: ${prefs.getString('user_email')}');
        print('Debug: user_name: ${prefs.getString('user_name')}');
        
        final user = User(
          id: userId,
          email: userData['email'] ?? email,
          name: fullName,
          role: role,
          phone: userData['phone'] ?? '',
          birthDate: userData['birth_date'] != null ? DateTime.parse(userData['birth_date']) : null,
        );

        print('Debug: Создан объект пользователя: ${user.toString()}');
        return user;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['error'] ?? errorData['detail'] ?? 'Ошибка входа: ${response.statusCode}');
        } catch (_) {
          throw Exception('Ошибка входа: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Debug: Ошибка при входе: $e');
      throw Exception('Ошибка при входе: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } catch (e) {
      print('Ошибка при выходе: $e');
      throw Exception('Ошибка при выходе из аккаунта: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<User?> getSavedUser() async {
    try {
      print('Debug: Загружаем сохраненные данные пользователя');
      final prefs = await SharedPreferences.getInstance();
      
      print('Debug: Проверяем сохраненные данные:');
      print('Debug: token: ${prefs.getString('token')}');
      print('Debug: user_id: ${prefs.getString('user_id')}');
      print('Debug: user_email: ${prefs.getString('user_email')}');
      print('Debug: user_name: ${prefs.getString('user_name')}');
      print('Debug: user_role: ${prefs.getString('user_role')}');
      
      final userId = prefs.getString('user_id');
      if (userId == null) {
        print('Debug: user_id не найден в SharedPreferences');
        return null;
      }

      final user = User(
        id: userId,
        email: prefs.getString('user_email') ?? '',
        name: prefs.getString('user_name') ?? '',
        role: UserRole.values.firstWhere(
          (role) => role.toString() == prefs.getString('user_role'),
          orElse: () => UserRole.customer,
        ),
        phone: prefs.getString('user_phone') ?? '',
        birthDate: prefs.getString('user_birth_date') != null 
          ? DateTime.parse(prefs.getString('user_birth_date')!) 
          : null,
      );

      print('Debug: Создан объект пользователя: ${user.toString()}');
      return user;
    } catch (e) {
      print('Debug: Ошибка при получении сохраненных данных пользователя: $e');
      return null;
    }
  }

  Future<User> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? birthDate,
  }) async {
    try {
      if (userId.isEmpty) {
        throw Exception('Некорректный идентификатор пользователя');
      }
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Требуется авторизация');
      }

      final Map<String, dynamic> body = {};
      if (firstName != null && firstName.isNotEmpty) body['first_name'] = firstName;
      if (lastName != null && lastName.isNotEmpty) body['last_name'] = lastName;
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;
      if (birthDate != null) body['birth_date'] = birthDate.toIso8601String().split('T')[0];

      print('Debug: Отправляем данные для обновления профиля: $body');
      print('Debug: URL: ${ApiConfig.baseUrl}/users/$userId/');
      print('Debug: Token: $token');

      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Превышено время ожидания ответа от сервера');
        },
      );

      print('Debug: Статус ответа: ${response.statusCode}');
      print('Debug: Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        
        // Обновляем сохраненные данные
        final fullName = '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim();
        await prefs.setString('user_name', fullName);
        await prefs.setString('user_phone', data['phone'] ?? '');
        if (data['birth_date'] != null) {
          await prefs.setString('user_birth_date', data['birth_date']);
        }
        
        // Создаем обновленного пользователя
        return User(
          id: userId, // Используем переданный userId
          email: data['email'] ?? '',
          name: fullName,
          role: UserRole.customer, // Используем текущую роль
          phone: data['phone'] ?? '',
          birthDate: data['birth_date'] != null ? DateTime.tryParse(data['birth_date']) : null,
        );
      } else {
        // Если сервер вернул ошибку, пробуем получить текст ошибки
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['error'] ?? 'Ошибка обновления профиля');
        } catch (_) {
          throw Exception('Ошибка обновления профиля: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Debug: Исключение при обновлении профиля: $e');
      throw Exception('Ошибка при обновлении профиля: $e');
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': 'buyer',
        }),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Превышено время ожидания ответа от сервера');
        },
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Ошибка регистрации: ${response.body}');
      }
    } catch (e) {
      throw Exception('Ошибка при регистрации: $e');
    }
  }

  Future<void> testConnection() async {
    try {
      print('Тестируем подключение к: ${ApiConfig.baseUrl}/users/');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/'),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('Таймаут при подключении');
          throw TimeoutException('Превышено время ожидания ответа от сервера');
        },
      );
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    } catch (e) {
      print('Error: $e');
    }
  }
} 