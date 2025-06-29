import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/task.dart';
import '../../utils/constants.dart';
import '../common/glass_card.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleComplete,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);
    final isCompleted = task.status == AppConstants.completedStatus;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Row(
            children: [
              // Completion checkbox
              GestureDetector(
                onTap: onToggleComplete,
                child: AnimatedContainer(
                  duration: AppConstants.shortAnimation,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.success : Colors.transparent,
                    border: Border.all(
                      color: isCompleted ? AppColors.success : priorityColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: AppSizes.paddingMd),
              
              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isCompleted
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSizes.paddingSm),
                    Row(
                      children: [
                        // Priority indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                          ),
                          child: Text(
                            task.priority.toUpperCase(),
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // XP reward
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.tealGradient,
                            ),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                          ),
                          child: Text(
                            '${task.xpReward} XP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: _getDueDateColor(task.dueDate!),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDueDate(task.dueDate!),
                            style: TextStyle(
                              color: _getDueDateColor(task.dueDate!),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Actions
              if (showActions) ...[
                const SizedBox(width: AppSizes.paddingSm),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  color: AppColors.cardBackground,
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16, color: AppColors.textSecondary),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: AppColors.danger),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppColors.danger)),
                        ],
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

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case AppConstants.highPriority:
        return AppColors.highPriority;
      case AppConstants.mediumPriority:
        return AppColors.mediumPriority;
      case AppConstants.lowPriority:
        return AppColors.lowPriority;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) {
      return AppColors.danger; // Overdue
    } else if (difference == 0) {
      return AppColors.warning; // Due today
    } else if (difference <= 3) {
      return AppColors.warning; // Due soon
    } else {
      return AppColors.textSecondary; // Normal
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference <= 7) {
      return 'Due in $difference days';
    } else {
      return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
    }
  }
}

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onTaskTap;
  final Function(Task) onToggleComplete;
  final Function(Task) onEditTask;
  final Function(Task) onDeleteTask;
  final bool showActions;
  final String? emptyMessage;

  const TaskList({
    super.key,
    required this.tasks,
    required this.onTaskTap,
    required this.onToggleComplete,
    required this.onEditTask,
    required this.onDeleteTask,
    this.showActions = true,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.paddingMd),
            Text(
              emptyMessage ?? 'No tasks found',
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
                  onTap: () => onTaskTap(task),
                  onToggleComplete: () => onToggleComplete(task),
                  onEdit: () => onEditTask(task),
                  onDelete: () => onDeleteTask(task),
                  showActions: showActions,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
