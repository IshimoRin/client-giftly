import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../domain/models/product.dart';
import 'auth_service.dart';

class RecommendationService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getRecommendations(String query) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final url = '${ApiConfig.baseUrl}/products/chat-recommend/';
      print('Debug: Отправляем запрос на получение рекомендаций');
      print('Debug: URL: $url');
      print('Debug: Query: $query');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'query': query,
          'limit': 3,
        }),
      );

      print('Debug: Статус ответа: ${response.statusCode}');
      print('Debug: Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Преобразуем продукты из ответа
          if (data['products'] != null) {
            data['products'] = (data['products'] as List).map((item) {
              if (item['product'] != null) {
                item['product'] = Product.fromJson(item['product']);
              }
              return item;
            }).toList();
          }
          return data;
        } else {
          throw Exception(data['error'] ?? 'Ошибка при получении рекомендаций');
        }
      } else {
        throw Exception('Ошибка при получении рекомендаций: ${response.statusCode}');
      }
    } catch (e) {
      print('Debug: Ошибка при получении рекомендаций: $e');
      throw Exception('Ошибка при получении рекомендаций: $e');
    }
  }
} 