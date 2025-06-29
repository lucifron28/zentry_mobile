import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../widgets/common/glass_card.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appearance',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return SwitchListTile(
                        title: const Text(
                          'Dark Mode',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        subtitle: const Text(
                          'Use dark theme',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) => themeProvider.toggleTheme(),
                        activeColor: AppColors.success,
                      );
                    },
                  ),
                  const Divider(color: AppColors.border),
                  _buildSettingTile(
                    icon: Icons.color_lens,
                    title: 'Theme Colors',
                    subtitle: 'Customize app colors',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Theme customization coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Notifications',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Push Notifications',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: const Text(
                      'Receive notifications',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    value: true,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification settings updated!')),
                      );
                    },
                    activeColor: AppColors.success,
                  ),
                  const Divider(color: AppColors.border),
                  SwitchListTile(
                    title: const Text(
                      'Task Reminders',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: const Text(
                      'Get reminded about tasks',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    value: true,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task reminder settings updated!')),
                      );
                    },
                    activeColor: AppColors.success,
                  ),
                  const Divider(color: AppColors.border),
                  SwitchListTile(
                    title: const Text(
                      'Achievement Alerts',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: const Text(
                      'Get notified when you unlock achievements',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    value: false,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Achievement alert settings updated!')),
                      );
                    },
                    activeColor: AppColors.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Productivity',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.timer,
                    title: 'Default Task Duration',
                    subtitle: '30 minutes',
                    onTap: () {
                      _showDurationDialog(context);
                    },
                  ),
                  const Divider(color: AppColors.border),
                  _buildSettingTile(
                    icon: Icons.today,
                    title: 'Week Start Day',
                    subtitle: 'Monday',
                    onTap: () {
                      _showWeekStartDialog(context);
                    },
                  ),
                  const Divider(color: AppColors.border),
                  SwitchListTile(
                    title: const Text(
                      'Auto-Archive Completed Tasks',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: const Text(
                      'Automatically move completed tasks to archive',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    value: true,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Auto-archive setting updated!')),
                      );
                    },
                    activeColor: AppColors.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Data & Privacy',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.backup,
                    title: 'Backup Data',
                    subtitle: 'Export your data',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data backup coming soon!')),
                      );
                    },
                  ),
                  const Divider(color: AppColors.border),
                  _buildSettingTile(
                    icon: Icons.restore,
                    title: 'Restore Data',
                    subtitle: 'Import your data',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data restore coming soon!')),
                      );
                    },
                  ),
                  const Divider(color: AppColors.border),
                  _buildSettingTile(
                    icon: Icons.delete_forever,
                    title: 'Clear All Data',
                    subtitle: 'Reset app to default state',
                    onTap: () {
                      _showClearDataDialog(context);
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'About',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.info_outline,
                    title: 'App Version',
                    subtitle: '1.0.0',
                    onTap: () {},
                  ),
                  const Divider(color: AppColors.border),
                  _buildSettingTile(
                    icon: Icons.article,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Privacy policy coming soon!')),
                      );
                    },
                  ),
                  const Divider(color: AppColors.border),
                  _buildSettingTile(
                    icon: Icons.description,
                    title: 'Terms of Service',
                    subtitle: 'Read our terms',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Terms of service coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.danger : AppColors.success,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.danger : AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  void _showDurationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Default Task Duration',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDurationOption(context, '15 minutes'),
            _buildDurationOption(context, '30 minutes'),
            _buildDurationOption(context, '1 hour'),
            _buildDurationOption(context, '2 hours'),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationOption(BuildContext context, String duration) {
    return ListTile(
      title: Text(
        duration,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Default duration set to $duration')),
        );
      },
    );
  }

  void _showWeekStartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Week Start Day',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildWeekStartOption(context, 'Monday'),
            _buildWeekStartOption(context, 'Sunday'),
            _buildWeekStartOption(context, 'Saturday'),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekStartOption(BuildContext context, String day) {
    return ListTile(
      title: Text(
        day,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Week starts on $day')),
        );
      },
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Clear All Data',
          style: TextStyle(color: AppColors.danger),
        ),
        content: const Text(
          'This will permanently delete all your tasks, projects, and achievements. This action cannot be undone.',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data clearing cancelled (demo)')),
              );
            },
            child: const Text(
              'Clear Data',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
