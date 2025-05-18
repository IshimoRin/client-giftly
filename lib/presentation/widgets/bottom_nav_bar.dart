import 'package:flutter/material.dart';
import '../../domain/models/user_role.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final UserRole role;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final items = _getNavigationItems();

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF9191E9),
      unselectedItemColor: Colors.grey,
      items: items,
    );
  }

  List<BottomNavigationBarItem> _getNavigationItems() {
    if (role == UserRole.seller) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Главная',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Заказы',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Статистика',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Профиль',
        ),
      ];
    }

    // Для гостей и покупателей показываем одинаковое меню
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Главная',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.smart_toy),
        label: 'Помощник',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: 'Корзина',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.favorite),
        label: 'Избранное',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Профиль',
      ),
    ];
  }
}
