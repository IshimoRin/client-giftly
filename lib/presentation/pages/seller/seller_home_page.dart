import 'package:flutter/material.dart';
import 'package:client_giftly/domain/models/user.dart';
import 'package:client_giftly/domain/models/user_role.dart';
import 'package:client_giftly/presentation/widgets/bottom_nav_bar.dart';
import 'orders_page.dart';
import 'stats_page.dart';
import 'store_page.dart';
import '../customer/profile_page.dart'; // Профиль общий для покупателя и продавца

class SellerHomePage extends StatefulWidget {
  final User user;

  const SellerHomePage({
    super.key,
    required this.user,
  });

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  late User _currentUser;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  void _updateUser(User updatedUser) {
    setState(() {
      _currentUser = updatedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Проверяем роль пользователя. Если не продавец, перенаправляем (на всякий случай)
    if (_currentUser.role != UserRole.seller) {
      // TODO: Перенаправить на главную страницу покупателя или страницу ошибки
      return const Center(child: Text('Ошибка: доступ запрещен')); // Временная заглушка
    }

    final List<Widget> _pages = [
      StorePage(), // Управление товарами
      OrdersPage(), // Заказы продавца
      StatsPage(), // Статистика магазина
      ProfilePage(user: _currentUser, onUserUpdated: _updateUser), // Профиль
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        role: _currentUser.role, // Передаем роль для отображения правильных пунктов меню
      ),
    );
  }
} 