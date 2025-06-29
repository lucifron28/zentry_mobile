import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../widgets/common/glass_card.dart';
import '../../providers/team_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/team.dart';
import '../../models/project.dart';
import '../../models/task.dart';

class TeamProjectManagementScreen extends StatefulWidget {
  final String teamId;

  const TeamProjectManagementScreen({
    super.key,
    required this.teamId,
  });

  @override
  State<TeamProjectManagementScreen> createState() => _TeamProjectManagementScreenState();
}

class _TeamProjectManagementScreenState extends State<TeamProjectManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Team? _team;
  List<Project> _teamProjects = [];
  List<Task> _teamTasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTeamData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTeamData() async {
    final teamProvider = context.read<TeamProvider>();
    final projectProvider = context.read<ProjectProvider>();
    final taskProvider = context.read<TaskProvider>();

    // Load team
    _team = teamProvider.teams.firstWhere(
      (team) => team.id == widget.teamId,
      orElse: () => throw Exception('Team not found'),
    );

    // Load team projects
    _teamProjects = projectProvider.projects
        .where((project) => project.teamId == widget.teamId)
        .toList();

    // Load team tasks
    _teamTasks = taskProvider.tasks
        .where((task) => task.teamId == widget.teamId)
        .toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _team?.name ?? 'Team Projects',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.success,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.success,
          tabs: const [
            Tab(icon: Icon(Icons.folder), text: 'Projects'),
            Tab(icon: Icon(Icons.task), text: 'Tasks'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showCreateOptions,
            icon: const Icon(Icons.add),
            tooltip: 'Add Project or Task',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProjectsTab(),
          _buildTasksTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildProjectsTab() {
    return RefreshIndicator(
      onRefresh: _loadTeamData,
      child: _teamProjects.isEmpty
          ? _buildEmptyState(
              Icons.folder_open,
              'No Team Projects',
              'Create your first team project to get started with collaboration.',
              () => _createProject(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _teamProjects.length,
              itemBuilder: (context, index) {
                final project = _teamProjects[index];
                return _buildProjectCard(project);
              },
            ),
    );
  }

  Widget _buildTasksTab() {
    return RefreshIndicator(
      onRefresh: _loadTeamData,
      child: _teamTasks.isEmpty
          ? _buildEmptyState(
              Icons.assignment,
              'No Team Tasks',
              'Assign tasks to team members to track progress.',
              () => _createTask(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _teamTasks.length,
              itemBuilder: (context, index) {
                final task = _teamTasks[index];
                return _buildTaskCard(task);
              },
            ),
    );
  }

  Widget _buildAnalyticsTab() {
    final totalProjects = _teamProjects.length;
    final completedProjects = _teamProjects.where((p) => p.isCompleted).length;
    final totalTasks = _teamTasks.length;
    final completedTasks = _teamTasks.where((t) => t.isCompleted).length;
    final teamMembers = _team?.memberCount ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Team Performance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Stats Overview
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Projects',
                  '$completedProjects/$totalProjects',
                  Icons.folder,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Tasks',
                  '$completedTasks/$totalTasks',
                  Icons.task_alt,
                  AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Members',
                  '$teamMembers',
                  Icons.group,
                  AppColors.danger,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Progress',
                  '${((completedTasks / (totalTasks > 0 ? totalTasks : 1)) * 100).toInt()}%',
                  Icons.analytics,
                  AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Progress Charts
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...(_teamProjects.isEmpty
                      ? [
                          const Text(
                            'No projects to analyze',
                            style: TextStyle(color: AppColors.textSecondary),
                          )
                        ]
                      : _teamProjects.map((project) => _buildProjectProgress(project))),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Team Activity
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActivityItem(
                    Icons.assignment_turned_in,
                    'Task completed',
                    '2 hours ago',
                    AppColors.success,
                  ),
                  _buildActivityItem(
                    Icons.person_add,
                    'New member joined',
                    '1 day ago',
                    AppColors.warning,
                  ),
                  _buildActivityItem(
                    Icons.folder_open,
                    'Project created',
                    '3 days ago',
                    AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    final progress = project.totalTasks > 0 
        ? (project.taskIds.length / project.totalTasks) 
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: InkWell(
          onTap: () => _openProject(project),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.purpleGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.folder,
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
                            project.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            project.statusLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(project.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  project.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${project.taskIds.length} tasks',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (project.dueDate != null) ...[
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: project.isOverdue ? AppColors.danger : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(project.dueDate!),
                        style: TextStyle(
                          fontSize: 12,
                          color: project.isOverdue ? AppColors.danger : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: InkWell(
          onTap: () => _openTask(task),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted ? AppColors.success : AppColors.textSecondary,
                      width: 2,
                    ),
                    color: task.isCompleted ? AppColors.success : Colors.transparent,
                  ),
                  child: task.isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                      if (task.assignedTo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Assigned to: ${task.assignedTo}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.priorityLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _getPriorityColor(task.priority),
                    ),
                  ),
                ),
                if (task.dueDate != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(task.dueDate!),
                    style: TextStyle(
                      fontSize: 12,
                      color: task.isOverdue ? AppColors.danger : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectProgress(Project project) {
    final progress = project.totalTasks > 0 
        ? (project.taskIds.length / project.totalTasks) 
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                project.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.cardBackground,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle, VoidCallback onPressed) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text(title.contains('Project') ? 'Create Project' : 'Create Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder_open, color: AppColors.success),
              title: const Text(
                'Create Project',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Start a new team project',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              onTap: () {
                Navigator.pop(context);
                _createProject();
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment, color: AppColors.warning),
              title: const Text(
                'Create Task',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Assign a task to team members',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              onTap: () {
                Navigator.pop(context);
                _createTask();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createProject() {
    // TODO: Navigate to create project screen with team context
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create project functionality coming soon!')),
    );
  }

  void _createTask() {
    // TODO: Navigate to create task screen with team context
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create task functionality coming soon!')),
    );
  }

  void _openProject(Project project) {
    // TODO: Navigate to project details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening project: ${project.name}')),
    );
  }

  void _openTask(Task task) {
    // TODO: Navigate to task details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening task: ${task.title}')),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'active':
        return AppColors.warning;
      case 'on_hold':
        return AppColors.textSecondary;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.danger;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 0) return '${difference}d left';
    return '${-difference}d ago';
  }
}
