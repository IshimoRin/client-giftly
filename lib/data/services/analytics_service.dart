import 'package:appmetrica_plugin/appmetrica_plugin.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // События оформления заказа
  Future<void> logOrderCreated({
    required String orderId,
    required double totalAmount,
    required int itemsCount,
    required List<String> productIds,
  }) async {
    await AppMetrica.reportEvent('order_created');
    await AppMetrica.reportEvent('order_details_${orderId}_${totalAmount.toStringAsFixed(0)}_${itemsCount}_${productIds.join("_")}');
  }

  // События добавления в избранное
  Future<void> logAddToFavorites({
    required String productId,
    required String productName,
    required double price,
  }) async {
    await AppMetrica.reportEvent('add_to_favorites');
    await AppMetrica.reportEvent('favorite_product_${productId}_${price.toStringAsFixed(0)}');
  }

  // События добавления в корзину
  Future<void> logAddToCart({
    required String productId,
    required String productName,
    required double price,
    required int quantity,
  }) async {
    await AppMetrica.reportEvent('add_to_cart');
    await AppMetrica.reportEvent('cart_product_${productId}_${price.toStringAsFixed(0)}_${quantity}');
  }

  // События взаимодействия с ИИ-помощником
  Future<void> logAIMessage({
    required String query,
    required bool isUserMessage,
    required int recommendationsCount,
    List<String>? recommendedProductIds,
  }) async {
    final eventName = isUserMessage ? 'ai_user_message' : 'ai_bot_response';
    await AppMetrica.reportEvent(eventName);
    if (recommendedProductIds != null && recommendedProductIds.isNotEmpty) {
      await AppMetrica.reportEvent('ai_recommendations_${recommendationsCount}_${recommendedProductIds.join("_")}');
    }
  }

  // События просмотра товара
  Future<void> logProductView({
    required String productId,
    required String productName,
    required double price,
    String? source,
  }) async {
    await AppMetrica.reportEvent('product_view');
    final sourceStr = source ?? 'unknown';
    await AppMetrica.reportEvent('view_product_${productId}_${price.toStringAsFixed(0)}_${sourceStr}');
  }

  // События поиска
  Future<void> logSearch({
    required String query,
    required int resultsCount,
  }) async {
    await AppMetrica.reportEvent('search');
    await AppMetrica.reportEvent('search_results_${resultsCount}');
  }

  // События фильтрации
  Future<void> logFilter({
    required Map<String, dynamic> filters,
    required int resultsCount,
  }) async {
    await AppMetrica.reportEvent('filter');
    final filterStr = filters.entries.map((e) => '${e.key}_${e.value}').join('_');
    await AppMetrica.reportEvent('filter_results_${filterStr}_${resultsCount}');
  }
} 