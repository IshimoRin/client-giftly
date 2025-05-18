import 'package:flutter/material.dart';
import '../../../domain/models/user.dart';
import '../../../domain/models/user_role.dart';
import '../../widgets/login_prompt.dart';
import 'package:giftly/presentation/pages/about_app_page.dart';
import 'package:giftly/presentation/pages/settings_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;
  Widget? _currentContent;

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

  @override
  Widget build(BuildContext context) {
    if (widget.user.role == UserRole.guest) {
      return const Scaffold(
        body: LoginPrompt(
          message: 'Войдите или зарегистрируйтесь, чтобы получить доступ к профилю',
        ),
      );
    }

    return Scaffold(
      appBar: _currentContent == null
          ? AppBar(
              title: const Text(
                'Профиль',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // TODO: Implement edit profile
                  },
                ),
              ],
            )
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _navigateBack,
              ),
              title: Text(
                _getTitle(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      body: _currentContent ?? _buildMainContent(context),
    );
  }

  String _getTitle() {
    if (_currentContent is SettingsContent) return 'Настройки';
    if (_currentContent is OrderHistoryContent) return 'История заказов';
    if (_currentContent is PersonalDataContent) return 'Мои данные';
    if (_currentContent is LegalDocsContent) return 'Правовые документы';
    if (_currentContent is ReturnPolicyContent) return 'О возврате товара';
    if (_currentContent is SupportContent) return 'Поддержка';
    if (_currentContent is BecomeSellerContent) return 'Как стать продавцом';
    if (_currentContent is AboutAppContent) return 'О приложении';
    return 'Профиль';
  }

  Widget _buildMainContent(BuildContext context) {
    return ListView(
      children: [
        if (widget.user.role != UserRole.guest) ...[
          // Аватар и имя пользователя
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: widget.user.photoUrl != null
                      ? NetworkImage(widget.user.photoUrl!)
                      : null,
                  child: widget.user.photoUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.user.name ?? 'Пользователь',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.user.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.user.email!,
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

        // Кнопка выхода
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Выйти'),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Column(
      children: [
        _buildProfileOption(
          context: context,
          title: 'Настройки',
          icon: Icons.settings,
          onTap: () {
            _navigateTo(const SettingsContent());
          },
        ),
        if (widget.user.role != UserRole.guest)
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
          title: 'Мои данные',
          icon: Icons.person,
          onTap: () {
            _navigateTo(const PersonalDataContent());
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

class PersonalDataContent extends StatelessWidget {
  const PersonalDataContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          // Здесь будут личные данные
        ],
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
