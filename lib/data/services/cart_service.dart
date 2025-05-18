import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/order.dart';

class CartService {
  // Получить содержимое корзины
  Future<List<CartItem>> getCartItems() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.cartUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => CartItem.fromJson(json)).toList();
      } else {
        throw Exception('Не удалось загрузить корзину');
      }
    } catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  // Добавить товар в корзину
  Future<void> addToCart(String productId, {int quantity = 1, String? note}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.cartUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'product_id': productId,
          'quantity': quantity,
          'note': note,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Не удалось добавить в корзину');
      }
    } catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  // Обновить количество товара в корзине
  Future<void> updateCartItemQuantity(String productId, int quantity) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.cartUrl}/$productId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'quantity': quantity,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Не удалось обновить количество');
      }
    } catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  // Удалить товар из корзины
  Future<void> removeFromCart(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.cartUrl}/$productId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Не удалось удалить из корзины');
      }
    } catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  // Очистить корзину
  Future<void> clearCart() async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.cartUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Не удалось очистить корзину');
      }
    } catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  // Оформить заказ
  Future<Order> createOrder({
    required String deliveryAddress,
    required String contactPhone,
    String? comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.ordersUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'delivery_address': deliveryAddress,
          'contact_phone': contactPhone,
          'comment': comment,
        }),
      );

      if (response.statusCode == 201) {
        return Order.fromJson(json.decode(response.body));
      } else {
        throw Exception('Не удалось создать заказ');
      }
    } catch (e) {
      throw Exception('Ошибка: $e');
    }
  }
} 