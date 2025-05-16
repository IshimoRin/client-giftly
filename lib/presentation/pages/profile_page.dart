import 'package:flutter/material.dart';
import 'package:giftly/presentation/pages/about_app_page.dart';
import 'package:giftly/presentation/pages/settings_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: _buildProfileContent(context),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileHeader(),
        const SizedBox(height: 24),
        _buildProfileOptions(context),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Профиль',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, color: Colors.grey[800]),
        ),
      ],
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Column(
      children: [
        _buildProfileOption(
          title: 'Настройки',
          icon: Icons.settings,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsPage()),
            );
          },
        ),
        _buildProfileOption(
          title: 'История заказов',
          icon: Icons.history,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsPage()),
            );
          },
        ),
        _buildProfileOption(
          title: 'Мои данные',
          icon: Icons.person,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsPage()),
            );
          },
        ),
        _buildProfileOption(
          title: 'Правовые документы',
          icon: Icons.description,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsPage()),
            );
          },
        ),
        _buildProfileOption(
          title: 'О возврате товара',
          icon: Icons.help,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsPage()),
            );
          },
        ),
        _buildProfileOption(
          title: 'Поддержка Gifty',
          icon: Icons.support_agent,
          tag: 'Всегда на связи',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsPage()),
            );
          },
        ),
        _buildProfileOption(
          title: 'GitHub репозиторий',
          icon: Icons.code,
          onTap: () async {
            final url =
                'https://github.com/Dodger0072/Programming-technologies-project';
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
            }
          },
        ),
        _buildProfileOption(
          title: 'Как стать продавцом',
          icon: Icons.business,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsPage()),
            );
          },
        ),
        _buildProfileOption(
          title: 'О приложении',
          icon: Icons.info,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AboutAppPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required String title,
    required icon,
    String? tag,
    VoidCallback? onTap,
    String? url,
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
                color: Colors.blue,
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

      onTap: () async {
        if (onTap != null) {
          onTap(); // вызываем кастомный onTap, если есть
        } else if (url != null && await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(
            Uri.parse(url),
            mode:
                LaunchMode.externalApplication, // Открытие во внешнем браузере
          );
        } else {
          // Можно добавить обработку ошибок или fallback
        }
      },
    );
  }
}
