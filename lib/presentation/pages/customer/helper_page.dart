import 'package:flutter/material.dart';
import '../../../domain/models/user.dart';
import '../../../domain/models/product.dart';
import '../../../data/services/recommendation_service.dart';
import '../../../data/services/cart_service.dart';
import '../../../data/services/analytics_service.dart';

class HelperPage extends StatefulWidget {
  final User? user;
  final VoidCallback? onCartUpdated;
  
  const HelperPage({
    Key? key,
    this.user,
    this.onCartUpdated,
  }) : super(key: key);


  @override
  _HelperPageState createState() => _HelperPageState();
}

class _HelperPageState extends State<HelperPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final RecommendationService _recommendationService = RecommendationService();
  final CartService _cartService = CartService();
  final AnalyticsService _analyticsService = AnalyticsService();
  bool _isLoading = false;

  final List<String> _quickSuggestions = [
    'Свадебный букет бюджет 4000',
    'Букет бюджет 3000',
    'Что подарить маме?',
    'Что подарить девушке?',
  ];

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    // Логируем сообщение пользователя
    await _analyticsService.logAIMessage(
      query: text,
      isUserMessage: true,
      recommendationsCount: 0,
    );

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _controller.clear();

    try {
      final result = await _recommendationService.getRecommendations(text);
      
      // Логируем ответ ИИ с рекомендациями
      await _analyticsService.logAIMessage(
        query: text,
        isUserMessage: false,
        recommendationsCount: (result['products'] as List?)?.length ?? 0,
        recommendedProductIds: (result['products'] as List?)
            ?.map((item) => (item['product'] as Product).id)
            .toList(),
      );
      
      setState(() {
        if (result['success'] == true) {
          // Извлекаем бюджет из запроса, если он указан
          int? budget;
          final budgetMatch = RegExp(r'бюджет\s*(\d+)').firstMatch(text.toLowerCase());
          if (budgetMatch != null) {
            budget = int.tryParse(budgetMatch.group(1) ?? '');
          }

          // Добавляем сообщение с рекомендациями
          final products = (result['products'] as List?)
              ?.map<RecommendedProduct>((item) {
                return RecommendedProduct(
                  product: item['product'] as Product,
                  relevance: item['relevance'] as int,
                );
              })
              .toList()
              ?.where((item) {
                // Фильтруем по бюджету, если он указан
                if (budget != null) {
                  return item.product.price <= budget!;
                }
                return true;
              })
              .toList()
              ?..sort((a, b) {
                // Сначала сортируем по релевантности
                final relevanceCompare = b.relevance.compareTo(a.relevance);
                if (relevanceCompare != 0) return relevanceCompare;
                
                // При равной релевантности сортируем по цене (от меньшей к большей)
                return a.product.price.compareTo(b.product.price);
              });

          _messages.add(ChatMessage(
            text: budget != null 
              ? '${result['message']} (в рамках бюджета ${budget}₽)'
              : result['message'],
            isUser: false,
            timestamp: DateTime.now(),
            products: products?.take(3).toList(), // Берем топ-3 самых релевантных
          ));
        } else {
          _messages.add(ChatMessage(
            text: 'Извините, произошла ошибка при получении рекомендаций.',
            isUser: false,
            timestamp: DateTime.now(),
          ));
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Извините, произошла ошибка: $e',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Помощник',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatMessageWidget(
                  message: message,
                  onProductTap: (product) {
                    // TODO: Добавить навигацию к деталям товара
                    print('Product tapped: ${product.name}');
                  },
                  cartService: _cartService,
                  onCartUpdated: widget.onCartUpdated,
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          // Quick Suggestions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: SizedBox(
              height: 40, // Adjust height as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _quickSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _quickSuggestions[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _sendMessage(suggestion),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200], // Light grey background
                        foregroundColor: Colors.black87, // Dark text
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 0, // No shadow
                      ),
                      child: Text(suggestion),
                    ),
                  );
                },
              ),
            ),
          ),
          // Input area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: 'Сообщение',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0), // Rounded corners
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white, // White background for input field
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Add spacing between text field and send button
                // Send Icon
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF9191E9)), // Theme color for send button
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<RecommendedProduct>? products;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.products,
  });
}

class RecommendedProduct {
  final Product product;
  final int relevance;

  RecommendedProduct({
    required this.product,
    required this.relevance,
  });
}

class _ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final Function(Product) onProductTap;
  final CartService cartService;
  final VoidCallback? onCartUpdated;

  const _ChatMessageWidget({
    Key? key,
    required this.message,
    required this.onProductTap,
    required this.cartService,
    this.onCartUpdated,
  }) : super(key: key);

  Future<void> _addToCart(BuildContext context, Product product) async {
    try {
      await cartService.addToCart(product.id);
      
      // Логируем добавление в корзину
      await AnalyticsService().logAddToCart(
        productId: product.id,
        productName: product.name,
        price: product.price,
        quantity: 1,
      );

      if (context.mounted) {
        onCartUpdated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Товар добавлен в корзину'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при добавлении в корзину: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.purple[100], // Placeholder, will replace with image later if needed
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assistant,
                    color: Colors.purple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!message.isUser) ...[
                      Text(
                        'Бот-помощник',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: message.isUser ? Color(0xFFE1F5FE) : Color(0xFFEEEEEE), // Light blue for user, light grey for bot
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.text,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          if (message.products != null && message.products!.isNotEmpty) ...[
                            SizedBox(height: 12),
                            Text(
                              'Рекомендуемые букеты:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            ...message.products!.map((recommended) {
                              final product = recommended.product;
                              return Card(
                                margin: EdgeInsets.only(bottom: 8),
                                elevation: 2, // Add slight elevation to cards
                                child: InkWell(
                                  onTap: () => onProductTap(product),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                product.image,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    width: 60,
                                                    height: 60,
                                                    color: Colors.grey[200],
                                                    child: Icon(Icons.image_not_supported),
                                                  );
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product.name,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    '${product.price.toStringAsFixed(2)} ₽',
                                                    style: TextStyle(
                                                      color: Colors.green[700],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  if (recommended.relevance > 0)
                                                    Text(
                                                      'Релевантность: ${recommended.relevance}%',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () => _addToCart(context, product),
                                            icon: Icon(Icons.shopping_cart, size: 18),
                                            label: Text('Добавить в корзину'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(0xFF9191E9),
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(vertical: 8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue[100], // Placeholder, will replace with image later if needed
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
          // Timestamp
          Padding(
            padding: EdgeInsets.only(top: 4.0, right: message.isUser ? 12.0 : 0.0, left: message.isUser ? 0.0 : 12.0), // Adjust padding based on sender
            child: Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'только что';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин. назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч. назад';
    } else {
      return '${timestamp.day}.${timestamp.month}.${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

