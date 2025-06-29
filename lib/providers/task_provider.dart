import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  TaskFilter _currentFilter = TaskFilter();
  TaskSortOption _sortOption = TaskSortOption.dateCreated;
  bool _sortAscending = false;
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _filteredTasks;
  List<Task> get allTasks => _tasks;
  TaskFilter get currentFilter => _currentFilter;
  TaskSortOption get sortOption => _sortOption;
  bool get sortAscending => _sortAscending;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters for filtered task counts
  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get pendingTasks => _tasks.where((task) => task.isPending).length;
  int get inProgressTasks => _tasks.where((task) => task.isInProgress).length;
  int get overdueTasks => _tasks.where((task) => task.isOverdue).length;
  int get dueTodayTasks => _tasks.where((task) => task.isDueToday).length;
  int get dueSoonTasks => _tasks.where((task) => task.isDueSoon).length;

  // Getters for priority counts
  int get highPriorityTasks => _tasks.where((task) => task.priority == 'high').length;
  int get mediumPriorityTasks => _tasks.where((task) => task.priority == 'medium').length;
  int get lowPriorityTasks => _tasks.where((task) => task.priority == 'low').length;

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getTasks();
      
      if (response['success'] == true) {
        _tasks = (response['tasks'] as List)
            .map((taskData) => Task.fromJson(taskData))
            .toList();
        
        _applyFiltersAndSort();
        _setLoading(false);
      } else {
        _error = response['message'] ?? 'Failed to load tasks';
        _setLoading(false);
      }
    } catch (e) {
      _error = 'Failed to load tasks: $e';
      _setLoading(false);
    }
  }

  Future<bool> createTask(TaskRequest taskRequest) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.createTask(taskRequest);
      
      if (response['success'] == true) {
        final newTask = Task.fromJson(response['task']);
        _tasks.add(newTask);
        _applyFiltersAndSort();
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to create task';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Failed to create task: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateTask(String taskId, TaskRequest taskRequest) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.updateTask(taskId, taskRequest);
      
      if (response['success'] == true) {
        final updatedTask = Task.fromJson(response['task']);
        final index = _tasks.indexWhere((task) => task.id == taskId);
        
        if (index != -1) {
          _tasks[index] = updatedTask;
          _applyFiltersAndSort();
        }
        
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update task';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Failed to update task: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.deleteTask(taskId);
      
      if (response['success'] == true) {
        _tasks.removeWhere((task) => task.id == taskId);
        _applyFiltersAndSort();
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to delete task';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Failed to delete task: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> completeTask(String taskId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.completeTask(taskId);
      
      if (response['success'] == true) {
        final updatedTask = Task.fromJson(response['task']);
        final index = _tasks.indexWhere((task) => task.id == taskId);
        
        if (index != -1) {
          _tasks[index] = updatedTask;
          _applyFiltersAndSort();
        }
        
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to complete task';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Failed to complete task: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateTaskStatus(String taskId, String status) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.updateTaskStatus(taskId, status);
      
      if (response['success'] == true) {
        final updatedTask = Task.fromJson(response['task']);
        final index = _tasks.indexWhere((task) => task.id == taskId);
        
        if (index != -1) {
          _tasks[index] = updatedTask;
          _applyFiltersAndSort();
        }
        
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update task status';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Failed to update task status: $e';
      _setLoading(false);
      return false;
    }
  }

  void applyFilter(TaskFilter filter) {
    _currentFilter = filter;
    _applyFiltersAndSort();
  }

  void clearFilter() {
    _currentFilter = TaskFilter();
    _applyFiltersAndSort();
  }

  void setSortOption(TaskSortOption option, {bool? ascending}) {
    _sortOption = option;
    if (ascending != null) {
      _sortAscending = ascending;
    }
    _applyFiltersAndSort();
  }

  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    // Apply filters
    _filteredTasks = _tasks.where((task) {
      if (_currentFilter.status != null && task.status != _currentFilter.status) {
        return false;
      }
      
      if (_currentFilter.priority != null && task.priority != _currentFilter.priority) {
        return false;
      }
      
      if (_currentFilter.category != null && task.category != _currentFilter.category) {
        return false;
      }
      
      if (_currentFilter.projectId != null && task.projectId != _currentFilter.projectId) {
        return false;
      }
      
      if (_currentFilter.assignedTo != null && task.assignedTo != _currentFilter.assignedTo) {
        return false;
      }
      
      if (_currentFilter.dueDateFrom != null && task.dueDate != null) {
        if (task.dueDate!.isBefore(_currentFilter.dueDateFrom!)) {
          return false;
        }
      }
      
      if (_currentFilter.dueDateTo != null && task.dueDate != null) {
        if (task.dueDate!.isAfter(_currentFilter.dueDateTo!)) {
          return false;
        }
      }
      
      if (_currentFilter.isOverdue == true && !task.isOverdue) {
        return false;
      }
      
      if (_currentFilter.isDueToday == true && !task.isDueToday) {
        return false;
      }
      
      if (_currentFilter.tags.isNotEmpty) {
        final hasMatchingTag = _currentFilter.tags.any((tag) => task.tags.contains(tag));
        if (!hasMatchingTag) {
          return false;
        }
      }
      
      return true;
    }).toList();

    // Apply sorting
    _filteredTasks.sort((a, b) {
      int comparison = 0;
      
      switch (_sortOption) {
        case TaskSortOption.dateCreated:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case TaskSortOption.dueDate:
          if (a.dueDate == null && b.dueDate == null) {
            comparison = 0;
          } else if (a.dueDate == null) {
            comparison = 1;
          } else if (b.dueDate == null) {
            comparison = -1;
          } else {
            comparison = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case TaskSortOption.priority:
          final priorityOrder = {'high': 3, 'medium': 2, 'low': 1};
          final aPriority = priorityOrder[a.priority] ?? 0;
          final bPriority = priorityOrder[b.priority] ?? 0;
          comparison = aPriority.compareTo(bPriority);
          break;
        case TaskSortOption.title:
          comparison = a.title.compareTo(b.title);
          break;
        case TaskSortOption.status:
          comparison = a.status.compareTo(b.status);
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });

    notifyListeners();
  }

  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  List<Task> getTasksByProject(String projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  List<Task> getTasksByStatus(String status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  List<Task> getTasksByPriority(String priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  List<Task> getOverdueTasks() {
    return _tasks.where((task) => task.isOverdue).toList();
  }

  List<Task> getDueTodayTasks() {
    return _tasks.where((task) => task.isDueToday).toList();
  }

  List<Task> getDueSoonTasks() {
    return _tasks.where((task) => task.isDueSoon).toList();
  }

  List<Task> getRecentTasks({int limit = 10}) {
    final sortedTasks = List<Task>.from(_tasks);
    sortedTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedTasks.take(limit).toList();
  }

  List<Task> getRecentlyCompletedTasks({int limit = 10}) {
    final completedTasks = _tasks.where((task) => task.isCompleted).toList();
    completedTasks.sort((a, b) => (b.completedAt ?? b.updatedAt).compareTo(a.completedAt ?? a.updatedAt));
    return completedTasks.take(limit).toList();
  }

  Map<String, int> getTaskCountsByCategory() {
    final counts = <String, int>{};
    for (final task in _tasks) {
      final category = task.category ?? 'Uncategorized';
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> getTaskCountsByPriority() {
    final counts = <String, int>{};
    for (final task in _tasks) {
      counts[task.priority] = (counts[task.priority] ?? 0) + 1;
    }
    return counts;
  }

  double getCompletionRate() {
    if (_tasks.isEmpty) return 0.0;
    return completedTasks / totalTasks;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
