class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final bool isFavorite;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.isFavorite = false,
  });

  // Создаем объект из JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    // Преобразуем цену в double, обрабатывая как строковые, так и числовые значения
    double parsePrice(dynamic value) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.parse(value);
      }
      return 0.0;
    }

    return Product(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'] ?? '',
      price: parsePrice(json['price']),
      image: json['image'] ?? '',
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  // Преобразуем объект в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'is_favorite': isFavorite,
    };
  }

  // Создаем копию объекта с новыми значениями
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? image,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
} 