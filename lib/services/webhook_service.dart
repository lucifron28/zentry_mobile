import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/env_config.dart';

/// Webhook Integration Service for Zentry Events
/// 
/// Sends notifications to external services (MS Teams, Discord, etc.) 
/// when important events occur in the app.
class WebhookService {
  static const String _prefsPrefix = 'webhook_';

  // Default webhook URLs (preconfigured)
  static const String defaultDiscordUrl = 'https://discord.com/api/webhooks/1388537349004329001/K4dIFQM9rzNh3zn--SEuLrqAG9H_frhaKC5i__PUecpjfmjEdwO1zv96QKvIjBIV8d7L';
  static const String defaultTeamsUrl = 'https://mseufeduph.webhook.office.com/webhookb2/1d1a0208-f69a-47ed-9c1b-8c29c5fc9769@ddedb3cc-596d-482b-8e8c-6cc149a7a7b7/IncomingWebhook/09b5955c636a46688922a4e106304fd9/d8352f48-e96e-4321-800f-f998f9af400a/V21F7JNsmKeqN21d_HSU9mFN4tJ8jkpGlYB4mL892I1P01';

  // Webhook event types
  static const String eventTaskCompleted = 'task_completed';
  static const String eventProjectCompleted = 'project_completed';
  static const String eventProjectProgress = 'project_progress';
  static const String eventBadgeEarned = 'badge_earned';
  static const String eventLevelUp = 'level_up';
  static const String eventStreakCheckpoint = 'streak_checkpoint';
  static const String eventProjectCreated = 'project_created';
  static const String eventProjectAssignment = 'project_assignment';

  /// Get webhook URL for a specific event
  static Future<String?> getWebhookUrl(String eventType) async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('${_prefsPrefix}${eventType}_url');
    
