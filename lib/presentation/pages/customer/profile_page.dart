import 'package:flutter/material.dart';
import '../../../domain/models/user.dart';
import '../../../domain/models/user_role.dart';
import '../../widgets/login_prompt.dart';
import 'package:giftly/presentation/pages/about_app_page.dart';
import 'package:giftly/presentation/pages/settings_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/services/auth_service.dart';

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

    if (_currentContent != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateBack,
          ),
          title: Text(
            _currentContent is PersonalDataContent ? 'Личные данные' : 'Профиль',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: _currentContent,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: _buildMainContent(context),
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
    return ListView(
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
    );
  }
}

class OrderHistoryContent extends StatelessWidget {
  const OrderHistoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          // Здесь будет история заказов
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
      final updatedUser = await AuthService().updateProfile(
        userId: widget.user.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text,
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
    return SingleChildScrollView(
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
                backgroundColor: const Color(0xFF91BDE9),
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
    );
  }
}

class LegalDocsContent extends StatelessWidget {
  const LegalDocsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          // Здесь будут правовые документы
        ],
      ),
    );
  }
}

class ReturnPolicyContent extends StatelessWidget {
  const ReturnPolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          // Здесь будет информация о возврате
        ],
      ),
    );
  }
}

class SupportContent extends StatelessWidget {
  const SupportContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          // Здесь будет поддержка
        ],
      ),
    );
  }
}

class BecomeSellerContent extends StatelessWidget {
  const BecomeSellerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          // Здесь будет информация о том, как стать продавцом
        ],
      ),
    );
  }
}

class AboutAppContent extends StatelessWidget {
  const AboutAppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
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
    );
  }
}
