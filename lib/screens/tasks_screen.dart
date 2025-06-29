import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task/task_card.dart';
import '../widgets/common/glass_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final activeTasks = taskProvider.tasks.where((task) => 
          task.status == 'pending' || task.status == 'in_progress').toList();
        
        final completedTasks = taskProvider.tasks.where((task) => 
          task.status == 'completed').toList();
        
        final highPriorityTasks = taskProvider.tasks.where((task) => 
          task.priority == 'high' && task.status != 'completed').toList();
        
        final overdueTasks = taskProvider.tasks.where((task) => 
          task.dueDate != null && 
          task.dueDate!.isBefore(DateTime.now()) && 
          task.status != 'completed').toList();

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
                      colors: AppColors.tealGradient,
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
                            'Tasks',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingSm),
                          Row(
                            children: [
                              _buildStatChip('${activeTasks.length} Active', Icons.pending),
                              const SizedBox(width: AppSizes.paddingSm),
                              _buildStatChip('${completedTasks.length} Done', Icons.check_circle),
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
                    // Add new task
                    _showAddTaskDialog();
                  },
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            Container(
              color: AppColors.cardBackground,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.tealGradient.first,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'High Priority'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Overdue'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTaskList(taskProvider.tasks, 'No tasks found'),
                  _buildTaskList(highPriorityTasks, 'No high priority tasks'),
                  _buildTaskList(completedTasks, 'No completed tasks'),
                  _buildTaskList(overdueTasks, 'No overdue tasks'),
                ],
              ),
            ),
          ],
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

  Widget _buildTaskList(List<Task> tasks, String emptyMessage) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: AppConstants.mediumAnimation,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: TaskCard(
                  task: task,
                  onTap: () => _showTaskDetails(task),
                  onToggleComplete: () => _toggleTaskCompletion(task),
                  onEdit: () => _editTask(task),
                  onDelete: () => _deleteTask(task),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTaskDetails(Task task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        margin: const EdgeInsets.all(AppSizes.paddingMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingSm),
              Text(
                task.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingMd),
              Row(
                children: [
                  Chip(
                    label: Text(task.priority.toUpperCase()),
                    backgroundColor: _getPriorityColor(task.priority),
                  ),
                  const SizedBox(width: AppSizes.paddingSm),
                  Chip(
                    label: Text('${task.xpReward} XP'),
                    backgroundColor: AppColors.tealGradient.first,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleTaskCompletion(Task task) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final success = await taskProvider.toggleTaskCompletion(task.id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
              ? task.isCompleted 
                ? 'Task marked as pending'
                : 'Task completed! +${task.xpReward} XP'
              : 'Failed to update task',
          ),
          backgroundColor: success ? 
            (task.isCompleted ? AppColors.warning : AppColors.success) : 
            AppColors.danger,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _editTask(Task task) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit task functionality coming soon!')),
    );
  }

  void _deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Task', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${task.title}"?',
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
                const SnackBar(content: Text('Task deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Add New Task', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Task creation functionality coming soon!',
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

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.highPriority;
      case 'medium':
        return AppColors.mediumPriority;
      case 'low':
        return AppColors.lowPriority;
      default:
        return AppColors.textSecondary;
    }
  }
}
