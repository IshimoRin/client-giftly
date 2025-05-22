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

    // Валидация URL изображения
    String validateImageUrl(dynamic imageUrl) {
      if (imageUrl == null || imageUrl.toString().isEmpty) {
        print('Debug: Пустой URL изображения, используем заглушку');
        return 'assets/images/bouquet_sample.png';
      }
      
      final url = imageUrl.toString();
      print('Debug: Обработка URL изображения: $url');
      
      // Если URL уже полный
      if (url.startsWith('http://') || url.startsWith('https://')) {
        print('Debug: URL уже полный: $url');
        return url;
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

    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: parsePrice(json['price']),
      image: validateImageUrl(json['image_url']),
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
      'image_url': image,
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