import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../domain/models/product.dart';
import '../../config/api_config.dart';
import 'package:dio/dio.dart';

class ProductService {
  final _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  // Получить список товаров
  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get('/products/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Failed to load products');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Превышено время ожидания ответа от сервера');
      }
      throw Exception('Ошибка при загрузке товаров: ${e.message}');
    } catch (e) {
      throw Exception('Ошибка при загрузке товаров: $e');
    }
  }

  // Получить список избранных товаров
  Future<List<Product>> getFavorites() async {
    try {
      final response = await _dio.get('/favorites/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Извлекаем продукты из вложенных объектов
        return data.map((json) => Product.fromJson(json['product'])).toList();
      }
      throw Exception('Failed to load favorites');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Превышено время ожидания ответа от сервера');
      }
      throw Exception('Ошибка при загрузке избранного: ${e.message}');
    } catch (e) {
      throw Exception('Ошибка при загрузке избранного: $e');
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
  // Удалён устаревший метод addToCart

  // Добавить/удалить товар из избранного
  Future<Product> toggleFavorite(Product product) async {
    try {
      final response = await _dio.post(
        '/products/${product.id}/toggle_favorite/',
      );
      
      if (response.statusCode == 200) {
        // Возвращаем копию продукта с обновленным статусом избранного
        return product.copyWith(
          isFavorite: response.data['status'] == 'added to favorites'
        );
      }
      throw Exception('Failed to toggle favorite');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Превышено время ожидания ответа от сервера');
      }
      throw Exception('Ошибка при обновлении избранного: ${e.message}');
    } catch (e) {
      throw Exception('Ошибка при обновлении избранного: $e');
    }
  }
} 