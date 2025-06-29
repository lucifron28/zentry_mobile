import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/project.dart';
import '../../utils/constants.dart';
import '../common/glass_card.dart';
import '../common/progress_bar.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(project.status);
    final progress = project.taskIds.isEmpty ? 0.0 : 0.6; // Mock progress for now

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Project icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getProjectGradient(project.color ?? 'purple'),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: const Icon(
                      Icons.folder,
                      color: Colors.white,
                      size: AppSizes.iconMd,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMd),
                  
                  // Project info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (project.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            project.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Actions menu
                  if (showActions)
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
              ),
              
              const SizedBox(height: AppSizes.paddingMd),
              
              // Progress bar
              ProgressBar(
                progress: progress,
                height: 8,
                gradientColors: _getProjectGradient(project.color ?? 'purple'),
                backgroundColor: AppColors.border,
                showLabel: true,
                label: 'Progress',
              ),
              
              const SizedBox(height: AppSizes.paddingMd),
              
              // Project stats
              Row(
                children: [
                  // Tasks count
                  _buildStatChip(
                    icon: Icons.task_alt,
                    label: '${project.taskIds.length} tasks',
                    color: AppColors.tealGradient.first,
                  ),
                  const SizedBox(width: AppSizes.paddingSm),
                  
                  // Status
                  _buildStatChip(
                    icon: _getStatusIcon(project.status),
                    label: project.status.toUpperCase(),
                    color: statusColor,
                  ),
                  
                  const Spacer(),
                  
                  // Due date (if exists)
                  if (project.dueDate != null) ...[
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: _getDueDateColor(project.dueDate!),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDueDate(project.dueDate!),
                      style: TextStyle(
                        color: _getDueDateColor(project.dueDate!),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'on_hold':
        return AppColors.warning;
      case 'completed':
        return AppColors.tealGradient.first;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.play_arrow;
      case 'on_hold':
        return Icons.pause;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.circle;
    }
  }

  List<Color> _getProjectGradient(String color) {
    switch (color.toLowerCase()) {
      case 'blue':
        return AppColors.blueGradient;
      case 'purple':
        return AppColors.purpleGradient;
      case 'teal':
        return AppColors.tealGradient;
      case 'green':
        return AppColors.greenGradient;
      case 'yellow':
        return AppColors.yellowGradient;
      case 'red':
        return AppColors.redGradient;
      default:
        return AppColors.purpleGradient;
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

class ProjectGrid extends StatelessWidget {
  final List<Project> projects;
  final Function(Project) onProjectTap;
  final Function(Project) onEditProject;
  final Function(Project) onDeleteProject;
  final bool showActions;
  final String? emptyMessage;

  const ProjectGrid({
    super.key,
    required this.projects,
    required this.onProjectTap,
    required this.onEditProject,
    required this.onDeleteProject,
    this.showActions = true,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSizes.paddingMd),
            Text(
              emptyMessage ?? 'No projects found',
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 2.5,
          crossAxisSpacing: AppSizes.paddingMd,
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
                  onTap: () => onProjectTap(project),
                  onEdit: () => onEditProject(project),
                  onDelete: () => onDeleteProject(project),
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

class ProjectOverviewCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const ProjectOverviewCard({
    super.key,
    required this.project,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = project.taskIds.isEmpty ? 0.0 : 0.6; // Mock progress for now

    return GlassCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getProjectGradient(project.color ?? 'purple'),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: const Icon(
                      Icons.folder,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingSm),
                  Expanded(
                    child: Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingSm),
              ProgressBar(
                progress: progress,
                height: 4,
                gradientColors: _getProjectGradient(project.color ?? 'purple'),
                backgroundColor: AppColors.border,
              ),
              const SizedBox(height: AppSizes.paddingSm),
              Text(
                '${project.taskIds.length} tasks',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getProjectGradient(String color) {
    switch (color.toLowerCase()) {
      case 'blue':
        return AppColors.blueGradient;
      case 'purple':
        return AppColors.purpleGradient;
      case 'teal':
        return AppColors.tealGradient;
      case 'green':
        return AppColors.greenGradient;
      case 'yellow':
        return AppColors.yellowGradient;
      case 'red':
        return AppColors.redGradient;
      default:
        return AppColors.purpleGradient;
    }
  }
}
