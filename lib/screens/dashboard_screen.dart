import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/project_provider.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/stat_card.dart';
import '../widgets/common/progress_bar.dart';
import '../widgets/task/task_card.dart';
import '../widgets/achievement/achievement_card.dart';
import '../widgets/project/project_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<TaskProvider>().loadTasks(),
      context.read<AchievementProvider>().loadAchievements(),
      context.read<ProjectProvider>().loadProjects(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.purpleGradient.first,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.purpleGradient,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMd),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              final user = authProvider.user;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  Text(
                                    user?.firstName ?? 'User',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {
                      // Navigate to notifications
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                    onPressed: () {
                      // Navigate to settings
                    },
                  ),
                ],
              ),
              
              // Dashboard content
              SliverPadding(
                padding: const EdgeInsets.all(AppSizes.paddingMd),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // User Level & XP
                    _buildLevelCard(),
                    const SizedBox(height: AppSizes.paddingMd),
                    
                    // Stats Overview
                    _buildStatsSection(),
                    const SizedBox(height: AppSizes.paddingMd),
                    
                    // Recent Tasks
                    _buildRecentTasksSection(),
                    const SizedBox(height: AppSizes.paddingMd),
                    
                    // Active Projects
                    _buildActiveProjectsSection(),
                    const SizedBox(height: AppSizes.paddingMd),
                    
                    // Recent Achievements
                    _buildRecentAchievementsSection(),
                    const SizedBox(height: AppSizes.paddingLg),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        if (user == null) return const SizedBox.shrink();

        return GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.tealGradient,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${user.level}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Level ${user.level}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${user.xp} XP',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingMd),
                XPProgressBar(
                  currentXP: user.xp % AppConstants.baseXpPerLevel,
                  nextLevelXP: AppConstants.baseXpPerLevel + (user.level * AppConstants.xpMultiplier),
                  level: user.level,
                  showLevel: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Consumer3<TaskProvider, AchievementProvider, ProjectProvider>(
      builder: (context, taskProvider, achievementProvider, projectProvider, child) {
        final completedTasks = taskProvider.tasks.where((task) => 
          task.status == AppConstants.completedStatus).length;
        final totalTasks = taskProvider.tasks.length;
        final earnedAchievements = achievementProvider.achievements.where((a) => a.earned).length;
        final activeProjects = projectProvider.projects.where((p) => p.isActive).length;

        return AnimationLimiter(
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            crossAxisSpacing: AppSizes.paddingMd,
            mainAxisSpacing: AppSizes.paddingMd,
            children: AnimationConfiguration.toStaggeredList(
              duration: AppConstants.mediumAnimation,
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                StatCard(
                  title: 'Tasks',
                  value: '$completedTasks/$totalTasks',
                  icon: Icons.task_alt,
                  gradient: AppColors.tealGradient,
                ),
                StatCard(
                  title: 'Achievements',
                  value: '$earnedAchievements',
                  icon: Icons.emoji_events,
                  gradient: AppColors.yellowGradient,
                ),
                StatCard(
                  title: 'Projects',
                  value: '$activeProjects',
                  icon: Icons.folder,
                  gradient: AppColors.purpleGradient,
                ),
                StatCard(
                  title: 'Streak',
                  value: '7 days', // Mock data
                  icon: Icons.local_fire_department,
                  gradient: AppColors.redGradient,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentTasksSection() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final recentTasks = taskProvider.tasks
            .where((task) => task.status != AppConstants.completedStatus)
            .take(3)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Tasks',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to tasks screen
                  },
                  child: Text(
                    'See All',
                    style: TextStyle(color: AppColors.tealGradient.first),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingSm),
            if (recentTasks.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingLg),
                  child: Text(
                    'No recent tasks',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentTasks.length,
                itemBuilder: (context, index) {
                  final task = recentTasks[index];
                  return TaskCard(
                    task: task,
                    onTap: () {
                      // Navigate to task details
                    },
                    onToggleComplete: () {
                      taskProvider.completeTask(task.id);
                    },
                    onEdit: () {
                      // Navigate to edit task
                    },
                    onDelete: () {
                      taskProvider.deleteTask(task.id);
                    },
                    showActions: false,
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildActiveProjectsSection() {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        final activeProjects = projectProvider.projects
            .where((project) => project.isActive)
            .take(2)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Projects',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to projects screen
                  },
                  child: Text(
                    'See All',
                    style: TextStyle(color: AppColors.purpleGradient.first),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingSm),
            if (activeProjects.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingLg),
                  child: Text(
                    'No active projects',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 4,
                  mainAxisSpacing: AppSizes.paddingSm,
                ),
                itemCount: activeProjects.length,
                itemBuilder: (context, index) {
                  final project = activeProjects[index];
                  return ProjectOverviewCard(
                    project: project,
                    onTap: () {
                      // Navigate to project details
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildRecentAchievementsSection() {
    return Consumer<AchievementProvider>(
      builder: (context, achievementProvider, child) {
        final recentAchievements = achievementProvider.achievements
            .where((achievement) => achievement.canClaim || achievement.earned)
            .take(3)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Achievements',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to achievements screen
                  },
                  child: Text(
                    'See All',
                    style: TextStyle(color: AppColors.yellowGradient.first),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingSm),
            if (recentAchievements.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingLg),
                  child: Text(
                    'No achievements yet',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentAchievements.length,
                  itemBuilder: (context, index) {
                    final achievement = recentAchievements[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < recentAchievements.length - 1 
                            ? AppSizes.paddingMd 
                            : 0,
                      ),
                      child: AchievementBadge(
                        achievement: achievement,
                        size: 64,
                        showProgress: true,
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
