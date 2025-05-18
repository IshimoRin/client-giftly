class ApiConfig {
  // В режиме разработки используем локальный сервер
  static const bool isDevelopment = true;

  // URL API в зависимости от режима
  static String get baseUrl {
    if (isDevelopment) {
      return 'http://10.0.2.2:8000/api'; // для Android эмулятора
    }
    // Здесь будет URL вашего продакшн API после деплоя
    return 'https://your-api-domain.com/api';
  }

  // API ключ (если требуется)
  static const String apiKey = '';

  // Endpoints
  static String get loginUrl => '$baseUrl/auth/login/';
  static String get registerUrl => '$baseUrl/auth/register/';
  static String get productsUrl => '$baseUrl/products/';
  static String get cartUrl => '$baseUrl/cart/';
  static String get ordersUrl => '$baseUrl/orders/';
  static String get favoritesUrl => '$baseUrl/favorites/';
} 