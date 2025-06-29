import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/stat_card.dart';
import '../widgets/common/gradient_button.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/achievement_provider.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.cardBackground,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.purpleGradient.map((c) => c.withValues(alpha: 0.3)).toList(),
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.success,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Ron Vincent Cada',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Senior Developer',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistics',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer3<TaskProvider, AchievementProvider, AuthProvider>(
                    builder: (context, taskProvider, achievementProvider, authProvider, child) {
                      final completedTasks = taskProvider.tasks.where((t) => t.isCompleted).length;
                      final totalTasks = taskProvider.tasks.length;
                      final unlockedAchievements = achievementProvider.achievements.where((a) => a.earned).length;
                      final totalAchievements = achievementProvider.achievements.length;
                      
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          StatCard(
                            title: 'Tasks Completed',
                            value: '$completedTasks/$totalTasks',
                            icon: Icons.task_alt,
                            gradient: AppColors.purpleGradient,
                          ),
                          StatCard(
                            title: 'Achievements',
                            value: '$unlockedAchievements/$totalAchievements',
                            icon: Icons.emoji_events,
                            gradient: AppColors.yellowGradient,
                          ),
                          StatCard(
                            title: 'Streak',
                            value: '7 days',
                            icon: Icons.local_fire_department,
                            gradient: AppColors.redGradient,
                          ),
                          StatCard(
                            title: 'Level',
                            value: '12',
                            icon: Icons.trending_up,
                            gradient: AppColors.tealGradient,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Account Settings',
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
                        _buildSettingItem(
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Edit Profile coming soon!')),
                            );
                          },
                        ),
                        const Divider(color: AppColors.border),
                        _buildSettingItem(
                          icon: Icons.notifications,
                          title: 'Notifications',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                            );
                          },
                        ),
                        const Divider(color: AppColors.border),
                        _buildSettingItem(
                          icon: Icons.security,
                          title: 'Privacy & Security',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Privacy settings coming soon!')),
                            );
                          },
                        ),
                        const Divider(color: AppColors.border),
                        _buildSettingItem(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Help & Support coming soon!')),
                            );
                          },
                        ),
                        const Divider(color: AppColors.border),
                        _buildSettingItem(
                          icon: Icons.settings,
                          title: 'App Settings',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          },
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Zentry Mobile',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'A gamified productivity app that transforms your daily tasks into an engaging experience.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GradientButton(
                          text: 'Sign Out',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Logout functionality coming soon!')),
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
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.success,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
