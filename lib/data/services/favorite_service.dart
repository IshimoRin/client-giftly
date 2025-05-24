import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';

class FavoriteService {
  static const String _baseUrl = 'http://localhost:8000/api';

  Future<List<Product>> getFavorites() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/favorites/'),
        headers: {
          'Content-Type': 'application/json',
          // Добавьте заголовок авторизации, если требуется
          // 'Authorization': 'Token your-auth-token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json['product'])).toList();
      } else {
        throw Exception('Ошибка при загрузке избранного: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при загрузке избранного: $e');
    }
  }

  Future<void> addToFavorites(int productId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/favorites/'),
        headers: {
          'Content-Type': 'application/json',
          // Добавьте заголовок авторизации, если требуется
          // 'Authorization': 'Token your-auth-token',
        },
        body: json.encode({'product': productId}),
      );

      if (response.statusCode != 201) {
        throw Exception('Ошибка при добавлении в избранное: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при добавлении в избранное: $e');
    }
  }

  Future<void> removeFromFavorites(int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/favorites/$productId/'),
        headers: {
          'Content-Type': 'application/json',
          // Добавьте заголовок авторизации, если требуется
          // 'Authorization': 'Token your-auth-token',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Ошибка при удалении из избранного: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при удалении из избранного: $e');
    }
  }
} 