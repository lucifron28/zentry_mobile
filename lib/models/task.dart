class Task {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final String? category;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final String userId;
  final String? projectId;
  final String? assignedTo;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final int xpReward;
  final bool isRecurring;
  final String? recurringPattern;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.category,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    required this.userId,
    this.projectId,
    this.assignedTo,
    this.tags = const [],
    this.metadata,
    required this.xpReward,
    this.isRecurring = false,
    this.recurringPattern,
  });

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now()) && !isCompleted;
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDueDate = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return today.isAtSameMomentAs(taskDueDate);
  }
  
  bool get isDueSoon {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final difference = dueDate!.difference(now);
    return difference.inDays <= 3 && difference.inDays >= 0;
  }

  String get priorityLabel {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return 'Unknown';
    }
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'low',
      status: json['status'] ?? 'pending',
      category: json['category'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      userId: json['user_id']?.toString() ?? '',
      projectId: json['project_id']?.toString(),
      assignedTo: json['assigned_to']?.toString(),
      tags: List<String>.from(json['tags'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
      xpReward: json['xp_reward'] ?? 0,
      isRecurring: json['is_recurring'] ?? false,
      recurringPattern: json['recurring_pattern'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'category': category,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'user_id': userId,
      'project_id': projectId,
      'assigned_to': assignedTo,
      'tags': tags,
      'metadata': metadata,
      'xp_reward': xpReward,
      'is_recurring': isRecurring,
      'recurring_pattern': recurringPattern,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    String? status,
    String? category,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    String? userId,
    String? projectId,
    String? assignedTo,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    int? xpReward,
    bool? isRecurring,
    String? recurringPattern,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      assignedTo: assignedTo ?? this.assignedTo,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      xpReward: xpReward ?? this.xpReward,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status, priority: $priority)';
  }
}

// Task filter model
class TaskFilter {
  final String? status;
  final String? priority;
  final String? category;
  final String? projectId;
  final String? assignedTo;
  final DateTime? dueDateFrom;
  final DateTime? dueDateTo;
  final bool? isOverdue;
  final bool? isDueToday;
  final List<String> tags;

  TaskFilter({
    this.status,
    this.priority,
    this.category,
    this.projectId,
    this.assignedTo,
    this.dueDateFrom,
    this.dueDateTo,
    this.isOverdue,
    this.isDueToday,
    this.tags = const [],
  });

  bool get hasFilters {
    return status != null ||
        priority != null ||
        category != null ||
        projectId != null ||
        assignedTo != null ||
        dueDateFrom != null ||
        dueDateTo != null ||
        isOverdue != null ||
        isDueToday != null ||
        tags.isNotEmpty;
  }

  TaskFilter copyWith({
    String? status,
    String? priority,
    String? category,
    String? projectId,
    String? assignedTo,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
    bool? isOverdue,
    bool? isDueToday,
    List<String>? tags,
  }) {
    return TaskFilter(
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      projectId: projectId ?? this.projectId,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDateFrom: dueDateFrom ?? this.dueDateFrom,
      dueDateTo: dueDateTo ?? this.dueDateTo,
      isOverdue: isOverdue ?? this.isOverdue,
      isDueToday: isDueToday ?? this.isDueToday,
      tags: tags ?? this.tags,
    );
  }

  TaskFilter clear() {
    return TaskFilter();
  }
}

// Task sort options
enum TaskSortOption {
  dateCreated,
  dueDate,
  priority,
  title,
  status,
}

// Task creation/update request model
class TaskRequest {
  final String title;
  final String description;
  final String priority;
  final String? category;
  final DateTime? dueDate;
  final String? projectId;
  final String? assignedTo;
  final List<String> tags;
  final bool isRecurring;
  final String? recurringPattern;

  TaskRequest({
    required this.title,
    required this.description,
    required this.priority,
    this.category,
    this.dueDate,
    this.projectId,
    this.assignedTo,
    this.tags = const [],
    this.isRecurring = false,
    this.recurringPattern,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'category': category,
      'due_date': dueDate?.toIso8601String(),
      'project_id': projectId,
      'assigned_to': assignedTo,
      'tags': tags,
      'is_recurring': isRecurring,
      'recurring_pattern': recurringPattern,
    };
  }

  factory TaskRequest.fromTask(Task task) {
    return TaskRequest(
      title: task.title,
      description: task.description,
      priority: task.priority,
      category: task.category,
      dueDate: task.dueDate,
      projectId: task.projectId,
      assignedTo: task.assignedTo,
      tags: task.tags,
      isRecurring: task.isRecurring,
      recurringPattern: task.recurringPattern,
    );
  }
}
