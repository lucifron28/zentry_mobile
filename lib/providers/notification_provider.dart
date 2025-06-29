import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<AppNotification> _notifications = [];
  NotificationPreferences _preferences = NotificationPreferences();
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  NotificationPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters for notification counts
  int get totalNotifications => _notifications.length;
  int get unreadNotifications => _notifications.where((n) => !n.read).length;
  int get readNotifications => _notifications.where((n) => n.read).length;
  
  // Getters for notification types
  List<AppNotification> get taskReminders => _notifications.where((n) => n.isTaskReminder).toList();
  List<AppNotification> get achievementNotifications => _notifications.where((n) => n.isAchievementUnlocked).toList();
  List<AppNotification> get levelUpNotifications => _notifications.where((n) => n.isLevelUp).toList();
  List<AppNotification> get streakNotifications => _notifications.where((n) => n.isStreakMilestone).toList();

  bool get hasUnreadNotifications => unreadNotifications > 0;

  Future<void> init() async {
    await loadNotifications();
    await _loadPreferences();
  }

  NotificationProvider() {
    // loadNotifications();
    // _loadPreferences();
  }

  Future<void> loadNotifications() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getNotifications();
      
      if (response['success'] == true) {
        _notifications = (response['notifications'] as List)
            .map((notificationData) => AppNotification.fromJson(notificationData))
            .toList();
        
        // Sort by creation date (newest first)
        _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        _setLoading(false);
      } else {
        _error = response['message'] ?? 'Failed to load notifications';
        _setLoading(false);
      }
    } catch (e) {
      _error = 'Failed to load notifications: $e';
      _setLoading(false);
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.markNotificationAsRead(notificationId);
      
      if (response['success'] == true) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(read: true);
          notifyListeners();
        }
        return true;
      } else {
        _error = response['message'] ?? 'Failed to mark notification as read';
        return false;
      }
    } catch (e) {
      _error = 'Failed to mark notification as read: $e';
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.markAllNotificationsAsRead();
      
      if (response['success'] == true) {
        for (int i = 0; i < _notifications.length; i++) {
          _notifications[i] = _notifications[i].copyWith(read: true);
        }
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to mark all notifications as read';
        return false;
      }
    } catch (e) {
      _error = 'Failed to mark all notifications as read: $e';
      return false;
    }
  }

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  AppNotification? getNotificationById(String notificationId) {
    try {
      return _notifications.firstWhere((n) => n.id == notificationId);
    } catch (e) {
      return null;
    }
  }

  List<AppNotification> getUnreadNotifications() {
    return _notifications.where((n) => !n.read).toList();
  }

  List<AppNotification> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  List<AppNotification> getRecentNotifications({int limit = 10}) {
    return _notifications.take(limit).toList();
  }

  // Notification preferences management
  Future<void> _loadPreferences() async {
    // In a real app, this would load from SharedPreferences or API
    // For now, using default preferences
    _preferences = NotificationPreferences();
    notifyListeners();
  }

  Future<void> updatePreferences(NotificationPreferences newPreferences) async {
    _preferences = newPreferences;
    // In a real app, this would save to SharedPreferences or API
    notifyListeners();
  }

  Future<void> toggleTaskReminders(bool enabled) async {
    _preferences = _preferences.copyWith(taskReminders: enabled);
    notifyListeners();
  }

  Future<void> toggleAchievementNotifications(bool enabled) async {
    _preferences = _preferences.copyWith(achievementUnlocked: enabled);
    notifyListeners();
  }

  Future<void> toggleLevelUpNotifications(bool enabled) async {
    _preferences = _preferences.copyWith(levelUp: enabled);
    notifyListeners();
  }

  Future<void> toggleStreakNotifications(bool enabled) async {
    _preferences = _preferences.copyWith(streakMilestones: enabled);
    notifyListeners();
  }

  Future<void> toggleProjectNotifications(bool enabled) async {
    _preferences = _preferences.copyWith(projectUpdates: enabled);
    notifyListeners();
  }

  Future<void> toggleTeamNotifications(bool enabled) async {
    _preferences = _preferences.copyWith(teamInvitations: enabled);
    notifyListeners();
  }

  Future<void> toggleEmailNotifications(bool enabled) async {
    _preferences = _preferences.copyWith(emailNotifications: enabled);
    notifyListeners();
  }

  Future<void> togglePushNotifications(bool enabled) async {
    _preferences = _preferences.copyWith(pushNotifications: enabled);
    notifyListeners();
  }

  Future<void> setReminderTime(String time) async {
    _preferences = _preferences.copyWith(reminderTime: time);
    notifyListeners();
  }

  Future<void> setReminderDays(List<String> days) async {
    _preferences = _preferences.copyWith(reminderDays: days);
    notifyListeners();
  }

  // Helper methods for creating notifications
  void createTaskReminderNotification(String taskTitle, String taskId) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Task Reminder',
      message: 'Don\'t forget: $taskTitle',
      type: 'task_reminder',
      createdAt: DateTime.now(),
      data: {'task_id': taskId},
    );
    
    if (_preferences.taskReminders) {
      addNotification(notification);
    }
  }

  void createAchievementNotification(String achievementName, int xpGained) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Achievement Unlocked! 🏆',
      message: 'You earned "$achievementName" (+$xpGained XP)',
      type: 'achievement_unlocked',
      createdAt: DateTime.now(),
      data: {'xp_gained': xpGained},
    );
    
    if (_preferences.achievementUnlocked) {
      addNotification(notification);
    }
  }

  void createLevelUpNotification(int newLevel, int xpGained) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Level Up! ⚡',
      message: 'Congratulations! You reached level $newLevel (+$xpGained XP)',
      type: 'level_up',
      createdAt: DateTime.now(),
      data: {'new_level': newLevel, 'xp_gained': xpGained},
    );
    
    if (_preferences.levelUp) {
      addNotification(notification);
    }
  }

  void createStreakNotification(int streakDays) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Streak Milestone! 🔥',
      message: 'Amazing! You\'ve maintained a $streakDays-day streak!',
      type: 'streak_milestone',
      createdAt: DateTime.now(),
      data: {'streak_days': streakDays},
    );
    
    if (_preferences.streakMilestones) {
      addNotification(notification);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
