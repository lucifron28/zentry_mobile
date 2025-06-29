class Project {
  final String id;
  final String name;
  final String description;
  final String status;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final String userId;
  final List<String> memberIds;
  final List<String> taskIds;
  final Map<String, dynamic>? metadata;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    this.color,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.completedAt,
    required this.userId,
    this.memberIds = const [],
    this.taskIds = const [],
    this.metadata,
  });

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isActive => status.toLowerCase() == 'active';
  bool get isOnHold => status.toLowerCase() == 'on_hold';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  
  bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now()) && !isCompleted;
  
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'on_hold':
        return 'On Hold';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  int get totalTasks => taskIds.length;
  int get totalMembers => memberIds.length;

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'active',
      color: json['color'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      userId: json['user_id']?.toString() ?? '',
      memberIds: List<String>.from(json['member_ids'] ?? []),
      taskIds: List<String>.from(json['task_ids'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'user_id': userId,
      'member_ids': memberIds,
      'task_ids': taskIds,
      'metadata': metadata,
    };
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? status,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    DateTime? completedAt,
    String? userId,
    List<String>? memberIds,
    List<String>? taskIds,
    Map<String, dynamic>? metadata,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      userId: userId ?? this.userId,
      memberIds: memberIds ?? this.memberIds,
      taskIds: taskIds ?? this.taskIds,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Project(id: $id, name: $name, status: $status)';
  }
}

// Project statistics
class ProjectStats {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final double completionRate;
  final List<Map<String, dynamic>> memberContributions;
  final Map<String, int> tasksByPriority;
  final List<Map<String, dynamic>> progressHistory;

  ProjectStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.completionRate,
    required this.memberContributions,
    required this.tasksByPriority,
    required this.progressHistory,
  });

  factory ProjectStats.fromJson(Map<String, dynamic> json) {
    return ProjectStats(
      totalTasks: json['total_tasks'] ?? 0,
      completedTasks: json['completed_tasks'] ?? 0,
      pendingTasks: json['pending_tasks'] ?? 0,
      overdueTasks: json['overdue_tasks'] ?? 0,
      completionRate: (json['completion_rate'] ?? 0.0).toDouble(),
      memberContributions: List<Map<String, dynamic>>.from(
        json['member_contributions'] ?? [],
      ),
      tasksByPriority: Map<String, int>.from(json['tasks_by_priority'] ?? {}),
      progressHistory: List<Map<String, dynamic>>.from(
        json['progress_history'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_tasks': totalTasks,
      'completed_tasks': completedTasks,
      'pending_tasks': pendingTasks,
      'overdue_tasks': overdueTasks,
      'completion_rate': completionRate,
      'member_contributions': memberContributions,
      'tasks_by_priority': tasksByPriority,
      'progress_history': progressHistory,
    };
  }
}

// Project creation/update request
class ProjectRequest {
  final String name;
  final String description;
  final String? color;
  final DateTime? dueDate;
  final List<String> memberIds;

  ProjectRequest({
    required this.name,
    required this.description,
    this.color,
    this.dueDate,
    this.memberIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'color': color,
      'due_date': dueDate?.toIso8601String(),
      'member_ids': memberIds,
    };
  }

  factory ProjectRequest.fromProject(Project project) {
    return ProjectRequest(
      name: project.name,
      description: project.description,
      color: project.color,
      dueDate: project.dueDate,
      memberIds: project.memberIds,
    );
  }
}

// Project filter
class ProjectFilter {
  final String? status;
  final String? userId;
  final DateTime? dueDateFrom;
  final DateTime? dueDateTo;
  final bool? isOverdue;

  ProjectFilter({
    this.status,
    this.userId,
    this.dueDateFrom,
    this.dueDateTo,
    this.isOverdue,
  });

  bool get hasFilters {
    return status != null ||
        userId != null ||
        dueDateFrom != null ||
        dueDateTo != null ||
        isOverdue != null;
  }

  ProjectFilter copyWith({
    String? status,
    String? userId,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
    bool? isOverdue,
  }) {
    return ProjectFilter(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      dueDateFrom: dueDateFrom ?? this.dueDateFrom,
      dueDateTo: dueDateTo ?? this.dueDateTo,
      isOverdue: isOverdue ?? this.isOverdue,
    );
  }

  ProjectFilter clear() {
    return ProjectFilter();
  }
}

// Project member
class ProjectMember {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String role;
  final DateTime joinedAt;
  final int tasksCompleted;
  final int totalTasks;

  ProjectMember({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.role,
    required this.joinedAt,
    required this.tasksCompleted,
    required this.totalTasks,
  });

  double get completionRate {
    if (totalTasks == 0) return 0.0;
    return tasksCompleted / totalTasks;
  }

  String get roleLabel {
    switch (role.toLowerCase()) {
      case 'owner':
        return 'Owner';
      case 'admin':
        return 'Admin';
      case 'member':
        return 'Member';
      case 'viewer':
        return 'Viewer';
      default:
        return 'Unknown';
    }
  }

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      role: json['role'] ?? 'member',
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'])
          : DateTime.now(),
      tasksCompleted: json['tasks_completed'] ?? 0,
      totalTasks: json['total_tasks'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      'tasks_completed': tasksCompleted,
      'total_tasks': totalTasks,
    };
  }
}
