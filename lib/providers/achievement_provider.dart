import 'package:flutter/foundation.dart';
import '../models/achievement.dart';

class AchievementProvider extends ChangeNotifier {
  List<Achievement> _achievements = [];
  List<Achievement> _filteredAchievements = [];
  AchievementFilter _currentFilter = AchievementFilter();
  AchievementStats? _stats;
  bool _isLoading = false;
  String? _error;

  List<Achievement> get achievements => _filteredAchievements;
  List<Achievement> get allAchievements => _achievements;
  AchievementFilter get currentFilter => _currentFilter;
  AchievementStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters for achievement counts
  int get totalAchievements => _achievements.length;
  int get earnedAchievements => _achievements.where((a) => a.earned).length;
  int get readyToClaim => _achievements.where((a) => a.canClaim && !a.earned).length;
  int get lockedAchievements => _achievements.where((a) => !a.earned && !a.canClaim).length;

  // Getters for category counts
  int get taskBadges => _achievements.where((a) => a.category == 'task').length;
  int get streakBadges => _achievements.where((a) => a.category == 'streak').length;
  int get levelBadges => _achievements.where((a) => a.category == 'level').length;
  int get specialBadges => _achievements.where((a) => a.category == 'special').length;

  // Getters for earned category counts
  int get earnedTaskBadges => _achievements.where((a) => a.category == 'task' && a.earned).length;
  int get earnedStreakBadges => _achievements.where((a) => a.category == 'streak' && a.earned).length;
  int get earnedLevelBadges => _achievements.where((a) => a.category == 'level' && a.earned).length;
  int get earnedSpecialBadges => _achievements.where((a) => a.category == 'special' && a.earned).length;

  // Total XP from achievements
  int get totalXpFromAchievements {
    return _achievements
        .where((a) => a.earned)
        .fold(0, (sum, a) => sum + a.experienceReward);
  }

  // Completion rate
  double get completionRate {
    if (_achievements.isEmpty) return 0.0;
    return earnedAchievements / totalAchievements;
  }

  AchievementProvider() {
    loadAchievements();
    loadStats();
  }

