import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/project_provider.dart';
import '../providers/team_provider.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/stat_card.dart';
import '../widgets/common/progress_bar.dart';
import '../widgets/task/task_card.dart';
import '../widgets/achievement/achievement_card.dart';
import '../widgets/project/project_card.dart';
import 'tasks_screen.dart';
import 'projects_screen.dart';
import 'achievements_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'teams_screen.dart';

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
      context.read<TeamProvider>().loadTeams(),
    ]);
  }

  void _navigateToScreen(int index) {
    // Find the parent MainLayout and trigger navigation
    final mainLayoutContext = context.findAncestorStateOfType<State<StatefulWidget>>();
    if (mainLayoutContext != null) {
      // Use a callback to notify parent or use a different approach
      // For now, we'll use Navigator.push as a fallback
      switch (index) {
        case 1: // Tasks
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TasksScreen()),
          );
          break;
        case 2: // Projects
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProjectsScreen()),
          );
          break;
        case 3: // Achievements
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AchievementsScreen()),
          );
          break;
      }
    }
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
                                      color: Colors.white.withValues(alpha: 0.9),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                    onPressed: () {
                      // Navigate to settings
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
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
                    
                    // My Teams
                    _buildMyTeamsSection(),
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
    return Consumer4<TaskProvider, AchievementProvider, ProjectProvider, TeamProvider>(
      builder: (context, taskProvider, achievementProvider, projectProvider, teamProvider, child) {
        // Calculate stats using proper provider getters
        final completedTasks = taskProvider.completedTasks;
        final totalTasks = taskProvider.totalTasks;
        final earnedAchievements = achievementProvider.earnedAchievements;
        final totalAchievements = achievementProvider.totalAchievements;
        final activeProjects = projectProvider.activeProjects;
        final totalProjects = projectProvider.totalProjects;
        final myTeams = teamProvider.myTeams.length;
        
        // Calculate completion percentage for task progress
        final taskProgress = totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;

        return AnimationLimiter(
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
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
                  title: 'Tasks Completed',
                  value: '$completedTasks/$totalTasks',
                  subtitle: '$taskProgress% done',
                  icon: Icons.task_alt,
                  gradient: AppColors.tealGradient,
                  onTap: () => _navigateToScreen(1), // Navigate to tasks
                ),
                StatCard(
                  title: 'Achievements',
                  value: '$earnedAchievements/$totalAchievements',
                  subtitle: '${achievementProvider.readyToClaim} ready to claim',
                  icon: Icons.emoji_events,
                  gradient: AppColors.yellowGradient,
                  onTap: () => _navigateToScreen(3), // Navigate to achievements
                ),
                StatCard(
                  title: 'Active Projects',
                  value: '$activeProjects',
                  subtitle: '$totalProjects total projects',
                  icon: Icons.folder,
                  gradient: AppColors.purpleGradient,
                  onTap: () => _navigateToScreen(2), // Navigate to projects
                ),
                StatCard(
                  title: 'My Teams',
                  value: '$myTeams',
                  subtitle: '${teamProvider.adminTeams.length} admin roles',
                  icon: Icons.groups,
                  gradient: AppColors.blueGradient,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TeamsScreen()),
                  ),
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
                    _navigateToScreen(1); // Tasks screen is at index 1
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
                      _navigateToScreen(1); // Navigate to tasks screen
                    },
                    onToggleComplete: () async {
                      final success = await taskProvider.completeTask(task.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success 
                                ? 'Task completed! +${task.xpReward} XP'
                                : 'Failed to complete task',
                            ),
                            backgroundColor: success ? AppColors.success : AppColors.danger,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    onEdit: () {
                      // Navigate to edit task
                      _navigateToScreen(1); // Navigate to tasks screen where editing can be done
                    },
                    onDelete: () async {
                      final success = await taskProvider.deleteTask(task.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success 
                                ? 'Task deleted successfully'
                                : 'Failed to delete task',
                            ),
                            backgroundColor: success ? AppColors.success : AppColors.danger,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
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
                    _navigateToScreen(2); // Projects screen is at index 2
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
                      _navigateToScreen(2); // Navigate to projects screen
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
                    _navigateToScreen(3); // Achievements screen is at index 3
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
                height: 110, // Increased height to accommodate badges and text without overflow
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

  Widget _buildMyTeamsSection() {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        final myTeams = teamProvider.myTeams.take(3).toList(); // Show max 3 teams

        return GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Teams',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TeamsScreen()),
                        );
                      },
                      child: const Text(
                        'View All',
                        style: TextStyle(color: AppColors.success),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingMd),
                if (myTeams.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.group_outlined,
                          size: 48,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No teams yet',
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TeamsScreen()),
                            );
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Create Team'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      ...myTeams.map((team) => _buildTeamCard(team)),
                      if (teamProvider.myTeams.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '+${teamProvider.myTeams.length - 3} more teams',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamCard(team) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamsScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.orangeGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.group,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${team.memberCount} members',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
