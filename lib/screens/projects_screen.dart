import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../utils/constants.dart';
import '../models/project.dart';
import '../widgets/project/project_card.dart';
import '../widgets/common/glass_card.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  // Mock projects data
  final List<Project> _mockProjects = [
    Project(
      id: '1',
      name: 'Zentry Mobile App',
      description: 'A gamified productivity app built with Flutter featuring task management, achievements, and progress tracking.',
      status: 'active',
      color: 'purple',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      userId: 'user1',
      taskIds: ['1', '2', '3', '5'],
    ),
    Project(
      id: '2',
      name: 'Personal Website',
      description: 'Portfolio website showcasing projects and skills using React and TypeScript.',
      status: 'active',
      color: 'teal',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      dueDate: DateTime.now().add(const Duration(days: 14)),
      userId: 'user1',
      taskIds: ['6', '7', '8'],
    ),
    Project(
      id: '3',
      name: 'Machine Learning Course',
      description: 'Complete online ML course with hands-on projects and assignments.',
      status: 'active',
      color: 'blue',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      dueDate: DateTime.now().add(const Duration(days: 60)),
      userId: 'user1',
      taskIds: ['9', '10'],
    ),
    Project(
      id: '4',
      name: 'Home Automation',
      description: 'IoT project to automate home lighting and temperature control.',
      status: 'completed',
      color: 'green',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      dueDate: DateTime.now().subtract(const Duration(days: 5)),
      completedAt: DateTime.now().subtract(const Duration(days: 10)),
      userId: 'user1',
      taskIds: ['11', '12', '13', '14'],
    ),
    Project(
      id: '5',
      name: 'Mobile Game Prototype',
      description: 'Unity-based mobile game prototype with multiplayer features.',
      status: 'on_hold',
      color: 'red',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      userId: 'user1',
      taskIds: ['15', '16'],
    ),
  ];

  List<Project> get _activeProjects => _mockProjects.where((p) => p.isActive).toList();
  List<Project> get _completedProjects => _mockProjects.where((p) => p.isCompleted).toList();
  List<Project> get _onHoldProjects => _mockProjects.where((p) => p.isOnHold).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
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
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Projects',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingSm),
                          Row(
                            children: [
                              _buildStatChip('${_activeProjects.length} Active', Icons.folder_open),
                              const SizedBox(width: AppSizes.paddingSm),
                              _buildStatChip('${_completedProjects.length} Done', Icons.check_circle),
                              const SizedBox(width: AppSizes.paddingSm),
                              _buildStatChip('${_onHoldProjects.length} On Hold', Icons.pause_circle),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    _showAddProjectDialog();
                  },
                ),
              ],
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
                  indicatorColor: AppColors.purpleGradient.first,
                  labelColor: AppColors.textPrimary,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Active'),
                    Tab(text: 'Completed'),
                    Tab(text: 'On Hold'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildProjectGrid(_mockProjects, 'No projects found'),
                    _buildProjectGrid(_activeProjects, 'No active projects'),
                    _buildProjectGrid(_completedProjects, 'No completed projects'),
                    _buildProjectGrid(_onHoldProjects, 'No projects on hold'),
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

  Widget _buildProjectGrid(List<Project> projects, String emptyMessage) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
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
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 1.8, // Further reduced to give even more height to cards
          mainAxisSpacing: AppSizes.paddingMd,
        ),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: AppConstants.mediumAnimation,
            columnCount: 1,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: ProjectCard(
                  project: project,
                  onTap: () => _showProjectDetails(project),
                  onEdit: () => _editProject(project),
                  onDelete: () => _deleteProject(project),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showProjectDetails(Project project) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => GlassCard(
          margin: const EdgeInsets.all(AppSizes.paddingMd),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getProjectGradient(project.color ?? 'purple'),
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        ),
                        child: const Icon(Icons.folder, color: Colors.white),
                      ),
                      const SizedBox(width: AppSizes.paddingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              project.statusLabel,
                              style: TextStyle(
                                color: _getStatusColor(project.status),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingMd),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSm),
                  Text(
                    project.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMd),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Tasks',
                          '${project.taskIds.length}',
                          Icons.task_alt,
                          AppColors.tealGradient,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingSm),
                      Expanded(
                        child: _buildInfoCard(
                          'Progress',
                          '65%', // Mock progress
                          Icons.trending_up,
                          AppColors.greenGradient,
                        ),
                      ),
                    ],
                  ),
                  if (project.dueDate != null) ...[
                    const SizedBox(height: AppSizes.paddingMd),
                    _buildInfoCard(
                      'Due Date',
                      '${project.dueDate!.day}/${project.dueDate!.month}/${project.dueDate!.year}',
                      Icons.schedule,
                      AppColors.yellowGradient,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient.map((c) => c.withValues(alpha: 0.1)).toList()),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: gradient.first.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: gradient.first),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: gradient.first,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _editProject(Project project) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit project functionality coming soon!')),
    );
  }

  void _deleteProject(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Project', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${project.name}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Project deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Add New Project', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Project creation functionality coming soon!',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  List<Color> _getProjectGradient(String color) {
    switch (color.toLowerCase()) {
      case 'purple':
        return AppColors.purpleGradient;
      case 'teal':
        return AppColors.tealGradient;
      case 'blue':
        return AppColors.blueGradient;
      case 'green':
        return AppColors.greenGradient;
      case 'red':
        return AppColors.redGradient;
      case 'yellow':
        return AppColors.yellowGradient;
      default:
        return AppColors.purpleGradient;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'completed':
        return AppColors.success;
      case 'on_hold':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }
}
