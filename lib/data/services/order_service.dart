import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../domain/models/order.dart';
import 'auth_service.dart';

class OrderService {
  final AuthService _authService = AuthService();

  Future<List<Order>> getUserOrders() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/orders/'),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Parsed data: $data');
        
        return data.map((json) {
          print('Processing order: $json');
          try {
            return Order.fromJson(json);
          } catch (e) {
            print('Error parsing order: $e');
            rethrow;
          }
        }).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Ошибка при получении заказов');
      }
    } catch (e) {
      print('Error in getUserOrders: $e');
      throw Exception('Ошибка при получении заказов: $e');
    }
  }
} 