import 'cart_item.dart';

enum OrderStatus {
  pending,    // В обработке
  completed,  // Завершён
  canceled    // Отменён
}

class Order {
  final String? id;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;
  final String? deliveryAddress;
  final String? contactPhone;
  final String? comment;
  final DateTime createdAt;

  const Order({
    this.id,
    required this.items,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    this.deliveryAddress,
    this.contactPhone,
    this.comment,
    required this.createdAt,
  });

  // Создаем объект из JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    print('Creating Order from JSON: $json');
    
    // Преобразуем строковые значения в числа
    double parseAmount(dynamic value) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.parse(value);
      }
      return 0.0;
    }

    // Преобразуем статус
    OrderStatus parseStatus(String status) {
      switch (status.toLowerCase()) {
        case 'pending':
          return OrderStatus.pending;
        case 'completed':
          return OrderStatus.completed;
        case 'canceled':
          return OrderStatus.canceled;
        default:
          return OrderStatus.pending;
      }
    }

    return Order(
      id: json['id']?.toString(),
      items: json['products'] != null 
          ? (json['products'] as List<dynamic>)
              .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      totalAmount: parseAmount(json['total_amount']),
      status: parseStatus(json['status'] as String),
      deliveryAddress: json['delivery_address'] as String?,
      contactPhone: json['contact_phone'] as String?,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Преобразуем объект в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'status': status.toString().split('.').last,
      if (deliveryAddress != null) 'delivery_address': deliveryAddress,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (comment != null) 'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Создаем копию с новыми значениями
  Order copyWith({
    String? id,
    List<CartItem>? items,
    double? totalAmount,
    OrderStatus? status,
    String? deliveryAddress,
    String? contactPhone,
    String? comment,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      contactPhone: contactPhone ?? this.contactPhone,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 