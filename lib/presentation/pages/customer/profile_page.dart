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
        title: const Text(
          'Профиль',
          style: TextStyle(
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
          onTap: () {
            _navigateTo(const SettingsContent());
          },
        ),
        if (_currentUser.role != UserRole.guest)
          _buildProfileOption(
            context: context,
            title: 'История заказов',
            icon: Icons.history,
            onTap: () {
              _navigateTo(const OrderHistoryContent());
            },
          ),
        _buildProfileOption(
          context: context,
          title: 'Правовые документы',
          icon: Icons.description,
          onTap: () {
            _navigateTo(const LegalDocsContent());
          },
        ),
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
            _navigateTo(const SupportContent());
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
          title: 'Как стать продавцом',
          icon: Icons.business,
          onTap: () {
            _navigateTo(const BecomeSellerContent());
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
      body: ListView(
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
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                  },
                ),
                ListTile(
                  title: const Text('Размер текста'),
                  subtitle: Slider(
                    value: _fontSize,
                    min: 12,
                    max: 24,
                    divisions: 4,
                    label: '${_fontSize.round()}',
                    onChanged: (value) {
                      setState(() {
                        _fontSize = value;
                      });
                    },
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
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
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
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('English'),
                  value: 'English',
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Кнопка сохранения
          ElevatedButton(
            onPressed: () {
              // TODO: Сохранить настройки
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Настройки сохранены'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9191E9),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Сохранить настройки'),
          ),
        ],
      ),
    );
  }
}

class OrderHistoryContent extends StatefulWidget {
  const OrderHistoryContent({super.key});

  @override
  State<OrderHistoryContent> createState() => _OrderHistoryContentState();
}

class _OrderHistoryContentState extends State<OrderHistoryContent> {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _searchController.addListener(_filterOrders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await _orderService.getUserOrders();
      setState(() {
        _orders = orders;
        _filteredOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterOrders() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredOrders = List.from(_orders);
      } else {
        _filteredOrders = _orders.where((order) {
          final orderNumberMatch = order.id?.toLowerCase().contains(query) ?? false;
          final productNameMatch = order.items.any((item) => item.name.toLowerCase().contains(query));
          return orderNumberMatch || productNameMatch;
        }).toList();
      }
    });
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
            child: Row(
              children: [
                Icon(Icons.filter_list, color: Colors.grey[700]),
                SizedBox(width: 8.0),
                Text('Все заказы', style: TextStyle(fontSize: 16.0, color: Colors.grey[700])),
                Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
              ],
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.person, size: 16.0, color: Colors.grey[600]),
                                              SizedBox(width: 4.0),
                                              Text(
                                                'Данила',
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
                                                fontWeight: FontWeight.bold,
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
                                      Center(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            // TODO: Implement rating action for this order
                                          },
                                           style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: Color(0xFF9191E9)),
                                             shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                          ),
                                          child: Text('Оцените нас', style: TextStyle(color: Color(0xFF9191E9), fontSize: 16)),
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
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            // Здесь будут правовые документы
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
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            // Здесь будет информация о возврате
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
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
