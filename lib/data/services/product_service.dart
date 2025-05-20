import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../domain/models/product.dart';
import '../../config/api_config.dart';

class ProductService {
  // Получить список товаров
  Future<List<Product>> getProducts() async {
    try {
      print('Fetching products from: ${ApiConfig.productsUrl}');
      
      final response = await http.get(
        Uri.parse(ApiConfig.productsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Превышено время ожидания ответа от сервера');
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((json) => Product.fromJson(json)).toList();
        } catch (e) {
          print('Error parsing JSON: $e');
          throw Exception('Ошибка при обработке данных: $e');
        }
      } else {
        print('Error response: ${response.body}');
        throw Exception('Ошибка получения товаров: ${response.body}');
      }
    } catch (e) {
      print('Error in getProducts: $e');
      throw Exception('Ошибка при получении товаров: $e');
    }
  }

  // Получить список избранных товаров
  Future<List<Product>> getFavorites() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.favoritesUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Превышено время ожидания ответа от сервера');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Не удалось загрузить избранное: ${response.body}');
      }
    } catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  // Добавить товар в избранное
  Future<void> addToFavorites(String productId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.favoritesUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'product_id': productId}),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Превышено время ожидания ответа от сервера');
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Не удалось добавить в избранное: ${response.body}');
      }
    } catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  // Удалить товар из избранного
  Future<void> removeFromFavorites(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.favoritesUrl}$productId/'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Превышено время ожидания ответа от сервера');
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Не удалось удалить из избранного: ${response.body}');
      }
    } catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  // Добавить товар в корзину
  Future<void> addToCart(String productId, {int quantity = 1}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.cartUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'product_id': productId,
          'quantity': quantity,
        }),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Превышено время ожидания ответа от сервера');
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Не удалось добавить в корзину: ${response.body}');
      }
    } catch (e) {
      throw Exception('Ошибка: $e');
    }
  }
} 