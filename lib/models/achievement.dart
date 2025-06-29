class Achievement {
  final int id;
  final String name;
  final String description;
  final String emoji;
  final String category;
  final int experienceReward;
  final bool earned;
  final DateTime? earnedAt;
  final int? requirementValue;
  final int? currentProgress;
  final bool canClaim;
  final String? requirementType;
  final Map<String, dynamic>? metadata;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    required this.experienceReward,
    this.earned = false,
    this.earnedAt,
    this.requirementValue,
    this.currentProgress,
    this.canClaim = false,
    this.requirementType,
    this.metadata,
  });

  double get progressPercentage {
    if (earned) return 1.0;
    if (requirementValue == null || currentProgress == null) return 0.0;
    return (currentProgress! / requirementValue!).clamp(0.0, 1.0);
  }

  bool get isLocked {
    return !earned && !canClaim && (currentProgress ?? 0) == 0;
  }

  String get statusText {
    if (earned) return 'Earned';
    if (canClaim) return 'Ready to Claim';
    return 'Locked';
  }

  String get categoryLabel {
    switch (category.toLowerCase()) {
      case 'task':
        return 'Task Badge';
      case 'streak':
        return 'Streak Badge';
      case 'level':
        return 'Level Badge';
      case 'special':
        return 'Special Badge';
      default:
        return 'Badge';
    }
  }

  String get progressText {
    if (earned) return 'Completed';
    if (requirementValue == null || currentProgress == null) return '';
    return '$currentProgress / $requirementValue';
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '🏆',
      category: json['category'] ?? 'general',
      experienceReward: json['experience_reward'] ?? 0,
      earned: json['earned'] ?? false,
      earnedAt: json['earned_at'] != null
          ? DateTime.parse(json['earned_at'])
          : null,
      requirementValue: json['requirement_value'],
      currentProgress: json['current_progress'],
      canClaim: json['can_claim'] ?? false,
      requirementType: json['requirement_type'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'category': category,
      'experience_reward': experienceReward,
      'earned': earned,
      'earned_at': earnedAt?.toIso8601String(),
      'requirement_value': requirementValue,
      'current_progress': currentProgress,
      'can_claim': canClaim,
      'requirement_type': requirementType,
      'metadata': metadata,
    };
  }

  Achievement copyWith({
    int? id,
    String? name,
    String? description,
    String? emoji,
    String? category,
    int? experienceReward,
    bool? earned,
    DateTime? earnedAt,
    int? requirementValue,
    int? currentProgress,
    bool? canClaim,
    String? requirementType,
    Map<String, dynamic>? metadata,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      experienceReward: experienceReward ?? this.experienceReward,
      earned: earned ?? this.earned,
      earnedAt: earnedAt ?? this.earnedAt,
      requirementValue: requirementValue ?? this.requirementValue,
      currentProgress: currentProgress ?? this.currentProgress,
      canClaim: canClaim ?? this.canClaim,
      requirementType: requirementType ?? this.requirementType,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Achievement(id: $id, name: $name, category: $category, earned: $earned)';
  }
}

// Achievement statistics
class AchievementStats {
  final int totalAchievements;
  final int earnedAchievements;
  final int readyToClaim;
  final int totalXpFromAchievements;
  final double completionRate;
  final Map<String, int> achievementsByCategory;
  final List<Achievement> recentlyEarned;
  final List<Achievement> almostComplete;

  AchievementStats({
    required this.totalAchievements,
    required this.earnedAchievements,
    required this.readyToClaim,
    required this.totalXpFromAchievements,
    required this.completionRate,
    required this.achievementsByCategory,
    required this.recentlyEarned,
    required this.almostComplete,
  });

  factory AchievementStats.fromJson(Map<String, dynamic> json) {
    return AchievementStats(
      totalAchievements: json['total_achievements'] ?? 0,
      earnedAchievements: json['earned_achievements'] ?? 0,
      readyToClaim: json['ready_to_claim'] ?? 0,
      totalXpFromAchievements: json['total_xp_from_achievements'] ?? 0,
      completionRate: (json['completion_rate'] ?? 0.0).toDouble(),
      achievementsByCategory: Map<String, int>.from(
        json['achievements_by_category'] ?? {},
      ),
      recentlyEarned: (json['recently_earned'] as List<dynamic>?)
              ?.map((a) => Achievement.fromJson(a))
              .toList() ??
          [],
      almostComplete: (json['almost_complete'] as List<dynamic>?)
              ?.map((a) => Achievement.fromJson(a))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_achievements': totalAchievements,
      'earned_achievements': earnedAchievements,
      'ready_to_claim': readyToClaim,
      'total_xp_from_achievements': totalXpFromAchievements,
      'completion_rate': completionRate,
      'achievements_by_category': achievementsByCategory,
      'recently_earned': recentlyEarned.map((a) => a.toJson()).toList(),
      'almost_complete': almostComplete.map((a) => a.toJson()).toList(),
    };
  }
}

// Achievement filter
class AchievementFilter {
  final String? category;
  final bool? earned;
  final bool? canClaim;

  AchievementFilter({
    this.category,
    this.earned,
    this.canClaim,
  });

  bool get hasFilters {
    return category != null || earned != null || canClaim != null;
  }

  AchievementFilter copyWith({
    String? category,
    bool? earned,
    bool? canClaim,
  }) {
    return AchievementFilter(
      category: category ?? this.category,
      earned: earned ?? this.earned,
      canClaim: canClaim ?? this.canClaim,
    );
  }

  AchievementFilter clear() {
    return AchievementFilter();
  }

  String get displayName {
    if (earned == true) return 'Earned';
    if (canClaim == true) return 'Available';
    if (earned == false) return 'Locked';
    if (category != null) {
      switch (category!.toLowerCase()) {
        case 'task':
          return 'Task Badges';
        case 'streak':
          return 'Streak Badges';
        case 'level':
          return 'Level Badges';
        case 'special':
          return 'Special Badges';
        default:
          return category!;
      }
    }
    return 'All';
  }
}

// Badge category info
class BadgeCategory {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int count;

  const BadgeCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.count,
  });

  factory BadgeCategory.fromJson(Map<String, dynamic> json) {
    return BadgeCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '📋',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'count': count,
    };
  }
}

// Predefined badge categories
class BadgeCategories {
  static const List<BadgeCategory> categories = [
    BadgeCategory(
      id: 'task',
      name: 'Task Badges',
      description: 'Earned by completing tasks and achieving productivity milestones',
      emoji: '📋',
      count: 0,
    ),
    BadgeCategory(
      id: 'streak',
      name: 'Streak Badges',
      description: 'Earned by maintaining consistent daily activity streaks',
      emoji: '🔥',
      count: 0,
    ),
    BadgeCategory(
      id: 'level',
      name: 'Level Badges',
      description: 'Earned by reaching new experience levels and XP milestones',
      emoji: '⚡',
      count: 0,
    ),
    BadgeCategory(
      id: 'special',
      name: 'Special Badges',
      description: 'Rare badges earned through unique achievements and events',
      emoji: '🏆',
      count: 0,
    ),
  ];

  static BadgeCategory? getCategory(String id) {
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }
}
