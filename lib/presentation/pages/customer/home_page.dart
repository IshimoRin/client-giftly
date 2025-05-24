import 'package:flutter/material.dart';
import 'package:client_giftly/presentation/pages/customer/cart_page.dart';
import 'package:client_giftly/presentation/pages/customer/favorite_page.dart';
import 'package:client_giftly/presentation/pages/customer/profile_page.dart';
import 'package:client_giftly/presentation/pages/customer/helper_page.dart';
import 'package:client_giftly/presentation/pages/login_page.dart';
import 'package:client_giftly/presentation/pages/seller/orders_page.dart';
import 'package:client_giftly/presentation/pages/seller/stats_page.dart';
import 'package:client_giftly/presentation/widgets/bottom_nav_bar.dart';
import 'package:client_giftly/domain/models/user_role.dart';
import 'package:client_giftly/domain/models/user.dart';
import 'package:client_giftly/data/services/product_service.dart';
import 'package:client_giftly/data/services/cart_service.dart';
import 'package:client_giftly/domain/models/product.dart';
import 'package:client_giftly/presentation/widgets/product_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  final User user;
  
  const HomePage({
    super.key,
    required this.user,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User _currentUser;
  int _selectedIndex = 0;
  final GlobalKey<CartPageState> _cartPageKey = GlobalKey<CartPageState>();
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadProducts();
  }

  void _updateUser(User updatedUser) {
    setState(() {
      _currentUser = updatedUser;
      _selectedIndex = 4; // Возвращаем на страницу профиля
    });
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final products = await _productService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _MainContent(onCartUpdated: () {
            _cartPageKey.currentState?.updateCart();
          }),
          HelperPage(),
          FavoritePage(
            user: _currentUser,
            onCartUpdated: () {
              _cartPageKey.currentState?.updateCart();
            },
            onFavoritesUpdated: () {
              setState(() {}); // Обновляем состояние при изменении избранного
            },
          ),
          CartPage(key: _cartPageKey, user: _currentUser),
          ProfilePage(
            user: _currentUser,
            onUserUpdated: _updateUser,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'ИИ Помощник',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Избранное',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Корзина',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

// Выносим главный контент в отдельный виджет
class _MainContent extends StatefulWidget {
  final VoidCallback onCartUpdated;

  const _MainContent({
    Key? key,
    required this.onCartUpdated,
  }) : super(key: key);

  @override
  State<_MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<_MainContent> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  List<Product> _allProducts = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Все';
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _showSupportDialog() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController problemController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поддержка'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Введите ваш email',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите email';
                  }
                  if (!value.contains('@')) {
                    return 'Пожалуйста, введите корректный email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: problemController,
                decoration: const InputDecoration(
                  labelText: 'Опишите вашу проблему',
                  hintText: 'Напишите подробно о вашей проблеме',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, опишите вашу проблему';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // TODO: Отправить сообщение в поддержку
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Сообщение отправлено в поддержку'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9191E9),
            ),
            child: const Text(
              'Отправить',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final allProducts = await _productService.getProducts();

      if (mounted) {
        setState(() {
          _allProducts = allProducts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<Product> get _filteredProducts {
    var filtered = _allProducts.where((product) {
      final searchLower = _searchController.text.toLowerCase();
      final matchesSearch = searchLower.isEmpty || 
          product.name.toLowerCase().contains(searchLower) ||
          (product.description?.toLowerCase().contains(searchLower) ?? false);
      final matchesCategory = _selectedCategory == 'Все' || product.name.contains(_selectedCategory);
      return matchesSearch && matchesCategory;
    }).toList();

    // Сортировка по цене
    filtered.sort((a, b) {
      if (_isAscending) {
        return a.price.compareTo(b.price);
      } else {
        return b.price.compareTo(a.price);
      }
    });

    return filtered;
  }

  void _toggleSort() {
    setState(() {
      _isAscending = !_isAscending;
    });
  }

  Future<void> _addToCart(Product product) async {
    try {
      final cart = await _cartService.addToCart(product.id);
      if (mounted) {
        widget.onCartUpdated(); // Обновляем корзину
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Товар добавлен в корзину'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Не удалось загрузить товары',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadProducts,
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadProducts();
      },
      child: Container(
        color: Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: 120,
              flexibleSpace: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Location and Support Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Location
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 18, color: Color(0xFF9191E9)),
                            const SizedBox(width: 4),
                            Text(
                              'Воронеж',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        // Support Button
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEFF1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.support_agent, color: Color(0xFF9191E9), size: 20),
                            onPressed: _showSupportDialog,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Search Bar and Filter Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Поиск по названию или описанию',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFe8e8e8),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Кнопка сортировки
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEFF1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                              color: const Color(0xFF9191E9),
                              size: 20,
                            ),
                            onPressed: _toggleSort,
                            tooltip: _isAscending ? 'По возрастанию' : 'По убыванию',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEFF1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.filter_list, color: Color(0xFF9191E9), size: 20),
                            onPressed: () {
                              // TODO: Открыть фильтры
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Image.asset('assets/images/banner.png'),
                      const SizedBox(height: 16),
                      const Text(
                        'Каталог букетов',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) => _buildProductCard(_filteredProducts[index]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CachedNetworkImage(
                    imageUrl: product.image,
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9191E9)),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/bouquet_sample.png',
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      try {
                        final updatedProduct = await _productService.toggleFavorite(product);
                        setState(() {
                          final index = _allProducts.indexWhere((p) => p.id == product.id);
                          if (index != -1) {
                            _allProducts[index] = updatedProduct;
                          }
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                updatedProduct.isFavorite 
                                  ? 'Товар добавлен в избранное'
                                  : 'Товар удален из избранного'
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Ошибка при обновлении избранного: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        product.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: product.isFavorite ? Colors.red : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Product Description (Added)
                  if (product.description != null && product.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0), // Spacing between name and description
                      child: Text(
                        product.description!,
                        style: TextStyle(
                          fontSize: 11, // Smaller font size for description
                          color: Colors.grey[700],
                        ),
                        maxLines: 2, // Limit description to 2 lines
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 4), // Spacing between description/name and price/button block
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(0)} ₽',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _addToCart(product),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9191E9),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 6), // Reduced vertical padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'В корзину',
                              style: TextStyle(
                                fontSize: 12, // Reduced font size
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
