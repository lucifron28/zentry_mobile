import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../services/api_service.dart';

class ProjectProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Project> _projects = [];
  List<Project> _filteredProjects = [];
  ProjectFilter _currentFilter = ProjectFilter();
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => _filteredProjects;
  List<Project> get allProjects => _projects;
  ProjectFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters for project counts
  int get totalProjects => _projects.length;
  int get activeProjects => _projects.where((p) => p.isActive).length;
  int get completedProjects => _projects.where((p) => p.isCompleted).length;
  int get onHoldProjects => _projects.where((p) => p.isOnHold).length;
  int get cancelledProjects => _projects.where((p) => p.isCancelled).length;
  int get overdueProjects => _projects.where((p) => p.isOverdue).length;

  Future<void> init() async {
    await loadProjects();
  }

  ProjectProvider() {
    // loadProjects();
  }

  Future<void> loadProjects() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getProjects();
      
      if (response['success'] == true) {
        _projects = (response['projects'] as List)
            .map((projectData) => Project.fromJson(projectData))
            .toList();
        
        _applyFilter();
        _setLoading(false);
      } else {
        // Fallback to mock data for demo
        _loadMockProjects();
        _setLoading(false);
      }
    } catch (e) {
      // Fallback to mock data for demo when API fails
      _loadMockProjects();
      _setLoading(false);
    }
  }

  void _loadMockProjects() {
    _projects = [
      Project(
        id: 'proj1',
        name: 'Zentry Mobile App',
        description: 'Complete mobile application with gamification features',
        status: 'active',
        color: '#6366F1',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        userId: 'user1',
        memberIds: ['user1', 'user2', 'user3'],
        taskIds: ['1', '2', '3'],
      ),
      Project(
        id: 'proj2',
        name: 'Backend API Development',
        description: 'RESTful API with authentication and data management',
        status: 'active',
        color: '#10B981',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        dueDate: DateTime.now().add(const Duration(days: 20)),
        userId: 'user1',
        memberIds: ['user1', 'user2'],
        taskIds: ['4', '5'],
      ),
      Project(
        id: 'proj3',
        name: 'UI/UX Design System',
        description: 'Comprehensive design system and component library',
        status: 'completed',
        color: '#F59E0B',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        dueDate: DateTime.now().subtract(const Duration(days: 3)),
        completedAt: DateTime.now().subtract(const Duration(days: 3)),
        userId: 'user1',
        memberIds: ['user1', 'user4'],
        taskIds: ['6'],
      ),
      Project(
        id: 'proj4',
        name: 'Team Collaboration Features',
        description: 'Real-time collaboration and communication tools',
        status: 'on_hold',
        color: '#8B5CF6',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        dueDate: DateTime.now().add(const Duration(days: 45)),
        userId: 'user1',
        memberIds: ['user1'],
        taskIds: ['7'],
      ),
    ];
    _applyFilter();
  }

  Future<bool> createProject(ProjectRequest projectRequest) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.createProject(projectRequest);
      
      if (response['success'] == true) {
        final newProject = Project.fromJson(response['project']);
        _projects.add(newProject);
        _applyFilter();
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to create project';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Failed to create project: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProject(String projectId, ProjectRequest projectRequest) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.updateProject(projectId, projectRequest);
      
      if (response['success'] == true) {
        final updatedProject = Project.fromJson(response['project']);
        final index = _projects.indexWhere((project) => project.id == projectId);
        
        if (index != -1) {
          _projects[index] = updatedProject;
          _applyFilter();
        }
        
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update project';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Failed to update project: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteProject(String projectId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.deleteProject(projectId);
      
      if (response['success'] == true) {
        _projects.removeWhere((project) => project.id == projectId);
        _applyFilter();
        _setLoading(false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to delete project';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Failed to delete project: $e';
      _setLoading(false);
      return false;
    }
  }

  void applyFilter(ProjectFilter filter) {
    _currentFilter = filter;
    _applyFilter();
  }

  void clearFilter() {
    _currentFilter = ProjectFilter();
    _applyFilter();
  }

  void _applyFilter() {
    _filteredProjects = _projects.where((project) {
      if (_currentFilter.status != null && project.status != _currentFilter.status) {
        return false;
      }
      
      if (_currentFilter.userId != null && project.userId != _currentFilter.userId) {
        return false;
      }
      
      if (_currentFilter.dueDateFrom != null && project.dueDate != null) {
        if (project.dueDate!.isBefore(_currentFilter.dueDateFrom!)) {
          return false;
        }
      }
      
      if (_currentFilter.dueDateTo != null && project.dueDate != null) {
        if (project.dueDate!.isAfter(_currentFilter.dueDateTo!)) {
          return false;
        }
      }
      
      if (_currentFilter.isOverdue == true && !project.isOverdue) {
        return false;
      }
      
      return true;
    }).toList();

    // Sort projects by creation date (newest first)
    _filteredProjects.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    notifyListeners();
  }

  Project? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((project) => project.id == projectId);
    } catch (e) {
      return null;
    }
  }

  List<Project> getProjectsByStatus(String status) {
    return _projects.where((project) => project.status == status).toList();
  }

  List<Project> getActiveProjects() {
    return _projects.where((project) => project.isActive).toList();
  }

  List<Project> getCompletedProjects() {
    return _projects.where((project) => project.isCompleted).toList();
  }

  List<Project> getOverdueProjects() {
    return _projects.where((project) => project.isOverdue).toList();
  }

  List<Project> getRecentProjects({int limit = 10}) {
    final sortedProjects = List<Project>.from(_projects);
    sortedProjects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedProjects.take(limit).toList();
  }

  List<Project> getProjectsByUser(String userId) {
    return _projects.where((project) => 
      project.userId == userId || project.memberIds.contains(userId)
    ).toList();
  }

  Map<String, int> getProjectCountsByStatus() {
    final counts = <String, int>{};
    for (final project in _projects) {
      counts[project.status] = (counts[project.status] ?? 0) + 1;
    }
    return counts;
  }

  double getCompletionRate() {
    if (_projects.isEmpty) return 0.0;
    return completedProjects / totalProjects;
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
