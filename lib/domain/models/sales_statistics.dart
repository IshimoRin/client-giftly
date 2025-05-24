class SalesStatistics {
  final double totalSales;
  final int orderCount;
  final List<DailyStatistics> dailyStats;
  final List<ProductStatistics> topProducts;

  SalesStatistics({
    required this.totalSales,
    required this.orderCount,
    required this.dailyStats,
    required this.topProducts,
  });

  factory SalesStatistics.fromJson(Map<String, dynamic> json) {
    return SalesStatistics(
      totalSales: double.parse(json['total_sales'].toString()),
      orderCount: json['order_count'],
      dailyStats: (json['daily_stats'] as List)
          .map((stat) => DailyStatistics.fromJson(stat))
          .toList(),
      topProducts: (json['top_products'] as List)
          .map((product) => ProductStatistics.fromJson(product))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sales': totalSales,
      'order_count': orderCount,
      'daily_stats': dailyStats.map((stat) => stat.toJson()).toList(),
      'top_products': topProducts.map((product) => product.toJson()).toList(),
    };
  }
}

class DailyStatistics {
  final DateTime date;
  final double sales;
  final int orders;

  DailyStatistics({
    required this.date,
    required this.sales,
    required this.orders,
  });

  factory DailyStatistics.fromJson(Map<String, dynamic> json) {
    return DailyStatistics(
      date: DateTime.parse(json['date']),
      sales: double.parse(json['sales'].toString()),
      orders: json['orders'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'sales': sales,
      'orders': orders,
    };
  }
}

class ProductStatistics {
  final int productId;
  final String productName;
  final int salesCount;
  final double totalRevenue;

  ProductStatistics({
    required this.productId,
    required this.productName,
    required this.salesCount,
    required this.totalRevenue,
  });

  factory ProductStatistics.fromJson(Map<String, dynamic> json) {
    return ProductStatistics(
      productId: json['product_id'],
      productName: json['product_name'],
      salesCount: json['sales_count'],
      totalRevenue: double.parse(json['total_revenue'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'sales_count': salesCount,
      'total_revenue': totalRevenue,
    };
  }
} 