import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../domain/models/product.dart';
import '../../config/api_config.dart';
import 'auth_service.dart';

class ProductService {
  final AuthService _authService = AuthService();

  // Получить список товаров
  Future<List<Product>> getProducts() async {
    try {
      print('Debug: Запрашиваем список товаров с ${ApiConfig.baseUrl}/products/');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/products/'),
      );
      
      print('Debug: Получен ответ от сервера. Статус: ${response.statusCode}');
      print('Debug: Сырые данные от сервера: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Debug: Получено ${data.length} товаров');
        
        final products = data.map((json) {
          try {
            print('Debug: Обрабатываем товар с данными: $json');
            final product = Product.fromJson(json);
            print('Debug: Обработан товар ${product.name} с изображением ${product.image}');
            return product;
          } catch (e) {
            print('Debug: Ошибка при обработке товара: $e');
            rethrow;
          }
        }).toList();
        
        return products;
      }
      throw Exception('Failed to load products: ${response.statusCode}');
    } catch (e) {
      print('Debug: Ошибка при загрузке товаров: $e');
      throw Exception('Ошибка при загрузке товаров: $e');
    }
  }

  // Получить список избранных товаров
  Future<List<Product>> getFavorites() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final url = '${ApiConfig.baseUrl}/favorites/';
      print('Debug: Запрашиваем избранное с URL: $url');
      print('Debug: Токен: $token');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token',
          'Accept': 'application/json',
        },
      );

      print('Debug: Ответ сервера при получении избранного: ${response.statusCode}');
      print('Debug: Заголовки ответа: ${response.headers}');
      print('Debug: Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Debug: Получено ${data.length} избранных товаров');
        
        final products = data.map((json) {
          try {
            print('Debug: Обрабатываем избранный товар: $json');
            if (json['product'] == null) {
              print('Debug: Ошибка: поле product отсутствует в ответе');
              throw Exception('Некорректный формат данных избранного');
            }
            final product = Product.fromJson(json['product']);
            print('Debug: Успешно обработан товар ${product.name}');
            return product;
          } catch (e) {
            print('Debug: Ошибка при обработке избранного товара: $e');
            rethrow;
          }
        }).toList();
        
        print('Debug: Успешно обработано ${products.length} товаров');
        return products;
      }
      throw Exception('Failed to load favorites: ${response.statusCode}');
    } catch (e) {
      print('Debug: Ошибка при загрузке избранного: $e');
      throw Exception('Ошибка при загрузке избранного: $e');
    }
  }

  // Добавить товар в избранное
  Future<void> addToFavorites(String productId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final url = '${ApiConfig.baseUrl}/favorites/add/';
      print('Debug: Добавляем в избранное товар $productId');
      print('Debug: URL: $url');
      print('Debug: Токен: $token');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'product_id': productId,
        }),
      );

      print('Debug: Ответ сервера при добавлении в избранное: ${response.statusCode}');
      print('Debug: Заголовки ответа: ${response.headers}');
      print('Debug: Тело ответа: ${response.body}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Ошибка при добавлении в избранное: ${response.body}');
      }
    } catch (e) {
      print('Debug: Ошибка при добавлении в избранное: $e');
      throw Exception('Ошибка при добавлении в избранное: $e');
    }
  }

  // Удалить товар из избранного
  Future<void> removeFromFavorites(String productId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final url = '${ApiConfig.baseUrl}/favorites/remove/';
      print('Debug: Удаляем из избранного товар $productId');
      print('Debug: URL: $url');
      print('Debug: Токен: $token');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'product_id': productId,
        }),
      );

      print('Debug: Ответ сервера при удалении из избранного: ${response.statusCode}');
      print('Debug: Заголовки ответа: ${response.headers}');
      print('Debug: Тело ответа: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Ошибка при удалении из избранного: ${response.body}');
      }
    } catch (e) {
      print('Debug: Ошибка при удалении из избранного: $e');
      throw Exception('Ошибка при удалении из избранного: $e');
    }
  }

  // Добавить товар в корзину
  // Удалён устаревший метод addToCart

  // Добавить/удалить товар из избранного
  Future<Product> toggleFavorite(Product product) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      print('Debug: Переключаем избранное для товара ${product.id} с токеном: $token');
      
      // Проверяем, есть ли товар уже в избранном
      final favorites = await getFavorites();
      final isInFavorites = favorites.any((f) => f.id == product.id);
      
      if (isInFavorites) {
        // Если товар в избранном, удаляем его
        print('Debug: Удаляем товар из избранного');
        await removeFromFavorites(product.id);
        // Обновляем список избранного после удаления
        await getFavorites();
        return product.copyWith(isFavorite: false);
      } else {
        // Если товара нет в избранном, добавляем его
        print('Debug: Добавляем товар в избранное');
        await addToFavorites(product.id);
        // Обновляем список избранного после добавления
        await getFavorites();
        return product.copyWith(isFavorite: true);
      }
    } catch (e) {
      print('Debug: Ошибка при переключении избранного: $e');
      throw Exception('Ошибка при обновлении избранного: $e');
    }
  }
} 