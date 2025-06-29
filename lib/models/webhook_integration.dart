class WebhookIntegration {
  final String id;
  final String name;
  final String webhookUrl;
  final String? description;
  final bool isActive;
  final List<String> eventTypes;
  final Map<String, String> headers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastTriggered;
  final int successCount;
  final int failureCount;

  WebhookIntegration({
    required this.id,
    required this.name,
    required this.webhookUrl,
    this.description,
    this.isActive = true,
    this.eventTypes = const [],
    this.headers = const {},
    required this.createdAt,
    required this.updatedAt,
    this.lastTriggered,
    this.successCount = 0,
    this.failureCount = 0,
  });

  double get successRate {
    final total = successCount + failureCount;
    if (total == 0) return 0.0;
    return successCount / total;
  }

  String get statusText {
    if (!isActive) return 'Inactive';
    if (lastTriggered == null) return 'Never triggered';
    return 'Active';
  }

  factory WebhookIntegration.fromJson(Map<String, dynamic> json) {
    return WebhookIntegration(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      webhookUrl: json['webhook_url'] ?? '',
      description: json['description'],
      isActive: json['is_active'] ?? true,
      eventTypes: List<String>.from(json['event_types'] ?? []),
      headers: Map<String, String>.from(json['headers'] ?? {}),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      lastTriggered: json['last_triggered'] != null
          ? DateTime.parse(json['last_triggered'])
          : null,
      successCount: json['success_count'] ?? 0,
      failureCount: json['failure_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'webhook_url': webhookUrl,
      'description': description,
      'is_active': isActive,
      'event_types': eventTypes,
      'headers': headers,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_triggered': lastTriggered?.toIso8601String(),
      'success_count': successCount,
      'failure_count': failureCount,
    };
  }

  WebhookIntegration copyWith({
    String? id,
    String? name,
    String? webhookUrl,
    String? description,
    bool? isActive,
    List<String>? eventTypes,
    Map<String, String>? headers,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastTriggered,
    int? successCount,
    int? failureCount,
  }) {
    return WebhookIntegration(
      id: id ?? this.id,
      name: name ?? this.name,
      webhookUrl: webhookUrl ?? this.webhookUrl,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      eventTypes: eventTypes ?? this.eventTypes,
      headers: headers ?? this.headers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebhookIntegration && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WebhookIntegration(id: $id, name: $name, isActive: $isActive)';
  }
}

// Webhook event types
class WebhookEventTypes {
  static const String taskCreated = 'task.created';
  static const String taskUpdated = 'task.updated';
  static const String taskCompleted = 'task.completed';
  static const String taskDeleted = 'task.deleted';
  static const String projectCreated = 'project.created';
  static const String projectUpdated = 'project.updated';
  static const String projectCompleted = 'project.completed';
  static const String achievementEarned = 'achievement.earned';
  static const String levelUp = 'user.level_up';
  static const String streakMilestone = 'user.streak_milestone';

  static const List<String> allEventTypes = [
    taskCreated,
    taskUpdated,
    taskCompleted,
    taskDeleted,
    projectCreated,
    projectUpdated,
    projectCompleted,
    achievementEarned,
    levelUp,
    streakMilestone,
  ];

  static String getEventTypeLabel(String eventType) {
    switch (eventType) {
      case taskCreated:
        return 'Task Created';
      case taskUpdated:
        return 'Task Updated';
      case taskCompleted:
        return 'Task Completed';
      case taskDeleted:
        return 'Task Deleted';
      case projectCreated:
        return 'Project Created';
      case projectUpdated:
        return 'Project Updated';
      case projectCompleted:
        return 'Project Completed';
      case achievementEarned:
        return 'Achievement Earned';
      case levelUp:
        return 'Level Up';
      case streakMilestone:
        return 'Streak Milestone';
      default:
        return eventType;
    }
  }

  static String getEventTypeDescription(String eventType) {
    switch (eventType) {
      case taskCreated:
        return 'Triggered when a new task is created';
      case taskUpdated:
        return 'Triggered when a task is updated';
      case taskCompleted:
        return 'Triggered when a task is completed';
      case taskDeleted:
        return 'Triggered when a task is deleted';
      case projectCreated:
        return 'Triggered when a new project is created';
      case projectUpdated:
        return 'Triggered when a project is updated';
      case projectCompleted:
        return 'Triggered when a project is completed';
      case achievementEarned:
        return 'Triggered when an achievement is earned';
      case levelUp:
        return 'Triggered when user levels up';
      case streakMilestone:
        return 'Triggered when user reaches a streak milestone';
      default:
        return 'Custom event type';
    }
  }
}

// Webhook request model
class WebhookRequest {
  final String name;
  final String webhookUrl;
  final String? description;
  final bool isActive;
  final List<String> eventTypes;
  final Map<String, String> headers;

  WebhookRequest({
    required this.name,
    required this.webhookUrl,
    this.description,
    this.isActive = true,
    this.eventTypes = const [],
    this.headers = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'webhook_url': webhookUrl,
      'description': description,
      'is_active': isActive,
      'event_types': eventTypes,
      'headers': headers,
    };
  }

  factory WebhookRequest.fromWebhook(WebhookIntegration webhook) {
    return WebhookRequest(
      name: webhook.name,
      webhookUrl: webhook.webhookUrl,
      description: webhook.description,
      isActive: webhook.isActive,
      eventTypes: webhook.eventTypes,
      headers: webhook.headers,
    );
  }
}

// Webhook log entry
class WebhookLog {
  final String id;
  final String webhookId;
  final String eventType;
  final int statusCode;
  final String? responseBody;
  final String? errorMessage;
  final DateTime timestamp;
  final Map<String, dynamic> payload;

  WebhookLog({
    required this.id,
    required this.webhookId,
    required this.eventType,
    required this.statusCode,
    this.responseBody,
    this.errorMessage,
    required this.timestamp,
    required this.payload,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isError => statusCode >= 400;

  String get statusText {
    if (isSuccess) return 'Success';
    if (isError) return 'Error';
    return 'Unknown';
  }

  factory WebhookLog.fromJson(Map<String, dynamic> json) {
    return WebhookLog(
      id: json['id']?.toString() ?? '',
      webhookId: json['webhook_id']?.toString() ?? '',
      eventType: json['event_type'] ?? '',
      statusCode: json['status_code'] ?? 0,
      responseBody: json['response_body'],
      errorMessage: json['error_message'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      payload: json['payload'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'webhook_id': webhookId,
      'event_type': eventType,
      'status_code': statusCode,
      'response_body': responseBody,
      'error_message': errorMessage,
      'timestamp': timestamp.toIso8601String(),
      'payload': payload,
    };
  }
}
