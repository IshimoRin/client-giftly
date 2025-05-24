import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';
import '../../domain/models/order.dart';
import '../../domain/models/product.dart';
import '../../domain/models/sales_statistics.dart';

class SellerService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
  }

  Future<List<Order>> getSellerOrders() async {
    try {
      final headers = await _getHeaders();
      print('Debug: Отправляем запрос на получение заказов с товарами продавца');
      print('Debug: URL: ${ApiConfig.baseUrl}/orders/seller_orders/');
      print('Debug: Headers: $headers');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/orders/seller_orders/'),
        headers: headers,
      );

      print('Debug: Статус ответа: ${response.statusCode}');
      print('Debug: Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Debug: Получено заказов: ${data.length}');
        for (var order in data) {
          print('Debug: Заказ ID: ${order['id']}, Статус: ${order['status']}');
        }
        return data.map((json) => Order.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Необходима авторизация');
      } else if (response.statusCode == 403) {
        throw Exception('Доступ запрещен');
      } else {
        throw Exception('Ошибка при получении заказов: ${response.statusCode}');
      }
    } catch (e) {
      print('Debug: Ошибка при получении заказов: $e');
      throw Exception('Ошибка при получении заказов: $e');
    }
  }

  Future<List<Product>> getSellerProducts() async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/products/';
      print('Debug: Отправляем запрос на получение товаров продавца');
      print('Debug: URL: $url');
      print('Debug: Headers: $headers');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Debug: Статус ответа: ${response.statusCode}');
      print('Debug: Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Debug: Получено товаров: ${data.length}');
        return data.map((json) => Product.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Необходима авторизация');
      } else {
        throw Exception('Ошибка при получении товаров: ${response.statusCode}');
      }
    } catch (e) {
      print('Debug: Ошибка при получении товаров: $e');
      throw Exception('Ошибка при получении товаров: $e');
    }
  }

  Future<SalesStatistics> getSellerStatistics() async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/statistics/seller/';
      print('Debug: Отправляем запрос на получение статистики');
      print('Debug: URL: $url');
      print('Debug: Headers: $headers');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Debug: Статус ответа: ${response.statusCode}');
      print('Debug: Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SalesStatistics.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Необходима авторизация');
      } else if (response.statusCode == 403) {
        throw Exception('Доступ запрещен');
      } else {
        throw Exception('Ошибка при получении статистики: ${response.statusCode}');
      }
    } catch (e) {
      print('Debug: Ошибка при получении статистики: $e');
      throw Exception('Ошибка при получении статистики: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      // Проверяем, что статус является допустимым
      final validStatuses = ['pending', 'completed', 'canceled'];
      if (!validStatuses.contains(status)) {
        throw Exception('Недопустимый статус заказа. Допустимые значения: ${validStatuses.join(", ")}');
      }

      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/orders/$orderId/update_status/';
      print('Debug: Отправляем запрос на обновление статуса заказа');
      print('Debug: URL: $url');
      print('Debug: Order ID: $orderId');
      print('Debug: Headers: $headers');
      print('Debug: Body: {"status": "$status"}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode({'status': status}),
      );

      print('Debug: Статус ответа: ${response.statusCode}');
      print('Debug: Тело ответа: ${response.body}');

      if (response.statusCode == 401) {
        throw Exception('Необходима авторизация');
      } else if (response.statusCode == 404) {
        throw Exception('Заказ не найден');
      } else if (response.statusCode != 200) {
        final responseData = json.decode(response.body);
        throw Exception('Ошибка при обновлении статуса заказа: ${responseData['message'] ?? responseData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      print('Debug: Ошибка при обновлении статуса заказа: $e');
      throw Exception('Ошибка при обновлении статуса заказа: $e');
    }
  }

  Future<Product> createProduct({
    required String name,
    required String description,
    required double price,
    String? imageUrl,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConfig.baseUrl}/products/';
      
      // Получаем ID продавца из токена
      final prefs = await SharedPreferences.getInstance();
      final sellerId = prefs.getInt('seller_id');
      
      if (sellerId == null) {
        throw Exception('ID продавца не найден. Пожалуйста, войдите в систему заново.');
      }
      
      // Если imageUrl не указан или не является валидным URL, используем дефолтное изображение
      final String validImageUrl = imageUrl?.isNotEmpty == true && Uri.tryParse(imageUrl!)?.hasAbsolutePath == true
          ? imageUrl
          : 'https://via.placeholder.com/150';

      final body = {
        'name': name,
        'description': description,
        'price': price.toString(),
        'image_url': validImageUrl,
        'seller': sellerId, // Используем числовой ID продавца
      };
      
      print('Debug: Отправляем запрос на создание товара');
      print('Debug: URL: $url');
      print('Debug: Headers: $headers');
      print('Debug: Body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      print('Debug: Статус ответа: ${response.statusCode}');
      print('Debug: Тело ответа: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Product.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Необходима авторизация');
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error'] ?? errorData['detail'] ?? 'Ошибка при создании товара: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Debug: Ошибка при создании товара: $e');
      throw Exception('Ошибка при создании товара: $e');
    }
  }

  Future<void> updateProduct({
    required int productId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
  }) async {
    try {
      final headers = await _getHeaders();
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (price != null) updateData['price'] = price;
      if (imageUrl != null) updateData['image_url'] = imageUrl;

      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/products/$productId/'),
        headers: headers,
        body: json.encode(updateData),
      );

      if (response.statusCode == 401) {
        throw Exception('Необходима авторизация');
      } else if (response.statusCode != 200) {
        throw Exception('Ошибка при обновлении товара: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при обновлении товара: $e');
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/products/$productId/'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        throw Exception('Необходима авторизация');
      } else if (response.statusCode != 204) {
        throw Exception('Ошибка при удалении товара: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при удалении товара: $e');
    }
  }
} 