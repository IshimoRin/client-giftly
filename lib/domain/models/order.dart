import 'cart_item.dart';

enum OrderStatus {
  pending,    // Ожидает подтверждения
  confirmed,  // Подтвержден
  processing, // В обработке
  shipping,   // Доставляется
  delivered,  // Доставлен
  cancelled   // Отменен
}

class Order {
  final String? id;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;
  final String deliveryAddress;
  final String contactPhone;
  final String? comment;
  final DateTime createdAt;

  const Order({
    this.id,
    required this.items,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    required this.deliveryAddress,
    required this.contactPhone,
    this.comment,
    required this.createdAt,
  });

  // Создаем объект из JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: json['total_amount'] as double,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: json['delivery_address'] as String,
      contactPhone: json['contact_phone'] as String,
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
      'delivery_address': deliveryAddress,
      'contact_phone': contactPhone,
      'comment': comment,
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