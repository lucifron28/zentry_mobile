import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../models/project.dart';
import '../models/webhook_integration.dart';
import '../utils/constants.dart';

class ApiService {
  static const String _baseUrl = AppConstants.baseUrl;
  String? _token;
  
  void setToken(String token) {
    _token = token;
  }
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // Task endpoints
  Future<Map<String, dynamic>> getTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tasks'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'tasks': data['tasks'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load tasks',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> createTask(TaskRequest taskRequest) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/tasks'),
        headers: _headers,
        body: jsonEncode(taskRequest.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'task': data['task'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create task',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateTask(String taskId, TaskRequest taskRequest) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/tasks/$taskId'),
        headers: _headers,
        body: jsonEncode(taskRequest.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'task': data['task'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update task',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> deleteTask(String taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/tasks/$taskId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete task',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> completeTask(String taskId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/tasks/$taskId/complete'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'task': data['task'],
          'xp_gained': data['xp_gained'] ?? 0,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to complete task',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateTaskStatus(String taskId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/tasks/$taskId/status'),
        headers: _headers,
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'task': data['task'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update task status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Project endpoints
  Future<Map<String, dynamic>> getProjects() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/projects'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'projects': data['projects'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load projects',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> createProject(ProjectRequest projectRequest) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/projects'),
        headers: _headers,
        body: jsonEncode(projectRequest.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'project': data['project'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create project',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateProject(String projectId, ProjectRequest projectRequest) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/projects/$projectId'),
        headers: _headers,
        body: jsonEncode(projectRequest.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'project': data['project'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update project',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> deleteProject(String projectId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/projects/$projectId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete project',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Achievement endpoints
  Future<Map<String, dynamic>> getAchievements() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/achievements'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'achievements': data['achievements'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load achievements',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> claimAchievement(int achievementId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/achievements/$achievementId/claim'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'achievement': data['achievement'],
          'xp_gained': data['xp_gained'] ?? 0,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to claim achievement',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getAchievementStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/achievements/stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'stats': data['stats'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load achievement stats',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Notification endpoints
  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'notifications': data['notifications'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load notifications',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> markNotificationAsRead(String notificationId) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/notifications/$notificationId/read'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to mark notification as read',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/notifications/read-all'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to mark all notifications as read',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // User stats endpoint
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'stats': data['stats'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load user stats',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Webhook endpoints
  Future<Map<String, dynamic>> getWebhooks() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/webhooks'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'webhooks': data['webhooks'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load webhooks',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> createWebhook(WebhookRequest webhookRequest) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/webhooks'),
        headers: _headers,
        body: jsonEncode(webhookRequest.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'webhook': data['webhook'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create webhook',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateWebhook(String webhookId, WebhookRequest webhookRequest) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/webhooks/$webhookId'),
        headers: _headers,
        body: jsonEncode(webhookRequest.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'webhook': data['webhook'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update webhook',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> deleteWebhook(String webhookId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/webhooks/$webhookId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete webhook',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}
