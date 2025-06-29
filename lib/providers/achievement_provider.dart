import 'package:flutter/foundation.dart';
import '../models/achievement.dart';
import '../services/api_service.dart';

class AchievementProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
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
      final response = await _apiService.getAchievements();
      
      if (response['success'] == true) {
        _achievements = (response['achievements'] as List)
            .map((achievementData) => Achievement.fromJson(achievementData))
            .toList();
        
        _applyFilter();
        _setLoading(false);
      } else {
        _error = response['message'] ?? 'Failed to load achievements';
        _setLoading(false);
      }
    } catch (e) {
      _error = 'Failed to load achievements: $e';
      _setLoading(false);
    }
  }

  Future<void> loadStats() async {
    try {
      final response = await _apiService.getAchievementStats();
      
      if (response['success'] == true) {
        _stats = AchievementStats.fromJson(response['stats']);
        notifyListeners();
      }
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
      final response = await _apiService.claimAchievement(achievementId);
      
      if (response['success'] == true) {
        final updatedAchievement = Achievement.fromJson(response['achievement']);
        final index = _achievements.indexWhere((a) => a.id == achievementId);
        
        if (index != -1) {
          _achievements[index] = updatedAchievement;
          _applyFilter();
        }
        
        // Update stats
        await loadStats();
        
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to claim achievement';
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
