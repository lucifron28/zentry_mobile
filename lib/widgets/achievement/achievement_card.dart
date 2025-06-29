import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/achievement.dart';
import '../../utils/constants.dart';
import '../common/glass_card.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;
  final VoidCallback? onClaim;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final canClaim = achievement.canClaim;
    final isEarned = achievement.earned;
    final isLocked = achievement.isLocked;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Row(
            children: [
              // Achievement icon
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: isLocked
                          ? null
                          : LinearGradient(
                              colors: _getGradientColors(achievement.category),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color: isLocked ? AppColors.locked : null,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Icon(
                      _getAchievementIcon(achievement.category),
                      size: AppSizes.iconLg,
                      color: isLocked ? AppColors.textMuted : Colors.white,
                    ),
                  ),
                  if (canClaim)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (isEarned)
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSizes.paddingMd),
              
              // Achievement content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isLocked
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.paddingSm),
                    Row(
                      children: [
                        // Points
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                          ),
                          child: Text(
                            '${achievement.experienceReward} pts',
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingSm),
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _getGradientColors(achievement.category),
                            ),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                          ),
                          child: Text(
                            achievement.category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Progress indicator (if applicable)
                        if (achievement.currentProgress != null && 
                            achievement.requirementValue != null &&
                            !isEarned) ...[
                          Text(
                            '${achievement.currentProgress}/${achievement.requirementValue}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    // Progress bar
                    if (achievement.currentProgress != null && 
                        achievement.requirementValue != null &&
                        !isEarned) ...[
                      const SizedBox(height: AppSizes.paddingSm),
                      LinearProgressIndicator(
                        value: achievement.progressPercentage,
                        backgroundColor: AppColors.border.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation(statusColor),
                        minHeight: 4,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Claim button
              if (canClaim) ...[
                const SizedBox(width: AppSizes.paddingSm),
                ElevatedButton(
                  onPressed: onClaim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMd,
                      vertical: AppSizes.paddingSm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                  ),
                  child: const Text(
                    'Claim',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (achievement.earned) {
      return AppColors.earned;
    } else if (achievement.canClaim) {
      return AppColors.claimable;
    } else {
      return AppColors.locked;
    }
  }

  IconData _getAchievementIcon(String type) {
    switch (type.toLowerCase()) {
      case 'task':
        return Icons.task_alt;
      case 'streak':
        return Icons.local_fire_department;
      case 'level':
        return Icons.trending_up;
      case 'special':
        return Icons.star;
      default:
        return Icons.emoji_events;
    }
  }

  List<Color> _getGradientColors(String type) {
    switch (type.toLowerCase()) {
      case 'task':
        return AppColors.tealGradient;
      case 'streak':
        return AppColors.redGradient;
      case 'level':
        return AppColors.purpleGradient;
      case 'special':
        return AppColors.yellowGradient;
      default:
        return AppColors.blueGradient;
    }
  }
}

class AchievementGrid extends StatelessWidget {
  final List<Achievement> achievements;
  final Function(Achievement) onAchievementTap;
  final Function(Achievement) onClaimAchievement;
  final String? emptyMessage;

  const AchievementGrid({
    super.key,
    required this.achievements,
    required this.onAchievementTap,
    required this.onClaimAchievement,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.paddingMd),
            Text(
              emptyMessage ?? 'No achievements found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: AppConstants.mediumAnimation,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: AchievementCard(
                  achievement: achievement,
                  onTap: () => onAchievementTap(achievement),
                  onClaim: achievement.canClaim
                      ? () => onClaimAchievement(achievement)
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final double size;
  final bool showProgress;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.size = 48.0,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = achievement.isLocked;
    final progress = achievement.currentProgress != null && achievement.requirementValue != null
        ? achievement.progressPercentage
        : 1.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: isLocked
                    ? null
                    : LinearGradient(
                        colors: _getGradientColors(achievement.category),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: isLocked ? AppColors.locked : null,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getAchievementIcon(achievement.category),
                size: size * 0.6,
                color: isLocked ? AppColors.textMuted : Colors.white,
              ),
            ),
            if (showProgress && !isLocked && progress < 1.0)
              Positioned.fill(
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(
                    _getGradientColors(achievement.category).first,
                  ),
                ),
              ),
          ],
        ),
        if (showProgress && achievement.currentProgress != null && achievement.requirementValue != null) ...[
          const SizedBox(height: 2), // Reduced spacing
          SizedBox(
            width: size + 16, // Appropriate width constraint
            child: Text(
              '${achievement.currentProgress}/${achievement.requirementValue}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: size * 0.14, // Smaller font size to fit better
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ],
    );
  }

  IconData _getAchievementIcon(String type) {
    switch (type.toLowerCase()) {
      case 'task':
        return Icons.task_alt;
      case 'streak':
        return Icons.local_fire_department;
      case 'level':
        return Icons.trending_up;
      case 'special':
        return Icons.star;
      default:
        return Icons.emoji_events;
    }
  }

  List<Color> _getGradientColors(String type) {
    switch (type.toLowerCase()) {
      case 'task':
        return AppColors.tealGradient;
      case 'streak':
        return AppColors.redGradient;
      case 'level':
        return AppColors.purpleGradient;
      case 'special':
        return AppColors.yellowGradient;
      default:
        return AppColors.blueGradient;
    }
  }
}
