import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../models/achievement.dart';
import '../providers/achievement_provider.dart';
import '../widgets/achievement/achievement_card.dart';
import '../widgets/common/glass_card.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AchievementProvider>(
      builder: (context, achievementProvider, child) {
        if (achievementProvider.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (achievementProvider.error != null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSizes.paddingMd),
                  Text(
                    achievementProvider.error!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.paddingMd),
                  ElevatedButton(
                    onPressed: () => achievementProvider.loadAchievements(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final totalXP = achievementProvider.totalXpFromAchievements;
        final earnedAchievements = achievementProvider.getEarnedAchievements();
        final claimableAchievements = achievementProvider.getClaimableAchievements();
        final lockedAchievements = achievementProvider.getLockedAchievements();
        final allAchievements = achievementProvider.allAchievements;
        
        return Scaffold(
          backgroundColor: AppColors.background,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 250,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppColors.yellowGradient,
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingMd),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Achievements',
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSizes.paddingSm),
                              Container(
                                padding: const EdgeInsets.all(AppSizes.paddingMd),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppSizes.paddingSm),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.emoji_events,
                                        color: Colors.orange,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.paddingMd),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Total XP Earned',
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.9),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '$totalXP XP',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${earnedAchievements.length}/${allAchievements.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSizes.paddingMd),
                              Row(
                                children: [
                                  _buildStatChip('${earnedAchievements.length} Earned', Icons.check_circle),
                                  const SizedBox(width: AppSizes.paddingSm),
                                  _buildStatChip('${claimableAchievements.length} Ready', Icons.star),
                                  const SizedBox(width: AppSizes.paddingSm),
                                  _buildStatChip('${lockedAchievements.length} Locked', Icons.lock),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  Container(
                    color: AppColors.cardBackground,
                    child: TabBar(
                      indicatorColor: AppColors.yellowGradient.first,
                      labelColor: AppColors.textPrimary,
                      unselectedLabelColor: AppColors.textSecondary,
                      tabs: const [
                        Tab(text: 'All'),
                        Tab(text: 'Earned'),
                        Tab(text: 'Claimable'),
                        Tab(text: 'Locked'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildAchievementsList(allAchievements, 'No achievements found'),
                        _buildAchievementsList(earnedAchievements, 'No earned achievements'),
                        _buildAchievementsList(claimableAchievements, 'No claimable achievements'),
                        _buildAchievementsList(lockedAchievements, 'No locked achievements'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSm,
        vertical: AppSizes.paddingXs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(List<Achievement> achievements, String emptyMessage) {
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
              emptyMessage,
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
        padding: const EdgeInsets.all(AppSizes.paddingMd),
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
                  onTap: () => _showAchievementDetails(achievement),
                  onClaim: achievement.canClaim 
                      ? () => _claimAchievement(achievement) 
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        margin: const EdgeInsets.all(AppSizes.paddingMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getGradientColors(achievement.category),
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    achievement.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMd),
              Text(
                achievement.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingSm),
              Text(
                achievement.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingMd),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMd,
                  vertical: AppSizes.paddingSm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.tealGradient.map((c) => c.withValues(alpha: 0.2)).toList(),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(color: AppColors.tealGradient.first.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.teal, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${achievement.experienceReward} XP',
                      style: TextStyle(
                        color: AppColors.tealGradient.first,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (achievement.currentProgress != null && 
                  achievement.requirementValue != null &&
                  !achievement.earned) ...[
                const SizedBox(height: AppSizes.paddingMd),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${achievement.currentProgress}/${achievement.requirementValue}',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingSm),
                    LinearProgressIndicator(
                      value: achievement.progressPercentage,
                      backgroundColor: AppColors.border.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation(
                        _getGradientColors(achievement.category).first,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _claimAchievement(Achievement achievement) {
    final achievementProvider = context.read<AchievementProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getGradientColors(achievement.category),
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  achievement.emoji,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMd),
            Text(
              'Achievement Unlocked!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSm),
            Text(
              achievement.name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMd,
                vertical: AppSizes.paddingSm,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.tealGradient),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Text(
                '+${achievement.experienceReward} XP',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await achievementProvider.claimAchievement(achievement.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Claimed ${achievement.experienceReward} XP!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Claim'),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors(String category) {
    switch (category.toLowerCase()) {
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
