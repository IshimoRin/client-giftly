import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/product.dart';
import '../../config/api_config.dart';

class ProductService {
  // Получить список товаров
  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.productsUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Не удалось загрузить товары');
      }
    } catch (e) {
      throw Exception('Ошибка: $e');
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
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Не удалось загрузить избранное');
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
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Не удалось добавить в избранное');
      }
    } catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  // Удалить товар из избранного
  Future<void> removeFromFavorites(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.favoritesUrl}/$productId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Не удалось удалить из избранного');
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
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Не удалось добавить в корзину');
      }
    } catch (e) {
      throw Exception('Ошибка: $e');
    }
  }
} 