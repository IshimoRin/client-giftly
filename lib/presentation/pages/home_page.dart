import 'package:flutter/material.dart';
import 'package:giftly/presentation/pages/favorite_page.dart';
import 'package:giftly/presentation/pages/helper_page.dart';
import 'package:giftly/presentation/pages/profile_page.dart';
import 'package:giftly/presentation/widgets/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    _MainContent(), // Выносим главный контент в отдельный виджет
    const HelperPage(),
    const Center(child: Text('Корзина')),
    const FavoritePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          _currentIndex == 0
              ? _buildAppBar()
              : null, // Показываем AppBar только на главной
      body: _screens[_currentIndex], // Отображаем текущий экран
      bottomNavigationBar: BottomNavBar(
        // отображаем нижнее меню
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const TextField(
        decoration: InputDecoration(
          hintText: 'Букеты, подарки и открытки',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          filled: true,
          fillColor: Color(0xFFF1F1F1),
        ),
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
