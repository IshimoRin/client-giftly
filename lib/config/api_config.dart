class ApiConfig {
  // В режиме разработки используем локальный сервер
  static const bool isDevelopment = false;

  // URL API в зависимости от режима
  static String get baseUrl {
    if (isDevelopment) {
      return 'http://10.0.2.2:8000/api'; // для Android эмулятора
    }
    // URL продакшн API
    return 'http://185.91.54.146/api';
  }

  // API ключ (если требуется)
  static const String apiKey = '';

  // Endpoints
  static String get loginUrl => '$baseUrl/users/login/';
  static String get registerUrl => '$baseUrl/users/register/';
  static String get productsUrl => '$baseUrl/products/';
  static String get cartUrl => '$baseUrl/cart/';
  static String get ordersUrl => '$baseUrl/orders/';
  static String get favoritesUrl => '$baseUrl/favorites/';
} 