import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Zentry';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://api.zentry.com';
  static const String apiVersion = 'v1';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String achievementsKey = 'achievements';
  static const String tasksKey = 'tasks';
  static const String projectsKey = 'projects';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Gamification Constants
  static const int baseXpPerLevel = 100;
  static const int xpMultiplier = 50;
  static const int maxLevel = 100;
  
  // Task XP Rewards
  static const int lowPriorityXp = 10;
  static const int mediumPriorityXp = 25;
  static const int highPriorityXp = 50;
  
  // Achievement Types
  static const String taskBadge = 'task';
  static const String streakBadge = 'streak';
  static const String levelBadge = 'level';
  static const String specialBadge = 'special';
  
  // Task Priorities
  static const String lowPriority = 'low';
  static const String mediumPriority = 'medium';
  static const String highPriority = 'high';
  
  // Task Status
  static const String pendingStatus = 'pending';
  static const String inProgressStatus = 'in_progress';
  static const String completedStatus = 'completed';
  
  // Notification Types
  static const String taskReminder = 'task_reminder';
  static const String achievementUnlocked = 'achievement_unlocked';
  static const String levelUp = 'level_up';
  static const String streakMilestone = 'streak_milestone';
}

class AppColors {
  // Background Colors
  static const Color background = Color(0xFF0F172A);
  static const Color cardBackground = Color(0xFF1E293B);
  static const Color secondaryBackground = Color(0xFF334155);
  static const Color border = Color(0xFF475569);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  
  // Accent Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  
  // Gradient Colors
  static const List<Color> purpleGradient = [
    Color(0xFFA855F7),
    Color(0xFF3B82F6),
  ];
  
  static const List<Color> tealGradient = [
    Color(0xFF14B8A6),
    Color(0xFF06B6D4),
  ];
  
  static const List<Color> greenGradient = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];
  
  static const List<Color> yellowGradient = [
    Color(0xFFF59E0B),
    Color(0xFFD97706),
  ];
  
  static const List<Color> redGradient = [
    Color(0xFFEF4444),
    Color(0xFFDC2626),
  ];
  
  static const List<Color> blueGradient = [
    Color(0xFF3B82F6),
    Color(0xFF1D4ED8),
  ];
  
  // Priority Colors
  static const Color lowPriority = Color(0xFF10B981);
  static const Color mediumPriority = Color(0xFFF59E0B);
  static const Color highPriority = Color(0xFFEF4444);
  
  // Achievement Colors
  static const Color earned = Color(0xFF10B981);
  static const Color claimable = Color(0xFFF59E0B);
  static const Color locked = Color(0xFF64748B);
}

class AppSizes {
  // Padding & Margins
  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;
  static const double paddingXl = 32.0;
  
  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  
  // Icon Sizes
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  
  // Avatar Sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 96.0;
  
  // Card Sizes
  static const double cardHeight = 120.0;
  static const double statCardHeight = 100.0;
  static const double taskCardHeight = 80.0;
  
  // Button Heights
  static const double buttonHeight = 48.0;
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightLg = 56.0;
}

class AppStrings {
  // Navigation
  static const String dashboard = 'Dashboard';
  static const String tasks = 'Tasks';
  static const String projects = 'Projects';
  static const String achievements = 'Achievements';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  
  // Authentication
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  
  // Tasks
  static const String createTask = 'Create Task';
  static const String editTask = 'Edit Task';
  static const String deleteTask = 'Delete Task';
  static const String taskTitle = 'Task Title';
  static const String taskDescription = 'Task Description';
  static const String dueDate = 'Due Date';
  static const String priority = 'Priority';
  static const String category = 'Category';
  static const String assignTo = 'Assign To';
  
  // Projects
  static const String createProject = 'Create Project';
  static const String editProject = 'Edit Project';
  static const String deleteProject = 'Delete Project';
  static const String projectName = 'Project Name';
  static const String projectDescription = 'Project Description';
  static const String teamMembers = 'Team Members';
  
  // Achievements
  static const String badgesEarned = 'Badges Earned';
  static const String readyToClaim = 'Ready to Claim';
  static const String totalXp = 'Total XP';
  static const String completionRate = 'Completion Rate';
  static const String claim = 'Claim';
  static const String earned = 'Earned';
  static const String locked = 'Locked';
  
  // Common
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String create = 'Create';
  static const String update = 'Update';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String info = 'Info';
  static const String retry = 'Retry';
  static const String refresh = 'Refresh';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String all = 'All';
  static const String none = 'None';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String ok = 'OK';
  static const String confirm = 'Confirm';
}
