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
          HelperPage(
            user: _currentUser,
            onCartUpdated: () {
              _cartPageKey.currentState?.updateCart();
            },
          ),
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
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'Все';
  String _sortBy = 'name';
  bool _isAscending = true;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'Все',
    'Букеты',
    'Композиции',
    'Подарки',
    'Свадьба',
    'Розы',
    'Тюльпаны',
    'Пионы',
    'Хризантемы',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final products = await _productService.getProducts();
      setState(() {
        _allProducts = products;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    var filtered = _allProducts.where((product) {
      final searchLower = _searchController.text.toLowerCase();
      final matchesSearch = searchLower.isEmpty || 
          product.name.toLowerCase().contains(searchLower) ||
          (product.description?.toLowerCase().contains(searchLower) ?? false);
      
      // Обновленная логика фильтрации по категориям
      bool matchesCategory = _selectedCategory == 'Все';
      if (!matchesCategory) {
        final productName = product.name.toLowerCase();
        final productDesc = product.description?.toLowerCase() ?? '';
        final category = _selectedCategory.toLowerCase();
        
        switch (_selectedCategory) {
          case 'Свадьба':
            matchesCategory = productName.contains('свадьб') || 
                             productName.contains('свадебн') ||
                             productDesc.contains('свадьб') ||
                             productDesc.contains('свадебн');
            break;
          case 'Розы':
            matchesCategory = productName.contains('роз') || 
                             productDesc.contains('роз');
            break;
          case 'Тюльпаны':
            matchesCategory = productName.contains('тюльпан') || 
                             productDesc.contains('тюльпан');
            break;
          case 'Пионы':
            matchesCategory = productName.contains('пион') || 
                             productDesc.contains('пион');
            break;
          case 'Хризантемы':
            matchesCategory = productName.contains('хризантем') || 
                             productDesc.contains('хризантем');
            break;
          default:
            matchesCategory = productName.contains(category) || 
                             productDesc.contains(category);
        }
      }
      
      return matchesSearch && matchesCategory;
    }).toList();

    // Применяем сортировку
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        default:
          comparison = 0;
      }
      return _isAscending ? comparison : -comparison;
    });

    setState(() {
      _filteredProducts = filtered;
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Фильтрация по категориям',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Новые категории цветов добавлены в каталог',
                        style: TextStyle(
                          color: Colors.amber[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Категория',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _categories.map((category) {
                  final isSelected = category == _selectedCategory;
                  final isNewCategory = category == 'Свадьба' || 
                                      category == 'Розы' || 
                                      category == 'Тюльпаны' || 
                                      category == 'Пионы' || 
                                      category == 'Хризантемы';
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(category),
                        if (isNewCategory) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'новое',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      this.setState(() {
                        _selectedCategory = category;
                        _applyFilters();
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color(0xFF9191E9).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF9191E9),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF9191E9) : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9191E9),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Закрыть',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSupportDialog() {
    final TextEditingController problemController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.support_agent, color: const Color(0xFF9191E9), size: 24),
            const SizedBox(width: 8),
            const Text(
              'Поддержка Gifty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF9191E9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF9191E9), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Мы всегда готовы помочь вам с любым вопросом',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9191E9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: problemController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Опишите ваш вопрос или проблему',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF9191E9), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, опишите ваш вопрос';
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
            child: const Text(
              'Отмена',
              style: TextStyle(color: Colors.grey),
            ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Отправить',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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
                              setState(() {
                                _applyFilters();
                              });
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
                          child: PopupMenuButton<String>(
                            icon: Icon(
                              _sortBy == 'name' 
                                  ? (_isAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha_outlined)
                                  : (_isAscending ? Icons.arrow_upward : Icons.arrow_downward),
                              color: const Color(0xFF9191E9),
                              size: 20,
                            ),
                            tooltip: 'Сортировка',
                            onSelected: (String value) {
                              setState(() {
                                switch (value) {
                                  case 'name_asc':
                                    _sortBy = 'name';
                                    _isAscending = true;
                                    break;
                                  case 'name_desc':
                                    _sortBy = 'name';
                                    _isAscending = false;
                                    break;
                                  case 'price_asc':
                                    _sortBy = 'price';
                                    _isAscending = true;
                                    break;
                                  case 'price_desc':
                                    _sortBy = 'price';
                                    _isAscending = false;
                                    break;
                                }
                                _applyFilters();
                              });
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'name_asc',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.sort_by_alpha,
                                      size: 20,
                                      color: _sortBy == 'name' && _isAscending 
                                          ? const Color(0xFF9191E9) 
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'По названию (А-Я)',
                                      style: TextStyle(
                                        color: _sortBy == 'name' && _isAscending 
                                            ? const Color(0xFF9191E9) 
                                            : Colors.black,
                                        fontWeight: _sortBy == 'name' && _isAscending 
                                            ? FontWeight.bold 
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'name_desc',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.sort_by_alpha_outlined,
                                      size: 20,
                                      color: _sortBy == 'name' && !_isAscending 
                                          ? const Color(0xFF9191E9) 
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'По названию (Я-А)',
                                      style: TextStyle(
                                        color: _sortBy == 'name' && !_isAscending 
                                            ? const Color(0xFF9191E9) 
                                            : Colors.black,
                                        fontWeight: _sortBy == 'name' && !_isAscending 
                                            ? FontWeight.bold 
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem<String>(
                                value: 'price_asc',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_upward,
                                      size: 20,
                                      color: _sortBy == 'price' && _isAscending 
                                          ? const Color(0xFF9191E9) 
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'По цене (возрастание)',
                                      style: TextStyle(
                                        color: _sortBy == 'price' && _isAscending 
                                            ? const Color(0xFF9191E9) 
                                            : Colors.black,
                                        fontWeight: _sortBy == 'price' && _isAscending 
                                            ? FontWeight.bold 
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'price_desc',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_downward,
                                      size: 20,
                                      color: _sortBy == 'price' && !_isAscending 
                                          ? const Color(0xFF9191E9) 
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'По цене (убывание)',
                                      style: TextStyle(
                                        color: _sortBy == 'price' && !_isAscending 
                                            ? const Color(0xFF9191E9) 
                                            : Colors.black,
                                        fontWeight: _sortBy == 'price' && !_isAscending 
                                            ? FontWeight.bold 
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                            onPressed: _showFilterDialog,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Каталог букетов',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedCategory != 'Все')
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Chip(
                                label: Text(_selectedCategory),
                                backgroundColor: const Color(0xFF9191E9).withOpacity(0.1),
                                labelStyle: const TextStyle(
                                  color: Color(0xFF9191E9),
                                ),
                                deleteIcon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Color(0xFF9191E9),
                                ),
                                onDeleted: () {
                                  setState(() {
                                    _selectedCategory = 'Все';
                                    _applyFilters();
                                  });
                                },
                              ),
                            ],
                          ),
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
                            final filteredIndex = _filteredProducts.indexWhere((p) => p.id == product.id);
                            if (filteredIndex != -1) {
                              _filteredProducts[filteredIndex] = updatedProduct;
                            }
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
