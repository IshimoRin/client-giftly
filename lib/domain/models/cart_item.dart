import 'product.dart';

class CartItem {
  final String id;
  final String productId;
  final String name;
  final String image;
  final double price;
  final int quantity;

  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
  });

  // Получить общую стоимость позиции
  double get totalPrice => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Если json содержит вложенный объект product
    if (json['product'] != null) {
      final product = json['product'];
      return CartItem(
        id: json['id'].toString(),
        productId: product['id'].toString(),
        name: product['name'],
        image: product['image'] ?? 'assets/images/bouquet_sample.png',
        price: double.parse(product['price'].toString()),
        quantity: json['quantity'] ?? 1,
      );
    }
    
    // Если json содержит прямые поля
    return CartItem(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      name: json['name'],
      image: json['image'] ?? 'assets/images/bouquet_sample.png',
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity,
    };
  }

  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    String? image,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
} 