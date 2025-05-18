// lib/pages/favorites_page.dart
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Настройки'),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection(
            'Аккаунт',
            [
              _buildSettingTile(
                'Изменить пароль',
                Icons.lock_outline,
                onTap: () {},
              ),
              _buildSettingTile(
                'Уведомления',
                Icons.notifications_outlined,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            'Приложение',
            [
              _buildSettingTile(
                'Язык',
                Icons.language,
                value: 'Русский',
                onTap: () {},
              ),
              _buildSettingTile(
                'Тёмная тема',
                Icons.dark_mode_outlined,
                isSwitch: true,
                onChanged: (value) {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingTile(
    String title,
    IconData icon, {
    String? value,
    bool isSwitch = false,
    VoidCallback? onTap,
    ValueChanged<bool>? onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: isSwitch
          ? Switch(
              value: false,
              onChanged: onChanged,
            )
          : value != null
              ? Text(
                  value,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                )
              : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: isSwitch ? null : onTap,
    );
  }
}
