import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;
  final String? note;  // Опциональное примечание к товару

  const CartItem({
    required this.product,
    required this.quantity,
    this.note,
  });

  // Получить общую стоимость позиции
  double get totalPrice => product.price * quantity;

  // Создаем объект из JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      note: json['note'] as String?,
    );
  }

  // Преобразуем объект в JSON
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'note': note,
    };
  }

  // Создаем копию с новыми значениями
  CartItem copyWith({
    Product? product,
    int? quantity,
    String? note,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }
} 