  Future<void> loadAchievements() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Initialize mock achievements for demo
      _achievements = _createMockAchievements();
      _applyFilter();
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load achievements: $e';
      _setLoading(false);
    }
  }

  List<Achievement> _createMockAchievements() {
    return [
      Achievement(
        id: 1,
        name: 'First Steps',
        description: 'Complete your first task',
        emoji: '🎯',
        category: 'task',
        experienceReward: 50,
        earned: true,
        earnedAt: DateTime.now().subtract(const Duration(days: 10)),
        requirementValue: 1,
        currentProgress: 1,
        canClaim: false,
        requirementType: 'tasks_completed',
      ),
      Achievement(
        id: 2,
        name: 'Task Master',
        description: 'Complete 10 tasks',
        emoji: '🎪',
        category: 'task',
        experienceReward: 100,
        earned: true,
        earnedAt: DateTime.now().subtract(const Duration(days: 5)),
        requirementValue: 10,
        currentProgress: 10,
        canClaim: false,
        requirementType: 'tasks_completed',
      ),
      Achievement(
        id: 3,
        name: 'Productivity Pro',
        description: 'Complete 50 tasks',
        emoji: '⚡',
        category: 'task',
        experienceReward: 250,
        earned: false,
        requirementValue: 50,
        currentProgress: 23,
        canClaim: false,
        requirementType: 'tasks_completed',
      ),
      Achievement(
        id: 4,
        name: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        emoji: '🔥',
        category: 'streak',
        experienceReward: 150,
        earned: true,
        earnedAt: DateTime.now().subtract(const Duration(days: 1)),
        requirementValue: 7,
        currentProgress: 7,
        canClaim: false,
        requirementType: 'streak_days',
      ),
      Achievement(
        id: 5,
        name: 'Month Champion',
        description: 'Maintain a 30-day streak',
        emoji: '🏆',
        category: 'streak',
        experienceReward: 500,
        earned: false,
        requirementValue: 30,
        currentProgress: 7,
        canClaim: false,
        requirementType: 'streak_days',
      ),
      Achievement(
        id: 6,
        name: 'Level Up!',
        description: 'Reach level 5',
        emoji: '⬆️',
        category: 'level',
        experienceReward: 200,
        earned: true,
        earnedAt: DateTime.now().subtract(const Duration(days: 20)),
        requirementValue: 5,
        currentProgress: 5,
        canClaim: false,
        requirementType: 'user_level',
      ),
      Achievement(
        id: 7,
        name: 'Double Digits',
        description: 'Reach level 10',
        emoji: '🔟',
        category: 'level',
        experienceReward: 300,
        earned: true,
        earnedAt: DateTime.now().subtract(const Duration(days: 8)),
        requirementValue: 10,
        currentProgress: 10,
        canClaim: false,
        requirementType: 'user_level',
      ),
      Achievement(
        id: 8,
        name: 'Project Pioneer',
        description: 'Create your first project',
        emoji: '📁',
        category: 'special',
        experienceReward: 75,
        earned: true,
        earnedAt: DateTime.now().subtract(const Duration(days: 30)),
        requirementValue: 1,
        currentProgress: 1,
        canClaim: false,
        requirementType: 'projects_created',
      ),
      Achievement(
        id: 9,
        name: 'Early Bird',
        description: 'Complete a task before 8 AM',
        emoji: '🌅',
        category: 'special',
        experienceReward: 100,
        earned: false,
        requirementValue: 1,
        currentProgress: 0,
        canClaim: true,
        requirementType: 'early_tasks',
      ),
      Achievement(
        id: 10,
        name: 'Night Owl',
        description: 'Complete a task after 10 PM',
        emoji: '🦉',
        category: 'special',
        experienceReward: 100,
        earned: false,
        requirementValue: 1,
        currentProgress: 0,
        canClaim: false,
        requirementType: 'late_tasks',
      ),
    ];
  }

  Future<void> loadStats() async {
    try {
      // Create mock stats based on current achievements
      _stats = AchievementStats(
        totalAchievements: totalAchievements,
        earnedAchievements: earnedAchievements,
        readyToClaim: readyToClaim,
        totalXpFromAchievements: totalXpFromAchievements,
        completionRate: completionRate,
        achievementsByCategory: {
          'task': taskBadges,
          'streak': streakBadges,
          'level': levelBadges,
          'special': specialBadges,
        },
        recentlyEarned: _achievements.where((a) => a.earned).take(3).toList(),
        almostComplete: _achievements.where((a) => !a.earned && (a.currentProgress ?? 0) > (a.requirementValue ?? 1) * 0.7).take(3).toList(),
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load achievement stats: $e');
      }
    }
  }

  Future<bool> claimAchievement(int achievementId) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Mock claim achievement - just mark as earned
      final index = _achievements.indexWhere((a) => a.id == achievementId);
      
      if (index != -1 && _achievements[index].canClaim && !_achievements[index].earned) {
        // Create updated achievement
        final achievement = _achievements[index];
        final updatedAchievement = Achievement(
          id: achievement.id,
          name: achievement.name,
          description: achievement.description,
          emoji: achievement.emoji,
          category: achievement.category,
          experienceReward: achievement.experienceReward,
          earned: true,
          earnedAt: DateTime.now(),
          requirementValue: achievement.requirementValue,
          currentProgress: achievement.currentProgress,
          canClaim: false,
          requirementType: achievement.requirementType,
          metadata: achievement.metadata,
        );
        
        _achievements[index] = updatedAchievement;
        _applyFilter();
        
        // Update stats
        await loadStats();
        
        _setLoading(false);
        return true;
      } else {
        _error = 'Achievement cannot be claimed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Failed to claim achievement: $e';
      _setLoading(false);
      return false;
    }
  }

  void applyFilter(AchievementFilter filter) {
    _currentFilter = filter;
    _applyFilter();
  }

  void clearFilter() {
    _currentFilter = AchievementFilter();
    _applyFilter();
  }

  void filterByCategory(String? category) {
    _currentFilter = _currentFilter.copyWith(category: category);
    _applyFilter();
  }

  void filterByEarned(bool? earned) {
    _currentFilter = _currentFilter.copyWith(earned: earned);
    _applyFilter();
  }

  void filterByCanClaim(bool? canClaim) {
    _currentFilter = _currentFilter.copyWith(canClaim: canClaim);
    _applyFilter();
  }

  void showAll() {
    _currentFilter = AchievementFilter();
    _applyFilter();
  }

  void showEarned() {
    _currentFilter = AchievementFilter(earned: true);
    _applyFilter();
  }

  void showAvailable() {
    _currentFilter = AchievementFilter(earned: false, canClaim: true);
    _applyFilter();
  }

  void showLocked() {
    _currentFilter = AchievementFilter(earned: false, canClaim: false);
    _applyFilter();
  }

  void _applyFilter() {
    _filteredAchievements = _achievements.where((achievement) {
      if (_currentFilter.category != null && achievement.category != _currentFilter.category) {
        return false;
      }
      
      if (_currentFilter.earned != null && achievement.earned != _currentFilter.earned) {
        return false;
      }
      
      if (_currentFilter.canClaim != null && achievement.canClaim != _currentFilter.canClaim) {
        return false;
      }
      
      return true;
    }).toList();

    // Sort achievements: earned first, then claimable, then by progress
    _filteredAchievements.sort((a, b) {
      if (a.earned && !b.earned) return -1;
      if (!a.earned && b.earned) return 1;
      
      if (a.canClaim && !b.canClaim) return -1;
      if (!a.canClaim && b.canClaim) return 1;
      
      return b.progressPercentage.compareTo(a.progressPercentage);
    });

    notifyListeners();
  }

  Achievement? getAchievementById(int achievementId) {
    try {
      return _achievements.firstWhere((achievement) => achievement.id == achievementId);
    } catch (e) {
      return null;
    }
  }

  List<Achievement> getAchievementsByCategory(String category) {
    return _achievements.where((achievement) => achievement.category == category).toList();
  }

  List<Achievement> getEarnedAchievements() {
    return _achievements.where((achievement) => achievement.earned).toList();
  }

  List<Achievement> getClaimableAchievements() {
    return _achievements.where((achievement) => achievement.canClaim && !achievement.earned).toList();
  }

  List<Achievement> getLockedAchievements() {
    return _achievements.where((achievement) => !achievement.earned && !achievement.canClaim).toList();
  }

  List<Achievement> getRecentlyEarned({int limit = 5}) {
    final recentlyEarned = _achievements
        .where((a) => a.earned && a.earnedAt != null)
        .toList();
    
    recentlyEarned.sort((a, b) => b.earnedAt!.compareTo(a.earnedAt!));
    return recentlyEarned.take(limit).toList();
  }

  List<Achievement> getAlmostComplete({int limit = 5}) {
    final almostComplete = _achievements
        .where((a) => !a.earned && a.progressPercentage >= 0.7)
        .toList();
    
    almostComplete.sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
    return almostComplete.take(limit).toList();
  }

  Map<String, int> getAchievementCountsByCategory() {
    final counts = <String, int>{};
    for (final achievement in _achievements) {
      counts[achievement.category] = (counts[achievement.category] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> getEarnedAchievementCountsByCategory() {
    final counts = <String, int>{};
    for (final achievement in _achievements.where((a) => a.earned)) {
      counts[achievement.category] = (counts[achievement.category] ?? 0) + 1;
    }
    return counts;
  }

  bool hasUnclaimedAchievements() {
    return _achievements.any((a) => a.canClaim && !a.earned);
  }

  int getUnclaimedXp() {
    return _achievements
        .where((a) => a.canClaim && !a.earned)
        .fold(0, (sum, a) => sum + a.experienceReward);
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

  // Method to update achievement progress (called from other providers)
  void updateAchievementProgress(int achievementId, int progress) {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1) {
      final achievement = _achievements[index];
      _achievements[index] = achievement.copyWith(
        currentProgress: progress,
        canClaim: achievement.requirementValue != null && 
                  progress >= achievement.requirementValue!,
      );
      _applyFilter();
    }
  }

  // Method to mark achievement as earned (called from other providers)
  void markAchievementAsEarned(int achievementId) {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1) {
      _achievements[index] = _achievements[index].copyWith(
        earned: true,
        earnedAt: DateTime.now(),
        canClaim: false,
      );
      _applyFilter();
    }
  }
}
