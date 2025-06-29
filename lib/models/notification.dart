class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic>? data;
  final String? actionUrl;
  final String? imageUrl;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.read = false,
    required this.createdAt,
    this.data,
    this.actionUrl,
    this.imageUrl,
  });

  bool get isTaskReminder => type.toLowerCase() == 'task_reminder';
  bool get isAchievementUnlocked => type.toLowerCase() == 'achievement_unlocked';
  bool get isLevelUp => type.toLowerCase() == 'level_up';
  bool get isStreakMilestone => type.toLowerCase() == 'streak_milestone';

  String get typeLabel {
    switch (type.toLowerCase()) {
      case 'task_reminder':
        return 'Task Reminder';
      case 'achievement_unlocked':
        return 'Achievement Unlocked';
      case 'level_up':
        return 'Level Up';
      case 'streak_milestone':
        return 'Streak Milestone';
      case 'project_update':
        return 'Project Update';
      case 'team_invitation':
        return 'Team Invitation';
      default:
        return 'Notification';
    }
  }

  String get iconEmoji {
    switch (type.toLowerCase()) {
      case 'task_reminder':
        return '📋';
      case 'achievement_unlocked':
        return '🏆';
      case 'level_up':
        return '⚡';
      case 'streak_milestone':
        return '🔥';
      case 'project_update':
        return '📊';
      case 'team_invitation':
        return '👥';
      default:
        return '🔔';
    }
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      read: json['read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      data: json['data'] as Map<String, dynamic>?,
      actionUrl: json['action_url'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'read': read,
      'created_at': createdAt.toIso8601String(),
      'data': data,
      'action_url': actionUrl,
      'image_url': imageUrl,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? read,
    DateTime? createdAt,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? imageUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AppNotification(id: $id, title: $title, type: $type, read: $read)';
  }
}

// Notification preferences
class NotificationPreferences {
  final bool taskReminders;
  final bool achievementUnlocked;
  final bool levelUp;
  final bool streakMilestones;
  final bool projectUpdates;
  final bool teamInvitations;
  final bool emailNotifications;
  final bool pushNotifications;
  final String reminderTime; // Format: "HH:mm"
  final List<String> reminderDays; // ["monday", "tuesday", etc.]

  NotificationPreferences({
    this.taskReminders = true,
    this.achievementUnlocked = true,
    this.levelUp = true,
    this.streakMilestones = true,
    this.projectUpdates = true,
    this.teamInvitations = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.reminderTime = "09:00",
    this.reminderDays = const [
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday"
    ],
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      taskReminders: json['task_reminders'] ?? true,
      achievementUnlocked: json['achievement_unlocked'] ?? true,
      levelUp: json['level_up'] ?? true,
      streakMilestones: json['streak_milestones'] ?? true,
      projectUpdates: json['project_updates'] ?? true,
      teamInvitations: json['team_invitations'] ?? true,
      emailNotifications: json['email_notifications'] ?? true,
      pushNotifications: json['push_notifications'] ?? true,
      reminderTime: json['reminder_time'] ?? "09:00",
      reminderDays: List<String>.from(json['reminder_days'] ?? [
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday"
      ]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_reminders': taskReminders,
      'achievement_unlocked': achievementUnlocked,
      'level_up': levelUp,
      'streak_milestones': streakMilestones,
      'project_updates': projectUpdates,
      'team_invitations': teamInvitations,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'reminder_time': reminderTime,
      'reminder_days': reminderDays,
    };
  }

  NotificationPreferences copyWith({
    bool? taskReminders,
    bool? achievementUnlocked,
    bool? levelUp,
    bool? streakMilestones,
    bool? projectUpdates,
    bool? teamInvitations,
    bool? emailNotifications,
    bool? pushNotifications,
    String? reminderTime,
    List<String>? reminderDays,
  }) {
    return NotificationPreferences(
      taskReminders: taskReminders ?? this.taskReminders,
      achievementUnlocked: achievementUnlocked ?? this.achievementUnlocked,
      levelUp: levelUp ?? this.levelUp,
      streakMilestones: streakMilestones ?? this.streakMilestones,
      projectUpdates: projectUpdates ?? this.projectUpdates,
      teamInvitations: teamInvitations ?? this.teamInvitations,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDays: reminderDays ?? this.reminderDays,
    );
  }
}
