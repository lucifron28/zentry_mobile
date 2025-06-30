import 'package:flutter/foundation.dart';
import '../models/team.dart';
import '../services/team_service.dart';
import '../services/webhook_service.dart';

class TeamProvider extends ChangeNotifier {
  final TeamService _teamService = TeamService();
  
  List<Team> _teams = [];
  Team? _currentTeam;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Team> get teams => _teams;
  Team? get currentTeam => _currentTeam;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<Team> get myTeams => _teams; // Show all teams for demo purposes
  
  List<Team> get adminTeams => _teams.where((team) => 
      team.isAdmin('current_user_id')).toList(); // TODO: Replace with actual user ID

  // Team Management
  Future<void> loadTeams() async {
    _setLoading(true);
    try {
      _teams = await _teamService.getUserTeams();
      _clearError();
    } catch (e) {
      _setError('Failed to load teams: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<Team?> createTeam({
    required String name,
    required String description,
    required TeamType type,
    List<String>? initialMemberEmails,
  }) async {
    _setLoading(true);
    try {
      final team = await _teamService.createTeam(
        name: name,
        description: description,
        type: type,
        initialMemberEmails: initialMemberEmails,
      );
      
      _teams.add(team);
      _clearError();
      
      // Send webhook notification
      await WebhookService.sendProjectCreated(
        projectName: name,
        description: description,
        estimatedTasks: 0,
      );
      
      notifyListeners();
      return team;
    } catch (e) {
      _setError('Failed to create team: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> joinTeam(String inviteCode) async {
    _setLoading(true);
    try {
      final team = await _teamService.joinTeamByInviteCode(inviteCode);
      if (team != null && !_teams.any((t) => t.id == team.id)) {
        _teams.add(team);
        notifyListeners();
      }
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to join team: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> inviteMember({
    required String teamId,
    required String email,
    required TeamRole role,
  }) async {
    try {
      final success = await _teamService.inviteMember(
        teamId: teamId,
        email: email,
        role: role,
      );
      
      if (success) {
        await loadTeams(); // Refresh teams to get updated member list
      }
      
      return success;
    } catch (e) {
      _setError('Failed to invite member: $e');
      return false;
    }
  }

  Future<bool> updateMemberRole({
    required String teamId,
    required String userId,
    required TeamRole newRole,
  }) async {
    try {
      final success = await _teamService.updateMemberRole(
        teamId: teamId,
        userId: userId,
        role: newRole,
      );
      
      if (success) {
        await loadTeams();
      }
      
      return success;
    } catch (e) {
      _setError('Failed to update member role: $e');
      return false;
    }
  }

  Future<bool> removeMember({
    required String teamId,
    required String userId,
  }) async {
    try {
      final success = await _teamService.removeMember(
        teamId: teamId,
        userId: userId,
      );
      
      if (success) {
        await loadTeams();
      }
      
      return success;
    } catch (e) {
      _setError('Failed to remove member: $e');
      return false;
    }
  }

  Future<bool> leaveTeam(String teamId) async {
    try {
      final success = await _teamService.leaveTeam(teamId);
      
      if (success) {
        _teams.removeWhere((team) => team.id == teamId);
        if (_currentTeam?.id == teamId) {
          _currentTeam = null;
        }
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError('Failed to leave team: $e');
      return false;
    }
  }

  Future<bool> deleteTeam(String teamId) async {
    try {
      // Store team name before deletion for webhook
      final teamToDelete = _teams.firstWhere(
        (t) => t.id == teamId, 
        orElse: () => Team(
          id: teamId, 
          name: 'Unknown Team', 
          description: '', 
          type: TeamType.project, 
          createdBy: 'unknown',
          createdAt: DateTime.now(),
          members: [],
        ),
      );
      
      final success = await _teamService.deleteTeam(teamId);
      
      if (success) {
        _teams.removeWhere((team) => team.id == teamId);
        if (_currentTeam?.id == teamId) {
          _currentTeam = null;
        }
        notifyListeners();
        
        // Send webhook notification
        WebhookService.sendTeamDeleted(
          teamId: teamId,
          teamName: teamToDelete.name,
        );
      }
      
      return success;
    } catch (e) {
      _setError('Failed to delete team: $e');
      return false;
    }
  }

  // Team Selection
  void setCurrentTeam(Team? team) {
    _currentTeam = team;
    notifyListeners();
  }

  void clearCurrentTeam() {
    _currentTeam = null;
    notifyListeners();
  }

  // Team Statistics
  Map<String, dynamic> getTeamStats(String teamId) {
    final team = _teams.firstWhere((t) => t.id == teamId);
    
    return {
      'totalMembers': team.memberCount,
      'activeMembers': team.activeMembers.length,
      'admins': team.members.where((m) => m.role == TeamRole.admin).length,
      'managers': team.members.where((m) => m.role == TeamRole.manager).length,
      'members': team.members.where((m) => m.role == TeamRole.member).length,
      'viewers': team.members.where((m) => m.role == TeamRole.viewer).length,
      'createdDaysAgo': DateTime.now().difference(team.createdAt).inDays,
    };
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
