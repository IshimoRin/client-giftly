import 'package:flutter/material.dart';
import '../../../domain/models/user.dart';
import '../../../domain/models/user_role.dart';
import '../../widgets/login_prompt.dart';
import 'package:client_giftly/presentation/pages/about_app_page.dart';
import 'package:client_giftly/presentation/pages/settings_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/services/auth_service.dart';
import 'package:client_giftly/presentation/pages/login_page.dart';
import '../../../domain/models/order.dart';
import '../../../data/services/order_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  final Function(User) onUserUpdated;

  const ProfilePage({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User _currentUser;
  bool _notificationsEnabled = true;
  Widget? _currentContent;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  @override
  void dispose() {
    // No-op
    super.dispose();
  }

  void _navigateTo(Widget content) {
    setState(() {
      _currentContent = content;
    });
  }

  void _navigateBack() {
    setState(() {
      _currentContent = null;
    });
  }

  void _updateUser(User updatedUser) {
    setState(() {
      _currentUser = updatedUser;
      _currentContent = null;
    });
    widget.onUserUpdated(updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser.role == UserRole.guest) {
      return const Scaffold(
        body: LoginPrompt(
          message: 'Войдите или зарегистрируйтесь, чтобы получить доступ к профилю',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _currentUser.role == UserRole.seller ? 'Профиль продавца' : 'Профиль',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await AuthService().logout();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка при выходе: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: _currentContent ?? _buildMainContent(context),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return ListView(
      children: [
        if (_currentUser.role != UserRole.guest) ...[
          // Аватар и имя пользователя
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _currentUser.photoUrl != null
                      ? NetworkImage(_currentUser.photoUrl!)
                      : null,
                  child: _currentUser.photoUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  _currentUser.name ?? 'Пользователь',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_currentUser.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _currentUser.email!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        // Опции профиля
        _buildProfileOptions(context),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Column(
      children: [
        _buildOptionTile(
          title: 'Личные данные',
          icon: Icons.person,
          onTap: () {
            _navigateTo(PersonalDataContent(
              user: _currentUser,
              onUserUpdated: _updateUser,
            ));
          },
        ),
        _buildProfileOption(
          context: context,
          title: 'Настройки',
          icon: Icons.settings,
          tag: 'В разработке',
          onTap: () {
            _navigateTo(SettingsContent());
          },
        ),
        if (_currentUser.role == UserRole.customer) ...[
          _buildProfileOption(
            context: context,
            title: 'История заказов',
            icon: Icons.history,
            onTap: () {
              if (_currentUser != null) {
                _navigateTo(OrderHistoryContent(user: _currentUser));
              } else {
                print('Ошибка: Пользователь не авторизован или данные не загружены.');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Пожалуйста, войдите в аккаунт.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          _buildProfileOption(
            context: context,
            title: 'Как стать продавцом',
            icon: Icons.business,
            onTap: () {
              _navigateTo(const BecomeSellerContent());
            },
          ),
        ],
        _buildProfileOption(
          context: context,
          title: 'Правовые документы',
          icon: Icons.description,
          onTap: () {
            _navigateTo(const LegalDocsContent());
          },
        ),
        if (_currentUser.role == UserRole.seller) ...[
          _buildProfileOption(
            context: context,
            title: 'Положение для продавца',
            icon: Icons.handshake_outlined,
            onTap: () {
              _navigateTo(const SellerAgreementContent());
            },
          ),
        ],
        _buildProfileOption(
          context: context,
          title: 'О возврате товара',
          icon: Icons.help,
          onTap: () {
            _navigateTo(const ReturnPolicyContent());
          },
        ),
        _buildProfileOption(
          context: context,
          title: 'Поддержка Gifty',
          icon: Icons.support_agent,
          tag: 'Всегда на связи',
          onTap: () {
            _showSupportDialog();
          },
        ),
        _buildProfileOption(
          context: context,
          title: 'GitHub репозиторий',
          icon: Icons.code,
          onTap: () async {
            final url = 'https://github.com/Dodger0072/Programming-technologies-project';
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
            }
          },
        ),
        _buildProfileOption(
          context: context,
          title: 'О приложении',
          icon: Icons.info,
          onTap: () {
            _navigateTo(const AboutAppContent());
          },
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      onTap: onTap,
    );
  }

  Widget _buildProfileOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    String? tag,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          if (tag != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF9191E9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      onTap: onTap,
    );
  }

  // Метод для отображения диалога поддержки (скопировано из home_page.dart)
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
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Введите ваш email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Color(0xFF91BDE9), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
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
                decoration: InputDecoration(
                  labelText: 'Опишите вашу проблему',
                  hintText: 'Напишите подробно о вашей проблеме',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Color(0xFF91BDE9), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
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
                print('Сообщение отправлено в поддержку от ${emailController.text}'); // Логируем email
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
}

class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Русский';
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final profilePage = context.findAncestorStateOfType<_ProfilePageState>();
            profilePage?._navigateBack();
          },
        ),
        title: const Text(
          'Настройки',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.orange.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Эта функция находится в разработке',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Тема приложения
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Внешний вид',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Тёмная тема'),
                        subtitle: Text(_isDarkMode ? 'Включена' : 'Выключена'),
                        value: _isDarkMode,
                        onChanged: null, // Делаем неактивным
                      ),
                      ListTile(
                        title: const Text('Размер текста'),
                        subtitle: Slider(
                          value: _fontSize,
                          min: 12,
                          max: 24,
                          divisions: 4,
                          label: '${_fontSize.round()}',
                          onChanged: null, // Делаем неактивным
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Уведомления
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Уведомления',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Push-уведомления'),
                        subtitle: const Text('Уведомления о заказах и акциях'),
                        value: _notificationsEnabled,
                        onChanged: null, // Делаем неактивным
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Язык
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Язык',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      RadioListTile<String>(
                        title: const Text('Русский'),
                        value: 'Русский',
                        groupValue: _selectedLanguage,
                        onChanged: null, // Делаем неактивным
                      ),
                      RadioListTile<String>(
                        title: const Text('English'),
                        value: 'English',
                        groupValue: _selectedLanguage,
                        onChanged: null, // Делаем неактивным
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Кнопка сохранения
                ElevatedButton(
                  onPressed: null, // Делаем неактивной
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9191E9).withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Сохранить настройки'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderHistoryContent extends StatefulWidget {
  final User user;
  const OrderHistoryContent({super.key, required this.user});

  @override
  State<OrderHistoryContent> createState() => _OrderHistoryContentState();
}

class _OrderHistoryContentState extends State<OrderHistoryContent> {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  List<Order> _filteredOrders = []; // Список для отображения после фильтрации
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController(); // Контроллер для поля поиска
  OrderStatus? _selectedStatus; // Переменная для хранения выбранного статуса

  @override
  void initState() {
    super.initState();
    _loadOrders();
    // Добавляем слушатель для поля поиска
    _searchController.addListener(_filterOrders);
  }

  @override
  void dispose() {
    _searchController.dispose(); // Очищаем контроллер при удалении виджета
    super.dispose();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await _orderService.getUserOrders();
      setState(() {
        _orders = orders; // Сохраняем полный список
        _filteredOrders = orders; // Изначально отфильтрованный список равен полному
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Метод для фильтрации заказов
  void _filterOrders() {
    final query = _searchController.text.toLowerCase().trim(); // Удаляем пробелы по краям
    setState(() {
      _filteredOrders = _orders.where((order) {
        final orderNumberMatch = order.id?.toLowerCase().contains(query) ?? false;
        final productNameMatch = order.items.any((item) => item.name.toLowerCase().contains(query));

        // Проверяем соответствие выбранному статусу
        final statusMatch = _selectedStatus == null || order.status == _selectedStatus;

        return (orderNumberMatch || productNameMatch) && statusMatch;
      }).toList();
      
      // Если поисковый запрос пустой и статус не выбран, показываем все заказы
      if (query.isEmpty && _selectedStatus == null) {
         _filteredOrders = List.from(_orders);
      }
    });
  }

  // Метод для отображения диалога выбора статуса
  void _showStatusFilter() {
    showModalBottomSheet( // Используем bottom sheet для выбора статуса
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Все заказы'),
                onTap: () {
                  setState(() {
                    _selectedStatus = null; // Сброс фильтра
                  });
                  _filterOrders();
                  Navigator.pop(context);
                },
              ),
              ...OrderStatus.values.map((status) => ListTile(
                title: Text(_getStatusText(status)),
                onTap: () {
                  setState(() {
                    _selectedStatus = status;
                  });
                  _filterOrders();
                  Navigator.pop(context);
                },
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'В обработке';
      case OrderStatus.completed:
        return 'Завершён';
      case OrderStatus.canceled:
        return 'Отменён';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.canceled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final profilePage = context.findAncestorStateOfType<_ProfilePageState>();
            profilePage?._navigateBack();
          },
        ),
        title: const Text(
          'История заказов',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Номер заказа, товар',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0)
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: GestureDetector(
              onTap: _showStatusFilter,
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: Colors.grey[700]),
                  SizedBox(width: 8.0),
                  Text(
                    _selectedStatus == null
                        ? 'Все заказы'
                        : _getStatusText(_selectedStatus!), // Отображаем выбранный статус
                    style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ошибка при загрузке заказов',
                              style: TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadOrders,
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      )
                    : _filteredOrders.isEmpty
                        ? const Center(
                            child: Text(
                              'У вас пока нет заказов',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = _filteredOrders[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 2.0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.person, size: 16.0, color: Colors.grey[600]),
                                              SizedBox(width: 4.0),
                                              Text(
                                                widget.user.name ?? 'Пользователь',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            'от ${order.createdAt.toString().split('.')[0].split(' ')[0]}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '№${order.id}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(order.status).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              _getStatusText(order.status),
                                              style: TextStyle(
                                                color: _getStatusColor(order.status),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '${order.totalAmount.toStringAsFixed(2)} ₽',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Оплачен',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          ...order.items.take(4).map((item) => Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: item.image.isNotEmpty
                                                ? (item.image == 'assets/images/bouquet_sample.png'
                                                    ? ClipRRect(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                        child: Image.asset(
                                                            item.image,
                                                            width: 60, 
                                                            height: 60, 
                                                            fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : ClipRRect(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                        child: CachedNetworkImage(
                                                            imageUrl: item.image,
                                                            width: 60, 
                                                            height: 60, 
                                                            fit: BoxFit.cover,
                                                            placeholder: (context, url) => Container(
                                                              width: 60,
                                                              height: 60,
                                                              color: Colors.grey[300],
                                                            ),
                                                            errorWidget: (context, url, error) => Container(
                                                              width: 60,
                                                              height: 60,
                                                              color: Colors.grey[300],
                                                              child: Icon(Icons.error),
                                                            ),
                                                        ),
                                                      ))
                                                : Container(
                                                    width: 60, 
                                                    height: 60, 
                                                    color: Colors.grey[300],
                                                    child: Icon(Icons.image_not_supported),
                                                  ),
                                          )),
                                          if (order.items.length > 4) Expanded(child: Text('+${order.items.length - 4} еще', style: TextStyle(color: Colors.grey[600]))),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          _showRatingDialog(order.id);
                                        },
                                         style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF9191E9),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          minimumSize: const Size(double.infinity, 0),
                                        ),
                                        child: const Text(
                                          'Оцените нас',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // Метод для отображения диалога оценки
  void _showRatingDialog(String? orderId) {
    double _rating = 0.0;
    final TextEditingController _reviewController = TextEditingController();

    showDialog( // Используем Dialog для окна оценки
      context: context,
      builder: (BuildContext context) {
        // Используем StatefulBuilder для обновления состояния внутри диалога
        return AlertDialog(
          title: const Text(
            'Оцените заказ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
          content: SingleChildScrollView(
            child: StatefulBuilder( // Оборачиваем контент в StatefulBuilder
              builder: (BuildContext context, StateSetter setState) {
                return ListBody(
                  children: <Widget>[
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 30, // Увеличим размер звезд для удобства
                            ),
                            onPressed: () {
                              setState(() {
                                _rating = index + 1.0; // Обновляем рейтинг
                              });
                            },
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _reviewController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Напишите ваш отзыв...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Отправить'),
              onPressed: () {
                // TODO: Отправить оценку и отзыв на сервер
                print('Отправка оценки для заказа $orderId: Рейтинг $_rating, Отзыв: ${_reviewController.text}');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class PersonalDataContent extends StatefulWidget {
  final User user;
  final Function(User) onUserUpdated;

  const PersonalDataContent({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<PersonalDataContent> createState() => _PersonalDataContentState();
}

class _PersonalDataContentState extends State<PersonalDataContent> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _birthDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize form fields with user data
    final nameParts = widget.user.name?.split(' ') ?? [];
    _firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : '';
    _lastNameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    _phoneController.text = widget.user.phone ?? '';
    _birthDate = widget.user.birthDate;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.user.id.isEmpty) {
        throw Exception('Ошибка: не удалось определить пользователя. Попробуйте выйти и войти снова.');
      }

      final updatedUser = await AuthService().updateProfile(
        userId: widget.user.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        birthDate: _birthDate,
      );

      if (mounted) {
        widget.onUserUpdated(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Данные успешно обновлены'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final profilePage = context.findAncestorStateOfType<_ProfilePageState>();
            profilePage?._navigateBack();
          },
        ),
        title: const Text(
          'Личные данные',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Имя',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  hintText: 'Введите имя',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Color(0xFF91BDE9), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Фамилия',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  hintText: 'Введите фамилию',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Color(0xFF91BDE9), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Телефон',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Введите номер телефона',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Color(0xFF91BDE9), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Дата рождения',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.shade50,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _birthDate != null
                            ? '${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}'
                            : 'Выберите дату',
                        style: TextStyle(
                          color: _birthDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9191E9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Сохранить',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LegalDocsContent extends StatelessWidget {
  const LegalDocsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final profilePage = context.findAncestorStateOfType<_ProfilePageState>();
            profilePage?._navigateBack();
          },
        ),
        title: const Text(
          'Правовые документы',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Общие положения',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1.1. Настоящая публичная оферта (далее — Оферта) определяет условия продажи товаров через интернет-магазин Продавца по адресу [сайт магазина].',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              '1.2. Термины и определения:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 4),
            Text(
              'Покупатель – физическое лицо, достигшее 18 лет, заключившее с Продавцом договор купли-продажи на условиях, изложенных в настоящей Оферте.\nЗаказ – заявка Покупателя на приобретение товара, оформленная в интернет-магазине.\nТовар – перечень продукции, представленный на сайте Продавца и имеющий описание и цену.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),

            Text(
              '2. Предмет оферты',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '2.1. Продавец обязуется передать в собственность Покупателю товар, а Покупатель обязуется принять и оплатить товар на условиях, предусмотренных настоящей Офертой.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              '2.2. Договор считается заключенным с момента подтверждения Заказа Продавцом любым доступным способом (по телефону, электронной почте, СМС).',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),

            Text(
              '3. Цена и порядок оплаты товара',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '3.1. Цена товара указывается на сайте Продавца в рублях РФ и включает налог на добавленную стоимость (НДС).',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 8),
            Text(
              '3.2. Оплата товара производится:\nbанковской картой онлайн;\nналичными курьеру (при доставке);\nбезналичным переводом на расчетный счет Продавца.',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 8),
            Text(
              '3.3. После оплаты Покупателю направляется электронный чек в соответствии с законодательством РФ.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),

            Text(
              '4. Доставка и самовывоз',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '4.1. Доставка товара осуществляется по адресу, указанному Покупателем при оформлении Заказа.',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 4),
            Text(
              '4.2. Стоимость и сроки доставки указываются при оформлении Заказа.',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 4),
            Text(
              '4.3. Возможен самовывоз товара по адресу: [адрес пункта выдачи].',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 4),
            Text(
              '4.4. В случае изменения времени доставки по вине Покупателя, Продавец оставляет за собой право взимать дополнительную плату.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class ReturnPolicyContent extends StatelessWidget {
  const ReturnPolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final profilePage = context.findAncestorStateOfType<_ProfilePageState>();
            profilePage?._navigateBack();
          },
        ),
        title: const Text(
          'О возврате товара',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 16),
            Text(
              '1. Можно ли вернуть товар, если он не понравился?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Цветы, бенто-торты, скоропортящиеся товары и изделия ручной работы возврату и обмену не подлежат, если они соответствуют описанию и качеству.',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 8),
             Text(
              'Если товар был доставлен с дефектом или не соответствует заказу, свяжитесь с нами в течение 24 часов через поддержку, и мы решим вопрос.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '2. Как оформить возврат?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1. Напишите в поддержку Giftly (соответствующий раздел в профиле или на главной странице кнопка сверху) в течение 24 часов после получения.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              '2. Укажите номер заказа, фото товара и описание проблемы.',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 4),
             Text(
              '3. Мы свяжемся с продавцом и предложим решение: замену, частичный или полный возврат средств.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '3. Когда вернут деньги?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Срок возврата – от 3 до 10 рабочих дней, в зависимости от платежной системы.',
              style: TextStyle(fontSize: 14),
            ),
            // Здесь будут правовые документы
          ],
        ),
      ),
    );
  }
}

class SupportContent extends StatelessWidget {
  const SupportContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final profilePage = context.findAncestorStateOfType<_ProfilePageState>();
            profilePage?._navigateBack();
          },
        ),
        title: const Text(
          'Поддержка Gifty',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            // Здесь будет поддержка
          ],
        ),
      ),
    );
  }
}

class BecomeSellerContent extends StatelessWidget {
  const BecomeSellerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final profilePage = context.findAncestorStateOfType<_ProfilePageState>();
            profilePage?._navigateBack();
          },
        ),
        title: const Text(
          'Как стать продавцом',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Кто может стать продавцом?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Мы сотрудничаем с:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              '✔ Самозанятыми',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '✔ Мастерами рукоделия',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '✔ Небольшими цветочными магазинами',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '✔ Кондитерами (бенто-торты, сладости)',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '✔ Производителями подарков и праздничных атрибутов',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '2. Как зарегистрироваться?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1. Скачайте приложение и пройдите быструю регистрацию – укажите email или номер телефона',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              '2. Создайте карточку товара – загрузите фото, укажите название, описание и цену.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              '3. После проверки модерацией ваш товар появится в каталоге, а вы получите полный доступ к личному кабинету.',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 16),
            Text(
              '3. Сколько стоит размещение?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Комиссия зависит от категории товара и формата сотрудничества. Подробности уточняйте у менеджера.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '4. Как происходит доставка?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
             Text(
              '✔ Вы можете доставлять заказы самостоятельно.',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 4),
             Text(
              '✔ Или использовать нашу логистику (условия обсуждаются индивидуально).',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            // Здесь будет информация о том, как стать продавцом
          ],
        ),
      ),
    );
  }
}

class AboutAppContent extends StatelessWidget {
  const AboutAppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final profilePage = context.findAncestorStateOfType<_ProfilePageState>();
            profilePage?._navigateBack();
          },
        ),
        title: const Text(
          'О приложении',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text('Версия: 1.0.0'),
            SizedBox(height: 8),
            Text('Команда: Giftly'),
            SizedBox(height: 8),
            Text('Дата: 16.05.2025'),
          ],
        ),
      ),
    );
  }
}

class SellerAgreementContent extends StatelessWidget {
  const SellerAgreementContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final profilePage = context.findAncestorStateOfType<_ProfilePageState>();
            profilePage?._navigateBack();
          },
        ),
        title: const Text(
          'Положение для продавца',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text(
              '1. Общие положения',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1.1. Продавец — физ. или юр. лицо, предоставляющее товары (подарки, цветы) для реализации через онлайн-магазин «Название магазина» (далее — Платформа).',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              '1.2. Платформа оказывает услуги по размещению товаров, приему платежей и организации доставки.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              '1.3. Отношения регулируются данным договором, законодательством РФ (или другой страны) и правилами Платформы.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),

            Text(
              '2. Обязанности продавца',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '2.1. Качество товаров:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Товары должны соответствовать описанию, фото и заявленным характеристикам.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'Цветы — свежие, подарки — без дефектов.',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 8),
            Text(
              '2.2. Сроки поставки:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Продавец обязуется передать товар курьеру/службе доставки в течение X часов после подтверждения заказа.',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 8),
            Text(
              '2.3. Информация:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Актуальные фото, описание, цена и наличие.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'Предупреждать Платформу об изменении ассортимента или цен за 3 дня.',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 8),
            Text(
              '2.4. Соблюдение законов:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Не продавать запрещенные товары (наркотики, оружие и т.д.).',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'Иметь все необходимые сертификаты (для пищевых продуктов, детских товаров и т.п.).',
              style: TextStyle(fontSize: 14),
            ),

            SizedBox(height: 16),
            Text(
              '3. Обязанности Платформы',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '3.1. Размещение товаров:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Создание карточек товаров на сайте.',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 4),
            Text(
              'SEO-оптимизация и продвижение.',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 8),
            Text(
              '3.2. Прием платежей:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 4),
            Text(
              'Организация оплаты через сайт (карты, электронные деньги).',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 8),
            Text(
              '3.3. Доставка:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 4),
            Text(
              'Передача заказов курьерским службам или логистическим партнерам.',
              style: TextStyle(fontSize: 14),
            ),

            SizedBox(height: 16),
            Text(
              '4. Финансовые условия',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 8),
            Text(
              '4.1. Комиссия Платформы:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'X% от стоимости каждого заказа.',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 8),
            Text(
              '4.2. Выплаты:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 4),
            Text(
              'Перечисление денег продавцу в течение Y банковских дней после доставки.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'Возврат средств покупателю — за счет продавца (если товар бракованный).',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 8),
            Text(
              '4.3. НДС:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 4),
            Text(
              'Если продавец работает с НДС, он обязан указать это в документах.',
              style: TextStyle(fontSize: 14),
            ),

            SizedBox(height: 16),
            Text(
              '5. Ответственность',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
             Text(
              '5.1. Продавец несет ответственность за:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Несоответствие товара описанию.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'Нарушение сроков передачи заказа.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'Нанесение ущерба покупателю (например, аллергия из-за некачественных цветов).',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 8),
             Text(
              '5.2. Платформа не отвечает за:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Действия курьерских служб.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'Ошибки в описании, если продавец предоставил неверные данные.',
              style: TextStyle(fontSize: 14),
            ),

            SizedBox(height: 16),
             Text(
              '6. Конфиденциальность',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '6.1. Продавец соглашается на обработку персональных данных в рамках закона.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              '6.2. Запрещено передавать данные покупателей третьим лицам.',
              style: TextStyle(fontSize: 14),
            ),

            SizedBox(height: 16),
             Text(
              '7. Срок действия и расторжение',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 8),
            Text(
              '7.1. Договор вступает в силу с даты подписания и действует 1 год (с автоматической пролонгацией).',
              style: TextStyle(fontSize: 14),
            ),
             SizedBox(height: 8),
            Text(
              '7.2. Расторжение возможно:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'По соглашению сторон.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'При нарушении условий одной из сторон (уведомление за 14 дней).',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
