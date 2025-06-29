import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../widgets/common/glass_card.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read!')),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          final notifications = notificationProvider.notifications;
          
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'When you have notifications, they\'ll appear here',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getNotificationColor(notification.type),
                      child: Icon(
                        _getNotificationIcon(notification.type),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatNotificationTime(notification.createdAt),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondary,
                      ),
                      color: AppColors.cardBackground,
                      onSelected: (value) {
                        switch (value) {
                          case 'mark_read':
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Marked as read!')),
                            );
                            break;
                          case 'delete':
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Notification deleted!')),
                            );
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (!notification.read)
                          const PopupMenuItem(
                            value: 'mark_read',
                            child: Text(
                              'Mark as read',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (notification.actionUrl != null) {
                        _handleNotificationAction(context, notification);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'task_reminder':
        return AppColors.warning;
      case 'achievement_unlocked':
        return AppColors.success;
      case 'level_up':
        return AppColors.purpleGradient.first;
      case 'streak_milestone':
        return Colors.orange;
      case 'project_deadline':
        return AppColors.danger;
      default:
        return AppColors.success;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'task_reminder':
        return Icons.task_alt;
      case 'achievement_unlocked':
        return Icons.emoji_events;
      case 'level_up':
        return Icons.trending_up;
      case 'streak_milestone':
        return Icons.local_fire_department;
      case 'project_deadline':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _handleNotificationAction(BuildContext context, notification) {
    if (notification.actionUrl != null) {
      final url = notification.actionUrl!;
      if (url.contains('task')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening task...')),
        );
      } else if (url.contains('achievement')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viewing achievement...')),
        );
      } else if (url.contains('project')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening project...')),
        );
      }
    }
  }
}
