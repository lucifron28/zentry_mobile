import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class AppHelpers {
  // Date formatting
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }
  
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }
  
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  static String formatTimeRemaining(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m left';
    } else {
      return 'Due now';
    }
  }
  
  // Level and XP calculations
  static int calculateLevel(int xp) {
    if (xp < AppConstants.baseXpPerLevel) return 1;
    
    int level = 1;
    int remainingXp = xp;
    
    while (remainingXp >= getXpRequiredForLevel(level + 1)) {
      remainingXp -= getXpRequiredForLevel(level + 1);
      level++;
      if (level >= AppConstants.maxLevel) break;
    }
    
    return level;
  }
  
  static int getXpRequiredForLevel(int level) {
    return AppConstants.baseXpPerLevel + (level - 1) * AppConstants.xpMultiplier;
  }
  
  static int getXpForCurrentLevel(int totalXp) {
    final level = calculateLevel(totalXp);
    int xpUsed = 0;
    
    for (int i = 1; i < level; i++) {
      xpUsed += getXpRequiredForLevel(i);
    }
    
    return totalXp - xpUsed;
  }
  
  static int getXpRequiredForNextLevel(int totalXp) {
    final level = calculateLevel(totalXp);
    return getXpRequiredForLevel(level + 1);
  }
  
  static double getLevelProgress(int totalXp) {
    final currentLevelXp = getXpForCurrentLevel(totalXp);
    final requiredXp = getXpRequiredForNextLevel(totalXp);
    return currentLevelXp / requiredXp;
  }
  
  // Task XP calculation
  static int getTaskXp(String priority) {
    switch (priority.toLowerCase()) {
      case AppConstants.lowPriority:
        return AppConstants.lowPriorityXp;
      case AppConstants.mediumPriority:
        return AppConstants.mediumPriorityXp;
      case AppConstants.highPriority:
        return AppConstants.highPriorityXp;
      default:
        return AppConstants.lowPriorityXp;
    }
  }
  
  // Priority colors
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case AppConstants.lowPriority:
        return AppColors.lowPriority;
      case AppConstants.mediumPriority:
        return AppColors.mediumPriority;
      case AppConstants.highPriority:
        return AppColors.highPriority;
      default:
        return AppColors.textMuted;
    }
  }
  
  static String getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case AppConstants.lowPriority:
        return 'Low';
      case AppConstants.mediumPriority:
        return 'Medium';
      case AppConstants.highPriority:
        return 'High';
      default:
        return 'Unknown';
    }
  }
  
  // Status colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case AppConstants.completedStatus:
        return AppColors.success;
      case AppConstants.inProgressStatus:
        return AppColors.warning;
      case AppConstants.pendingStatus:
        return AppColors.textMuted;
      default:
        return AppColors.textMuted;
    }
  }
  
  // Achievement colors
  static Color getAchievementColor(bool earned, bool canClaim) {
    if (earned) return AppColors.earned;
    if (canClaim) return AppColors.claimable;
    return AppColors.locked;
  }
  
  // Gradient helpers
  static List<Color> getGradientForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'task':
        return AppColors.purpleGradient;
      case 'streak':
        return AppColors.tealGradient;
      case 'level':
        return AppColors.blueGradient;
      case 'special':
        return AppColors.yellowGradient;
      default:
        return AppColors.purpleGradient;
    }
  }
  
  // Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
  
  static bool isValidPassword(String password) {
    return password.length >= 8;
  }
  
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!isValidPassword(value)) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  // Snackbar helpers
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.cardBackground,
      ),
    );
  }
  
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: AppColors.danger),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.cardBackground,
      ),
    );
  }
  
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.warning),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.cardBackground,
      ),
    );
  }
  
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.cardBackground,
      ),
    );
  }
  
  // Dialog helpers
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDangerous
                ? ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
  
  // Loading dialog
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
  
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  // Color utilities
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  // Number formatting
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
  
  // Percentage formatting
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }
  
  // Debouncer for search
  static Timer? _debounceTimer;
  
  static void debounce(VoidCallback action, {Duration delay = const Duration(milliseconds: 500)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, action);
  }
}