    // Return saved URL if exists, otherwise return default Discord URL
    return savedUrl ?? defaultDiscordUrl;
  }

  /// Set webhook URL for a specific event
  static Future<void> setWebhookUrl(String eventType, String? url) async {
    final prefs = await SharedPreferences.getInstance();
    if (url != null && url.isNotEmpty) {
      await prefs.setString('${_prefsPrefix}${eventType}_url', url);
    } else {
      await prefs.remove('${_prefsPrefix}${eventType}_url');
    }
  }

  /// Check if webhook is enabled for a specific event
  static Future<bool> isWebhookEnabled(String eventType) async {
    final prefs = await SharedPreferences.getInstance();
    // Enable by default for task completion and badge earned events
    final defaultEnabled = eventType == eventTaskCompleted || eventType == eventBadgeEarned;
    return prefs.getBool('${_prefsPrefix}${eventType}_enabled') ?? defaultEnabled;
  }

  /// Enable/disable webhook for a specific event
  static Future<void> setWebhookEnabled(String eventType, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefsPrefix}${eventType}_enabled', enabled);
  }

  /// Send webhook notification for task completion
  static Future<void> sendTaskCompleted({
    required String taskTitle,
    required String priority,
    required String projectName,
    required int xpEarned,
    required int totalXp,
  }) async {
    await _sendWebhook(
      eventTaskCompleted,
      {
        'event': 'task_completed',
        'task': {
          'title': taskTitle,
          'priority': priority,
          'project': projectName,
          'xp_earned': xpEarned,
        },
        'user': {
          'total_xp': totalXp,
          'name': 'Ron Vincent Cada',
        },
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Send webhook notification for project completion
  static Future<void> sendProjectCompleted({
    required String projectName,
    required int totalTasks,
    required int xpEarned,
    required String duration,
  }) async {
    await _sendWebhook(
      eventProjectCompleted,
      {
        'event': 'project_completed',
        'project': {
          'name': projectName,
          'total_tasks': totalTasks,
          'duration': duration,
          'xp_earned': xpEarned,
        },
        'user': {
          'name': 'Ron Vincent Cada',
        },
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Send webhook notification for project progress update
  static Future<void> sendProjectProgress({
    required String projectName,
    required int completedTasks,
    required int totalTasks,
    required double progressPercentage,
  }) async {
    await _sendWebhook(
      eventProjectProgress,
      {
        'event': 'project_progress',
        'project': {
          'name': projectName,
          'completed_tasks': completedTasks,
          'total_tasks': totalTasks,
          'progress_percentage': progressPercentage,
        },
        'user': {
          'name': 'Ron Vincent Cada',
        },
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Send webhook notification for badge earned
  static Future<void> sendBadgeEarned({
    required String badgeName,
    required String badgeCategory,
    required String badgeDescription,
    required int xpReward,
  }) async {
    await _sendWebhook(
      eventBadgeEarned,
      {
        'event': 'badge_earned',
        'badge': {
          'name': badgeName,
          'category': badgeCategory,
          'description': badgeDescription,
          'xp_reward': xpReward,
        },
        'user': {
          'name': 'Ron Vincent Cada',
        },
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Send webhook notification for level up
  static Future<void> sendLevelUp({
    required int newLevel,
    required int totalXp,
    required int xpToNextLevel,
  }) async {
    await _sendWebhook(
      eventLevelUp,
      {
        'event': 'level_up',
        'level': {
          'new_level': newLevel,
          'total_xp': totalXp,
          'xp_to_next_level': xpToNextLevel,
        },
        'user': {
          'name': 'Ron Vincent Cada',
        },
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Send webhook notification for streak checkpoint
  static Future<void> sendStreakCheckpoint({
    required int streakDays,
    required String checkpointType, // '7_days', '30_days', '50_days', '100_days'
    required int bonusXp,
  }) async {
    await _sendWebhook(
      eventStreakCheckpoint,
      {
        'event': 'streak_checkpoint',
        'streak': {
          'days': streakDays,
          'checkpoint_type': checkpointType,
          'bonus_xp': bonusXp,
        },
        'user': {
          'name': 'Ron Vincent Cada',
        },
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Send webhook notification for project creation
  static Future<void> sendProjectCreated({
    required String projectName,
    required String description,
    required int estimatedTasks,
  }) async {
    await _sendWebhook(
      eventProjectCreated,
      {
        'event': 'project_created',
        'project': {
          'name': projectName,
          'description': description,
          'estimated_tasks': estimatedTasks,
        },
        'user': {
          'name': 'Ron Vincent Cada',
        },
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Send webhook notification for project assignment
  static Future<void> sendProjectAssignment({
    required String projectName,
    required String taskTitle,
    required String priority,
  }) async {
    await _sendWebhook(
      eventProjectAssignment,
      {
        'event': 'project_assignment',
        'assignment': {
          'project_name': projectName,
          'task_title': taskTitle,
          'priority': priority,
        },
        'user': {
          'name': 'Ron Vincent Cada',
        },
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Internal method to send webhook
  static Future<void> _sendWebhook(String eventType, Map<String, dynamic> payload) async {
    try {
      if (!await isWebhookEnabled(eventType)) {
        return; // Webhook not enabled for this event
      }

      final webhookUrl = await getWebhookUrl(eventType);
      if (webhookUrl == null || webhookUrl.isEmpty) {
        return; // No webhook URL configured
      }

      // Enhance payload with app info
      payload['app'] = {
        'name': EnvConfig.appName,
        'version': EnvConfig.appVersion,
      };

      // Format for different webhook types
      Map<String, dynamic> formattedPayload;
      
      if (webhookUrl.contains('discord.com')) {
        formattedPayload = _formatForDiscord(payload);
      } else if (webhookUrl.contains('office.com') || webhookUrl.contains('teams.microsoft.com')) {
        formattedPayload = _formatForTeams(payload);
      } else {
        // Generic webhook format
        formattedPayload = payload;
      }

      if (EnvConfig.debugMode) {
        print('🔗 Sending webhook for $eventType to $webhookUrl');
        print('📦 Payload: ${json.encode(formattedPayload)}');
      }

      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(formattedPayload),
      ).timeout(const Duration(seconds: 10));

      if (EnvConfig.debugMode) {
        print('✅ Webhook response: ${response.statusCode}');
      }

    } catch (e) {
      if (EnvConfig.debugMode) {
        print('❌ Webhook error for $eventType: $e');
      }
      // Don't throw - webhook failures shouldn't break the app
    }
  }

  /// Format payload for Discord webhook
  static Map<String, dynamic> _formatForDiscord(Map<String, dynamic> payload) {
    String title = '';
    String description = '';
    int color = 0x00ff00; // Green by default

    switch (payload['event']) {
      case 'task_completed':
        title = '🎯 Task Completed!';
        description = '**${payload['task']['title']}** (${payload['task']['priority']} priority)\n'
            'Project: ${payload['task']['project']}\n'
            'XP Earned: +${payload['task']['xp_earned']}';
        color = 0x00ff00; // Green
        break;
      case 'project_completed':
        title = '🏆 Project Completed!';
        description = '**${payload['project']['name']}**\n'
            'Tasks: ${payload['project']['total_tasks']}\n'
            'Duration: ${payload['project']['duration']}\n'
            'XP Earned: +${payload['project']['xp_earned']}';
        color = 0xffd700; // Gold
        break;
      case 'badge_earned':
        title = '🏅 New Badge Earned!';
        description = '**${payload['badge']['name']}**\n'
            '${payload['badge']['description']}\n'
            'XP Reward: +${payload['badge']['xp_reward']}';
        color = 0xff6b35; // Orange
        break;
      case 'level_up':
        title = '⭐ Level Up!';
        description = 'Reached **Level ${payload['level']['new_level']}**!\n'
            'Total XP: ${payload['level']['total_xp']}\n'
            'XP to next level: ${payload['level']['xp_to_next_level']}';
        color = 0x9b59b6; // Purple
        break;
      case 'streak_checkpoint':
        title = '🔥 Streak Milestone!';
        description = '**${payload['streak']['days']} Day Streak**!\n'
            'Bonus XP: +${payload['streak']['bonus_xp']}';
        color = 0xe74c3c; // Red
        break;
      default:
        title = '📱 Zentry Update';
        description = 'Event: ${payload['event']}';
    }

    return {
      'embeds': [
        {
          'title': title,
          'description': description,
          'color': color,
          'footer': {
            'text': 'Zentry Mobile - ${DateTime.now().toString().split('.')[0]}',
          },
          'author': {
            'name': payload['user']['name'],
          },
        }
      ]
    };
  }

  /// Format payload for MS Teams webhook
  static Map<String, dynamic> _formatForTeams(Map<String, dynamic> payload) {
    String title = '';
    String text = '';
    String themeColor = '00FF00'; // Green by default

    switch (payload['event']) {
      case 'task_completed':
        title = '🎯 Task Completed!';
        text = '**${payload['task']['title']}** (${payload['task']['priority']} priority)  \n'
            'Project: ${payload['task']['project']}  \n'
            'XP Earned: +${payload['task']['xp_earned']}';
        themeColor = '00FF00'; // Green
        break;
      case 'project_completed':
        title = '🏆 Project Completed!';
        text = '**${payload['project']['name']}**  \n'
            'Tasks: ${payload['project']['total_tasks']}  \n'
            'Duration: ${payload['project']['duration']}  \n'
            'XP Earned: +${payload['project']['xp_earned']}';
        themeColor = 'FFD700'; // Gold
        break;
      case 'badge_earned':
        title = '🏅 New Badge Earned!';
        text = '**${payload['badge']['name']}**  \n'
            '${payload['badge']['description']}  \n'
            'XP Reward: +${payload['badge']['xp_reward']}';
        themeColor = 'FF6B35'; // Orange
        break;
      case 'level_up':
        title = '⭐ Level Up!';
        text = 'Reached **Level ${payload['level']['new_level']}**!  \n'
            'Total XP: ${payload['level']['total_xp']}  \n'
            'XP to next level: ${payload['level']['xp_to_next_level']}';
        themeColor = '9B59B6'; // Purple
        break;
      case 'streak_checkpoint':
        title = '🔥 Streak Milestone!';
        text = '**${payload['streak']['days']} Day Streak**!  \n'
            'Bonus XP: +${payload['streak']['bonus_xp']}';
        themeColor = 'E74C3C'; // Red
        break;
      default:
        title = '📱 Zentry Update';
        text = 'Event: ${payload['event']}';
    }

    return {
      '@type': 'MessageCard',
      '@context': 'http://schema.org/extensions',
      'themeColor': themeColor,
      'summary': title,
      'sections': [
        {
          'activityTitle': title,
          'activitySubtitle': 'From ${payload['user']['name']}',
          'activityImage': 'https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Trophy/3D/trophy_3d.png',
          'text': text,
          'markdown': true,
        }
      ]
    };
  }

  /// Get all available webhook events with descriptions
  static Map<String, String> getAvailableEvents() {
    return {
      eventTaskCompleted: 'Task completed with project progress',
      eventProjectCompleted: 'Project finished successfully',
      eventProjectProgress: 'Project milestone reached',
      eventBadgeEarned: 'Achievement badge unlocked',
      eventLevelUp: 'XP level increased',
      eventStreakCheckpoint: 'Streak milestones (7, 30, 50, 100 days)',
      eventProjectCreated: 'New project created',
      eventProjectAssignment: 'Task assigned to project',
    };
  }

  /// Get webhook settings summary
  static Future<Map<String, dynamic>> getWebhookSettings() async {
    final events = getAvailableEvents();
    final settings = <String, dynamic>{};

    for (final eventType in events.keys) {
      settings[eventType] = {
        'enabled': await isWebhookEnabled(eventType),
        'url': await getWebhookUrl(eventType),
        'description': events[eventType],
      };
    }

    return settings;
  }

  /// Get default webhook URLs
  static Map<String, String> getDefaultUrls() {
    return {
      'discord': defaultDiscordUrl,
      'teams': defaultTeamsUrl,
    };
  }

  /// Initialize default webhook settings (call on app startup)
  static Future<void> initializeDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Set default URLs for all events if not already set
    final events = getAvailableEvents();
    for (final eventType in events.keys) {
      final existingUrl = prefs.getString('${_prefsPrefix}${eventType}_url');
      if (existingUrl == null) {
        await prefs.setString('${_prefsPrefix}${eventType}_url', defaultDiscordUrl);
      }
    }
  }
}
