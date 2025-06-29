import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../utils/constants.dart';
import '../models/achievement.dart';
import '../widgets/achievement/achievement_card.dart';
import '../widgets/common/glass_card.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  // Mock achievements data
  final List<Achievement> _mockAchievements = [
    Achievement(
      id: 1,
      name: 'First Steps',
      description: 'Complete your first task',
      emoji: '🎯',
      category: 'task',
      experienceReward: 10,
      earned: true,
      earnedAt: DateTime.now().subtract(const Duration(days: 14)),
      requirementValue: 1,
      currentProgress: 1,
    ),
    Achievement(
      id: 2,
      name: 'Task Master',
      description: 'Complete 10 tasks',
      emoji: '✅',
      category: 'task',
      experienceReward: 50,
      earned: true,
      earnedAt: DateTime.now().subtract(const Duration(days: 7)),
      requirementValue: 10,
      currentProgress: 10,
    ),
    Achievement(
      id: 3,
      name: 'Speed Demon',
      description: 'Complete 5 tasks in one day',
      emoji: '⚡',
      category: 'streak',
      experienceReward: 25,
      canClaim: true,
      requirementValue: 5,
      currentProgress: 5,
    ),
    Achievement(
      id: 4,
      name: 'Level Up',
      description: 'Reach level 5',
      emoji: '🚀',
      category: 'level',
      experienceReward: 100,
      earned: false,
      requirementValue: 5,
      currentProgress: 3,
    ),
    Achievement(
      id: 5,
      name: 'Streak Keeper',
      description: 'Maintain a 7-day streak',
      emoji: '🔥',
      category: 'streak',
      experienceReward: 75,
      earned: false,
      requirementValue: 7,
      currentProgress: 4,
    ),
    Achievement(
      id: 6,
      name: 'Project Pioneer',
      description: 'Create your first project',
      emoji: '📁',
      category: 'special',
      experienceReward: 30,
      earned: true,
      earnedAt: DateTime.now().subtract(const Duration(days: 10)),
      requirementValue: 1,
      currentProgress: 1,
    ),
    Achievement(
      id: 7,
      name: 'Multitasker',
      description: 'Have 3 active projects simultaneously',
      emoji: '🎭',
      category: 'special',
      experienceReward: 60,
      earned: false,
      requirementValue: 3,
      currentProgress: 2,
    ),
    Achievement(
      id: 8,
      name: 'Night Owl',
      description: 'Complete tasks after 10 PM',
      emoji: '🦉',
      category: 'special',
      experienceReward: 20,
      earned: false,
      requirementValue: 5,
      currentProgress: 2,
    ),
    Achievement(
      id: 9,
      name: 'Early Bird',
      description: 'Complete tasks before 8 AM',
      emoji: '🐦',
      category: 'special',
      experienceReward: 20,
      earned: false,
      requirementValue: 5,
      currentProgress: 1,
    ),
    Achievement(
      id: 10,
      name: 'Century Club',
      description: 'Complete 100 tasks',
      emoji: '💯',
      category: 'task',
      experienceReward: 200,
      earned: false,
      requirementValue: 100,
      currentProgress: 25,
    ),
  ];

  List<Achievement> get _earnedAchievements => _mockAchievements.where((a) => a.earned).toList();
  List<Achievement> get _claimableAchievements => _mockAchievements.where((a) => a.canClaim).toList();
  List<Achievement> get _lockedAchievements => _mockAchievements.where((a) => a.isLocked).toList();
  List<Achievement> get _inProgressAchievements => _mockAchievements.where((a) => 
    !a.earned && !a.canClaim && !a.isLocked).toList();

  @override
  Widget build(BuildContext context) {
    final totalXP = _earnedAchievements.fold<int>(0, (sum, a) => sum + a.experienceReward);
    
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
                                  '${_earnedAchievements.length}/${_mockAchievements.length}',
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
                              _buildStatChip('${_earnedAchievements.length} Earned', Icons.check_circle),
                              const SizedBox(width: AppSizes.paddingSm),
                              _buildStatChip('${_claimableAchievements.length} Ready', Icons.star),
                              const SizedBox(width: AppSizes.paddingSm),
                              _buildStatChip('${_inProgressAchievements.length} Progress', Icons.trending_up),
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
                    _buildAchievementsList(_mockAchievements, 'No achievements found'),
                    _buildAchievementsList(_earnedAchievements, 'No earned achievements'),
                    _buildAchievementsList(_claimableAchievements, 'No claimable achievements'),
                    _buildAchievementsList(_lockedAchievements, 'No locked achievements'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Claimed ${achievement.experienceReward} XP!'),
                  backgroundColor: AppColors.success,
                ),
              );
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
