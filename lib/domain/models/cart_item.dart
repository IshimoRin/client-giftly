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
    print('Debug: CartItem.fromJson входные данные: $json');
    
    // Если json содержит вложенный объект product
    if (json['product'] != null) {
      final product = json['product'];
      print('Debug: Обработка вложенного product: $product');
      return CartItem(
        id: json['id'].toString(),
        productId: product['id'].toString(),
        name: product['name'],
        image: _getValidImageUrl(product['image_url']),
        price: double.parse(product['price'].toString()),
        quantity: json['quantity'] ?? 1,
      );
    }
    
    // Если json содержит прямые поля
    print('Debug: Обработка прямых полей');
    return CartItem(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      name: json['name'],
      image: _getValidImageUrl(json['image_url']),
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'] ?? 1,
    );
  }

  static String _getValidImageUrl(dynamic imageUrl) {
    if (imageUrl == null || imageUrl.toString().isEmpty) {
      print('Debug: Пустой URL изображения, используем заглушку');
      return 'assets/images/bouquet_sample.png';
    }
    
    final url = imageUrl.toString();
    print('Debug: Обработка URL изображения: $url');
    
    // Если URL уже полный, заменяем https на http
    if (url.startsWith('http://') || url.startsWith('https://')) {
      final httpUrl = url.replaceFirst('https://', 'http://');
      print('Debug: URL преобразован в HTTP: $httpUrl');
      return httpUrl;
    }
    
    // Если URL начинается с /media/
    if (url.startsWith('/media/')) {
      final fullUrl = 'http://185.91.54.146$url';
      print('Debug: Преобразован URL с /media/: $fullUrl');
      return fullUrl;
    }
    
    // Если URL начинается с /
    if (url.startsWith('/')) {
      final fullUrl = 'http://185.91.54.146$url';
      print('Debug: Преобразован URL с /: $fullUrl');
      return fullUrl;
    }
    
    // Если URL не начинается с /, добавляем его
    final fullUrl = 'http://185.91.54.146/$url';
    print('Debug: Преобразован URL без /: $fullUrl');
    return fullUrl;
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