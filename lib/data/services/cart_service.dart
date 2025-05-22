import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../domain/models/cart.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/order.dart';
import 'auth_service.dart';

class CartService {
  final AuthService _authService = AuthService();

  Future<Cart> addToCart(String productId, {int quantity = 1}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/cart/add_item/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'product_id': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Cart.fromJson(data['cart']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Ошибка при добавлении в корзину');
      }
    } catch (e) {
      throw Exception('Ошибка при добавлении в корзину: $e');
    }
  }

  Future<Cart> getCart() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/cart/get_cart/'),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          final List<CartItem> items = data.map((item) {
            if (item['product'] != null) {
              return CartItem.fromJson(item);
            }
            return CartItem(
              id: item['id'].toString(),
              productId: item['product_id'].toString(),
              name: item['name'],
              image: item['image'] ?? 'assets/images/bouquet_sample.png',
              price: double.parse(item['price'].toString()),
              quantity: item['quantity'] ?? 1,
            );
          }).toList();

          return Cart(
            id: 'current',
            items: items,
            totalPrice: items.fold<double>(
              0,
              (sum, item) => sum + item.totalPrice,
            ),
          );
        }
        return Cart.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Ошибка при получении корзины');
      }
    } catch (e) {
      throw Exception('Ошибка при получении корзины: $e');
    }
  }

  Future<Cart> removeFromCart(String productId, {int quantity = 1}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      // Сначала получаем текущую корзину
      final currentCart = await getCart();
      final cartItem = currentCart.items.firstWhere(
        (item) => item.productId == productId,
        orElse: () => throw Exception('Товар не найден в корзине'),
      );

      // Проверяем, не пытаемся ли мы удалить больше товаров, чем есть в корзине
      if (quantity > cartItem.quantity) {
        throw Exception('Нельзя удалить больше товаров, чем есть в корзине');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/cart/remove_item/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'product_id': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Cart.fromJson(data['cart']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Ошибка при удалении из корзины');
      }
    } catch (e) {
      throw Exception('Ошибка при удалении из корзины: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/cart/clear_cart/'),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Ошибка при очистке корзины');
      }
    } catch (e) {
      throw Exception('Ошибка при очистке корзины: $e');
    }
  }

  Future<Order> createOrder({
    required String deliveryAddress,
    required String contactPhone,
    String? comment,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Необходима авторизация');
    }

    // Проверяем, что в корзине есть товары
    final cart = await getCart();
    if (cart.items.isEmpty) {
      throw Exception('Корзина пуста. Добавьте товары перед оформлением заказа.');
    }

    // Создаем заказ из корзины
    final requestBody = {
      'delivery_address': deliveryAddress,
      'contact_phone': contactPhone,
      if (comment != null) 'comment': comment,
      'total_amount': cart.totalPrice.toString(),
      'status': 'pending',
    };

    print('Request body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/orders/create_from_cart/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        try {
          final jsonData = jsonDecode(response.body);
          print('Parsed JSON data: $jsonData');
          
          // Преобразуем строковые значения в числа
          if (jsonData['order'] != null) {
            final orderData = jsonData['order'];
            // Безопасное преобразование total_amount
            if (orderData['total_amount'] != null) {
              if (orderData['total_amount'] is String) {
                orderData['total_amount'] = double.parse(orderData['total_amount']);
              } else if (orderData['total_amount'] is int) {
                orderData['total_amount'] = orderData['total_amount'].toDouble();
              }
            }
            
            // Безопасное преобразование цен товаров
            if (orderData['products'] != null) {
              for (var product in orderData['products']) {
                if (product['price'] != null) {
                  if (product['price'] is String) {
                    product['price'] = double.parse(product['price']);
                  } else if (product['price'] is int) {
                    product['price'] = product['price'].toDouble();
                  }
                }
              }
            }
          }
          
          return Order.fromJson(jsonData['order']);
        } catch (e) {
          print('Error parsing response: $e');
          print('Raw response body: ${response.body}');
          throw Exception('Ошибка при обработке ответа сервера: $e');
        }
      } else if (response.statusCode == 500) {
        throw Exception('Ошибка сервера при создании заказа. Пожалуйста, попробуйте позже.');
      } else {
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['error'] ?? 'Ошибка при создании заказа: ${response.body}');
        } catch (e) {
          print('Error parsing error response: $e');
          throw Exception('Ошибка при создании заказа. Пожалуйста, попробуйте позже.');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Ошибка при создании заказа: $e');
    }
  }
} 