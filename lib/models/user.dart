class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatar;
  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActivity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final Map<String, dynamic>? preferences;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
    required this.xp,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivity,
    required this.createdAt,
    required this.updatedAt,
    this.isEmailVerified = false,
    this.preferences,
  });

  String get fullName => '$firstName $lastName';
  
  String get displayName {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return fullName;
    } else if (firstName.isNotEmpty) {
      return firstName;
    }
    return email.split('@').first;
  }
  
  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      avatar: json['avatar'],
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastActivity: json['last_activity'] != null
          ? DateTime.parse(json['last_activity'])
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      isEmailVerified: json['is_email_verified'] ?? false,
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
      'xp': xp,
      'level': level,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_activity': lastActivity.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_email_verified': isEmailVerified,
      'preferences': preferences,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
    int? xp,
    int? level,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivity,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivity: lastActivity ?? this.lastActivity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $fullName, xp: $xp, level: $level)';
  }
}

// User statistics model
class UserStats {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final int totalProjects;
  final int activeProjects;
  final int completedProjects;
  final int totalAchievements;
  final int earnedAchievements;
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final double completionRate;
  final Map<String, int> tasksByPriority;
  final Map<String, int> tasksByCategory;
  final List<Map<String, dynamic>> weeklyActivity;

  UserStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.totalProjects,
    required this.activeProjects,
    required this.completedProjects,
    required this.totalAchievements,
    required this.earnedAchievements,
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    required this.completionRate,
    required this.tasksByPriority,
    required this.tasksByCategory,
    required this.weeklyActivity,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalTasks: json['total_tasks'] ?? 0,
      completedTasks: json['completed_tasks'] ?? 0,
      pendingTasks: json['pending_tasks'] ?? 0,
      overdueTasks: json['overdue_tasks'] ?? 0,
      totalProjects: json['total_projects'] ?? 0,
      activeProjects: json['active_projects'] ?? 0,
      completedProjects: json['completed_projects'] ?? 0,
      totalAchievements: json['total_achievements'] ?? 0,
      earnedAchievements: json['earned_achievements'] ?? 0,
      totalXp: json['total_xp'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      completionRate: (json['completion_rate'] ?? 0.0).toDouble(),
      tasksByPriority: Map<String, int>.from(json['tasks_by_priority'] ?? {}),
      tasksByCategory: Map<String, int>.from(json['tasks_by_category'] ?? {}),
      weeklyActivity: List<Map<String, dynamic>>.from(
        json['weekly_activity'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_tasks': totalTasks,
      'completed_tasks': completedTasks,
      'pending_tasks': pendingTasks,
      'overdue_tasks': overdueTasks,
      'total_projects': totalProjects,
      'active_projects': activeProjects,
      'completed_projects': completedProjects,
      'total_achievements': totalAchievements,
      'earned_achievements': earnedAchievements,
      'total_xp': totalXp,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'completion_rate': completionRate,
      'tasks_by_priority': tasksByPriority,
      'tasks_by_category': tasksByCategory,
      'weekly_activity': weeklyActivity,
    };
  }
}
