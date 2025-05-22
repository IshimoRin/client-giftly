import 'package:dio/dio.dart';
import '../../domain/models/cart_item.dart';
import '../../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  // Получить токен из SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Добавить товар в корзину
  Future<CartItem> addToCart(String productId, {int quantity = 1}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      print('Using token for addToCart: $token'); // Для отладки
      print('Debug: Product ID: $productId');
      print('Debug: Quantity: $quantity');

      final response = await _dio.post(
        '/cart/add_item/',
        data: {
          'product_id': productId,
          'quantity': quantity,
        },
        options: Options(
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      
      print('Debug: Статус ответа: ${response.statusCode}');
      print('Debug: Тело ответа: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Получаем первый элемент из списка товаров корзины
        final cartData = response.data['cart'];
        if (cartData != null && cartData['items'] != null && cartData['items'].isNotEmpty) {
          return CartItem.fromJson(cartData['items'][0]);
        }
        throw Exception('Товар не был добавлен в корзину');
      } else {
        throw Exception('Не удалось добавить товар в корзину: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioError in addToCart: ${e.message}'); // Для отладки
      print('Debug: Response data: ${e.response?.data}'); // Добавляем вывод данных ответа
      if (e.response?.statusCode == 403) {
        throw Exception('Доступ запрещен. Пожалуйста, войдите в систему заново.');
      }
      throw Exception('Ошибка при добавлении в корзину: ${e.message}');
    } catch (e) {
      print('Error in addToCart: $e'); // Для отладки
      throw Exception('Ошибка при добавлении в корзину: $e');
    }
  }

  // Получить содержимое корзины
  Future<List<CartItem>> getCart() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      print('Using token: $token'); // Для отладки

      final response = await _dio.get(
        '/cart/',
        options: Options(
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => CartItem.fromJson(item)).toList();
      } else {
        throw Exception('Не удалось загрузить корзину: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioError: ${e.message}'); // Для отладки
      print('Debug: Response data: ${e.response?.data}'); // Добавляем вывод данных ответа
      if (e.response?.statusCode == 403) {
        throw Exception('Доступ запрещен. Пожалуйста, войдите в систему заново.');
      }
      throw Exception('Ошибка при загрузке корзины: ${e.message}');
    } catch (e) {
      print('Error: $e'); // Для отладки
      throw Exception('Ошибка при загрузке корзины: $e');
    }
  }

  // Обновить количество товара в корзине
  Future<CartItem> updateQuantity(String cartItemId, int quantity) async {
    try {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        _dio.options.headers['Authorization'] = 'Token $token';
      }
      final response = await _dio.put(
        '/cart/update_quantity/',
        data: {
          'cart_item_id': cartItemId,
          'quantity': quantity,
        },
      );
      
      if (response.statusCode == 200) {
        return CartItem.fromJson(response.data);
      }
      throw Exception('Failed to update cart item');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Превышено время ожидания ответа от сервера');
      }
      throw Exception('Ошибка при обновлении корзины: ${e.message}');
    } catch (e) {
      throw Exception('Ошибка при обновлении корзины: $e');
    }
  }

  // Удалить товар из корзины
  Future<void> removeFromCart(String productId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      print('Using token for removeFromCart: $token'); // Для отладки

      final response = await _dio.post(
        '/cart/remove_item/',
        data: {
          'product_id': productId,
        },
        options: Options(
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Не удалось удалить товар из корзины: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioError in removeFromCart: ${e.message}'); // Для отладки
      print('Debug: Response data: ${e.response?.data}'); // Добавляем вывод данных ответа
      if (e.response?.statusCode == 403) {
        throw Exception('Доступ запрещен. Пожалуйста, войдите в систему заново.');
      }
      throw Exception('Ошибка при удалении из корзины: ${e.message}');
    } catch (e) {
      print('Error in removeFromCart: $e'); // Для отладки
      throw Exception('Ошибка при удалении из корзины: $e');
    }
  }

  // Очистить корзину
  Future<void> clearCart() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final response = await _dio.delete(
        '/cart/clear/',
        options: Options(
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Не удалось очистить корзину: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioError in clearCart: ${e.message}'); // Для отладки
      print('Debug: Response data: ${e.response?.data}'); // Добавляем вывод данных ответа
      if (e.response?.statusCode == 403) {
        throw Exception('Доступ запрещен. Пожалуйста, войдите в систему заново.');
      }
      throw Exception('Ошибка при очистке корзины: ${e.message}');
    } catch (e) {
      print('Error in clearCart: $e'); // Для отладки
      throw Exception('Ошибка при очистке корзины: $e');
    }
  }

  // Оформить заказ
  Future<Map<String, dynamic>> checkout({
    required String address,
    required String phone,
    String? comment,
  }) async {
    try {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        _dio.options.headers['Authorization'] = 'Token $token';
      }
      final response = await _dio.post(
        '/orders/create/',
        data: {
          'address': address,
          'phone': phone,
          'comment': comment,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create order');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Превышено время ожидания ответа от сервера');
      }
      throw Exception('Ошибка при оформлении заказа: ${e.message}');
    } catch (e) {
      throw Exception('Ошибка при оформлении заказа: $e');
    }
  }
} 