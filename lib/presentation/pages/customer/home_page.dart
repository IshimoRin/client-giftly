import 'package:flutter/material.dart';
import 'package:giftly/presentation/pages/customer/cart_page.dart';
import 'package:giftly/presentation/pages/customer/favorite_page.dart';
import 'package:giftly/presentation/pages/customer/helper_page.dart';
import 'package:giftly/presentation/pages/customer/profile_page.dart';
import 'package:giftly/presentation/pages/login_page.dart';
import 'package:giftly/presentation/pages/seller/orders_page.dart';
import 'package:giftly/presentation/pages/seller/stats_page.dart';
import 'package:giftly/presentation/widgets/bottom_nav_bar.dart';
import 'package:giftly/domain/models/user_role.dart';
import 'package:giftly/domain/models/user.dart';

class HomePage extends StatefulWidget {
  final User user;
  
  const HomePage({
    super.key,
    required this.user,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = _getScreensByRole(widget.user);
  }

  List<Widget> _getScreensByRole(User user) {
    // Базовые экраны доступны всем
    final List<Widget> screens = [
      _MainContent(),
    ];

    // Для гостя показываем те же страницы, что и для покупателя
    if (user.role == UserRole.guest || user.role == UserRole.customer) {
      screens.addAll([
        const HelperPage(),
        CartPage(user: user),
        FavoritePage(user: user),
        ProfilePage(user: user),
      ]);
    } else if (user.role == UserRole.seller) {
      screens.addAll([
        const OrdersPage(),
        const StatsPage(),
        ProfilePage(user: user),
      ]);
    }
    return screens;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _currentIndex == 0 
        ? NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  toolbarHeight: 90,
                  pinned: true,
                  floating: true,
                  expandedHeight: 150,
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(top: 34.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.support_agent,
                              color: Color(0xFFB3B3B3),
                              size: 22,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              // TODO: Implement support
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(55),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 6.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F8F8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const TextField(
                                decoration: InputDecoration(
                                  hintText: 'Букеты, подарки и открытки',
                                  hintStyle: TextStyle(
                                    color: Color(0xFFB3B3B3),
                                    fontSize: 15,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Color(0xFFB3B3B3),
                                    size: 22,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.tune,
                                color: Color(0xFFB3B3B3),
                                size: 22,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                // TODO: Implement filters
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: _screens[_currentIndex],
          )
        : _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        role: widget.user.role,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// Выносим главный контент в отдельный виджет
class _MainContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/banner.png'),
            const SizedBox(height: 16),
            const Text(
              'Вы недавно смотрели',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) => _buildBouquetCard(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Каталог букетов',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              itemBuilder: (context, index) => _buildVerticalBouquetCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBouquetCard() {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.asset(
              'assets/images/bouquet_sample.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Букет невесты\nс хризантемами',
            style: TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          const Text('4 500 ₽', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF9191E9),
              minimumSize: const Size.fromHeight(30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.shopping_cart, size: 16),
            label: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalBouquetCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/bouquet_sample.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Букет с розами и лилиями',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Нежный букет, идеально подходит для любого праздника.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '3 900 ₽',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9191E9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.shopping_cart, size: 16),
                      label: const Text('Добавить'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
