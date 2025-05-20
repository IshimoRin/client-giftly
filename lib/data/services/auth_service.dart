import '../../domain/models/user.dart';
import '../../domain/models/user_role.dart';
import '../../config/api_config.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class AuthService {
  Future<User> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login response data: $data'); // Debug print
        return User(
          id: data['id'].toString(),
          email: data['email'],
          name: '${data['first_name']} ${data['last_name']}',
          role: UserRole.values.firstWhere(
            (role) => role.toString().split('.').last == data['role'],
            orElse: () => UserRole.customer,
          ),
          phone: data['phone'],
          birthDate: data['birth_date'] != null ? DateTime.parse(data['birth_date']) : null,
        );
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Ошибка входа');
      }
    } catch (e) {
      throw Exception('Ошибка при входе: $e');
    }
  }

  Future<void> logout() async {
    // TODO: Реализовать выход через API
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<User> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? birthDate,
  }) async {
    try {
      final body = {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (phone != null) 'phone': phone,
        if (birthDate != null) 'birth_date': '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}',
      };
      print('Sending update profile request: $body'); // Debug print

      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Превышено время ожидания ответа от сервера');
        },
      );

      print('Update profile response: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User(
          id: data['id'].toString(),
          email: data['email'],
          name: '${data['first_name']} ${data['last_name']}',
          role: UserRole.values.firstWhere(
            (role) => role.toString().split('.').last == data['role'],
            orElse: () => UserRole.customer,
          ),
          phone: data['phone'],
          birthDate: data['birth_date'] != null ? DateTime.parse(data['birth_date']) : null,
        );
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Ошибка обновления профиля');
      }
    } catch (e) {
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
          'role': 'buyer',    // По умолчанию роль - покупатель
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