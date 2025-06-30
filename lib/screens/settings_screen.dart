import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../widgets/common/glass_card.dart';
import '../providers/theme_provider.dart';
import '../services/webhook_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, TextEditingController> _urlControllers = {};
  final Map<String, bool> _eventEnabledState = {};

  @override
  void initState() {
    super.initState();
    _initializeWebhookSettings();
  }

  @override
  void dispose() {
    for (var controller in _urlControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _initializeWebhookSettings() async {
    // Initialize defaults first
    await WebhookService.initializeDefaults();
    
    final events = WebhookService.getAvailableEvents();
    final defaultUrls = WebhookService.getDefaultUrls();
    
    // Initialize URL controllers with default URLs
    _urlControllers['discord'] = TextEditingController(text: defaultUrls['discord']);
    _urlControllers['teams'] = TextEditingController(text: defaultUrls['teams']);
    
    for (var eventType in events.keys) {
      final url = await WebhookService.getWebhookUrl(eventType);
      final enabled = await WebhookService.isWebhookEnabled(eventType);
      
      _urlControllers[eventType] = TextEditingController(text: url ?? '');
      _eventEnabledState[eventType] = enabled;
    }
    setState(() {});
  }

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
              'Webhook Integrations',
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
                    icon: Icons.webhook,
                    title: 'Configure Webhooks',
                    subtitle: 'Pre-configured for Discord & Teams',
                    onTap: () => _showWebhookConfigDialog(context),
                  ),
                  const Divider(color: AppColors.border),
                  _buildSettingTile(
                    icon: Icons.send,
                    title: 'Test Discord Webhook',
                    subtitle: 'Send demo notification to Discord',
                    onTap: () => _testDiscordWebhook(context),
                  ),
                  const Divider(color: AppColors.border),
                  _buildSettingTile(
                    icon: Icons.groups,
                    title: 'Test Teams Webhook',
                    subtitle: 'Send demo notification to MS Teams',
                    onTap: () => _testTeamsWebhook(context),
                  ),
                  const Divider(color: AppColors.border),
                  _buildSettingTile(
                    icon: Icons.info_outline,
                    title: 'Webhook Status',
                    subtitle: _getWebhookStatusText(),
                    onTap: () => _showWebhookStatusDialog(context),
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

  String _getWebhookStatusText() {
    int enabledCount = 0;
    for (var enabled in _eventEnabledState.values) {
      if (enabled) enabledCount++;
    }
    
    if (enabledCount == 0) {
      return 'Ready to use - configure events';
    } else {
      return '$enabledCount event${enabledCount == 1 ? '' : 's'} active';
    }
  }

  void _showWebhookConfigDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Webhook Configuration',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Configure webhook URLs and enable events',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: _buildWebhookEventList(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showWebhookStatusDialog(BuildContext context) {
    final events = WebhookService.getAvailableEvents();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Webhook Status',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final eventType = events.keys.elementAt(index);
              final enabled = _eventEnabledState[eventType] ?? false;
              final hasUrl = (_urlControllers[eventType]?.text.isNotEmpty) ?? false;
              
              return ListTile(
                leading: Icon(
                  enabled && hasUrl ? Icons.check_circle : Icons.circle_outlined,
                  color: enabled && hasUrl ? AppColors.success : AppColors.textSecondary,
                ),
                title: Text(
                  _getEventDisplayName(eventType),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                subtitle: Text(
                  enabled && hasUrl ? 'Active' : 'Not configured',
                  style: TextStyle(
                    color: enabled && hasUrl ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testDiscordWebhook(BuildContext context) async {
    try {
      // Force Discord URL and send a realistic demo notification
      const discordUrl = 'https://discord.com/api/webhooks/1388537349004329001/K4dIFQM9rzNh3zn--SEuLrqAG9H_frhaKC5i__PUecpjfmjEdwO1zv96QKvIjBIV8d7L';
      
      // Temporarily override webhook URL for demo
      await WebhookService.setWebhookUrl(WebhookService.eventTaskCompleted, discordUrl);
      await WebhookService.setWebhookEnabled(WebhookService.eventTaskCompleted, true);
      
      await WebhookService.sendTaskCompleted(
        taskTitle: 'Implement Real-time Notifications',
        projectName: 'Zentry Mobile Development',
        priority: 'High',
        xpEarned: 150,
        totalXp: 2750,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎯 Discord demo notification sent successfully!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to send Discord webhook: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _testTeamsWebhook(BuildContext context) async {
    try {
      // Force Teams URL and send a realistic demo notification
      const teamsUrl = 'https://mseufeduph.webhook.office.com/webhookb2/1d1a0208-f69a-47ed-9c1b-8c29c5fc9769@ddedb3cc-596d-482b-8e8c-6cc149a7a7b7/IncomingWebhook/09b5955c636a46688922a4e106304fd9/d8352f48-e96e-4321-800f-f998f9af400a/V21F7JNsmKeqN21d_HSU9mFN4tJ8jkpGlYB4mL892I1P01';
      
      // Temporarily override webhook URL for demo
      await WebhookService.setWebhookUrl(WebhookService.eventBadgeEarned, teamsUrl);
      await WebhookService.setWebhookEnabled(WebhookService.eventBadgeEarned, true);
      
      await WebhookService.sendBadgeEarned(
        badgeName: 'Productivity Champion',
        badgeCategory: 'Achievement',
        badgeDescription: 'Completed 50+ tasks in the Zentry Mobile app with excellent consistency and quality! Keep up the amazing work!',
        xpReward: 200,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🏅 Teams demo notification sent successfully!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to send Teams webhook: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  List<Widget> _buildWebhookEventList() {
    final events = WebhookService.getAvailableEvents();
    final List<Widget> widgets = [];
    
    // Add URL configuration section first
    widgets.add(
      Card(
        color: AppColors.cardBackground.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Webhook URLs (Preconfigured)',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Default URLs are already configured. Edit if needed.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        const discordUrl = 'https://discord.com/api/webhooks/1388537349004329001/K4dIFQM9rzNh3zn--SEuLrqAG9H_frhaKC5i__PUecpjfmjEdwO1zv96QKvIjBIV8d7L';
                        _urlControllers['discord']?.text = discordUrl;
                        for (var eventType in events.keys) {
                          WebhookService.setWebhookUrl(eventType, discordUrl);
                          _urlControllers[eventType]?.text = discordUrl;
                        }
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Discord URL applied to all events')),
                        );
                      },
                      icon: const Icon(Icons.discord, size: 16),
                      label: const Text('Apply Discord'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5865F2).withValues(alpha: 0.8),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        const teamsUrl = 'https://mseufeduph.webhook.office.com/webhookb2/1d1a0208-f69a-47ed-9c1b-8c29c5fc9769@ddedb3cc-596d-482b-8e8c-6cc149a7a7b7/IncomingWebhook/09b5955c636a46688922a4e106304fd9/d8352f48-e96e-4321-800f-f998f9af400a/V21F7JNsmKeqN21d_HSU9mFN4tJ8jkpGlYB4mL892I1P01';
                        _urlControllers['teams']?.text = teamsUrl;
                        for (var eventType in events.keys) {
                          WebhookService.setWebhookUrl(eventType, teamsUrl);
                          _urlControllers[eventType]?.text = teamsUrl;
                        }
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Teams URL applied to all events')),
                        );
                      },
                      icon: const Icon(Icons.groups, size: 16),
                      label: const Text('Apply Teams'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6264A7).withValues(alpha: 0.8),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _urlControllers['discord'] ?? TextEditingController(),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Discord Webhook URL (Editable)',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  helperText: 'Pre-configured Discord webhook - edit if needed',
                  helperStyle: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Update all event URLs with Discord URL
                  for (var eventType in events.keys) {
                    if (value.contains('discord.com')) {
                      WebhookService.setWebhookUrl(eventType, value);
                      _urlControllers[eventType]?.text = value;
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _urlControllers['teams'] ?? TextEditingController(),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'MS Teams Webhook URL (Editable)',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  helperText: 'Pre-configured Teams webhook - edit if needed',
                  helperStyle: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Update all event URLs with Teams URL
                  for (var eventType in events.keys) {
                    if (value.contains('office.com') || value.contains('teams.microsoft.com')) {
                      WebhookService.setWebhookUrl(eventType, value);
                      _urlControllers[eventType]?.text = value;
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
    
    widgets.add(const SizedBox(height: 16));
    widgets.add(
      const Text(
        'Event Types',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    widgets.add(const SizedBox(height: 8));
    
    // Add event toggles
    for (var entry in events.entries) {
      final eventType = entry.key;
      final description = entry.value;
      final enabled = _eventEnabledState[eventType] ?? false;
      
      widgets.add(
        SwitchListTile(
          title: Text(
            _getEventDisplayName(eventType),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          subtitle: Text(
            description,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          value: enabled,
          onChanged: (value) async {
            await WebhookService.setWebhookEnabled(eventType, value);
            setState(() {
              _eventEnabledState[eventType] = value;
            });
          },
          activeColor: AppColors.success,
        ),
      );
      
      if (entry.key != events.keys.last) {
        widgets.add(const Divider(color: AppColors.border));
      }
    }
    
    return widgets;
  }

  String _getEventDisplayName(String eventType) {
    switch (eventType) {
      case WebhookService.eventTaskCompleted:
        return 'Task Completed';
      case WebhookService.eventProjectCompleted:
        return 'Project Completed';
      case WebhookService.eventProjectProgress:
        return 'Project Progress';
      case WebhookService.eventBadgeEarned:
        return 'Badge Earned';
      case WebhookService.eventLevelUp:
        return 'Level Up';
      case WebhookService.eventStreakCheckpoint:
        return 'Streak Checkpoint';
      case WebhookService.eventProjectCreated:
        return 'Project Created';
      case WebhookService.eventProjectAssignment:
        return 'Project Assignment';
      default:
        return eventType.replaceAll('_', ' ').split(' ').map((word) => 
          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word
        ).join(' ');
    }
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
