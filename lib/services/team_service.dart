import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/team.dart';

class TeamService {
  static const String _teamsKey = 'teams';
  static const String _currentUserKey = 'current_user_id';

  // Simulate current user ID (in real app, this would come from auth)
  Future<String> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_currentUserKey);
    
    if (userId == null) {
      // Generate a unique user ID for demo purposes
      userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_currentUserKey, userId);
    }
    
    return userId;
  }

  // Get all teams for the current user
  Future<List<Team>> getUserTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await getCurrentUserId();
    
    final teamsJson = prefs.getString(_teamsKey);
    if (teamsJson == null) {
      // Create sample teams for demo
      return await _createSampleTeams(userId);
    }
    
    final List<dynamic> teamsList = json.decode(teamsJson);
    final allTeams = teamsList.map((t) => Team.fromJson(t)).toList();
    
    // Return only teams where user is a member
    return allTeams.where((team) => team.isMember(userId)).toList();
  }

  // Create a new team
  Future<Team> createTeam({
    required String name,
    required String description,
    required TeamType type,
    List<String>? initialMemberEmails,
  }) async {
    final userId = await getCurrentUserId();
    final teamId = 'team_${DateTime.now().millisecondsSinceEpoch}';
    final inviteCode = _generateInviteCode();
    
    // Create team creator as admin
    final creator = TeamMember(
      userId: userId,
      name: 'Current User', // In real app, get from user profile
      email: 'user@example.com', // In real app, get from user profile
      role: TeamRole.admin,
      status: MemberStatus.active,
      joinedAt: DateTime.now(),
    );
    
    final team = Team(
      id: teamId,
      name: name,
      description: description,
      createdBy: userId,
      createdAt: DateTime.now(),
      members: [creator],
      type: type,
      inviteCode: inviteCode,
    );
    
    await _saveTeam(team);
    
    // Send invites to initial members if provided
    if (initialMemberEmails != null) {
      for (final email in initialMemberEmails) {
        await _inviteMemberByEmail(team, email, TeamRole.member);
      }
    }
    
    return team;
  }

  // Join team by invite code
  Future<Team?> joinTeamByInviteCode(String inviteCode) async {
    final allTeams = await _getAllTeams();
    final team = allTeams.where((t) => t.inviteCode == inviteCode).firstOrNull;
    
    if (team == null) {
      throw Exception('Invalid invite code');
    }
    
    final userId = await getCurrentUserId();
    
    // Check if user is already a member
    if (team.isMember(userId)) {
      return team;
    }
    
    // Add user as member
    final newMember = TeamMember(
      userId: userId,
      name: 'Current User',
      email: 'user@example.com',
      role: TeamRole.member,
      status: MemberStatus.active,
      joinedAt: DateTime.now(),
    );
    
    final updatedMembers = [...team.members, newMember];
    final updatedTeam = Team(
      id: team.id,
      name: team.name,
      description: team.description,
      createdBy: team.createdBy,
      createdAt: team.createdAt,
      members: updatedMembers,
      avatarUrl: team.avatarUrl,
      type: team.type,
      inviteCode: team.inviteCode,
    );
    
    await _updateTeam(updatedTeam);
    return updatedTeam;
  }

  // Invite member to team
  Future<bool> inviteMember({
    required String teamId,
    required String email,
    required TeamRole role,
  }) async {
    final teams = await _getAllTeams();
    final teamIndex = teams.indexWhere((t) => t.id == teamId);
    
    if (teamIndex == -1) {
      throw Exception('Team not found');
    }
    
    final team = teams[teamIndex];
    await _inviteMemberByEmail(team, email, role);
    
    return true;
  }

  // Update member role
  Future<bool> updateMemberRole({
    required String teamId,
    required String userId,
    required TeamRole role,
  }) async {
    final teams = await _getAllTeams();
    final teamIndex = teams.indexWhere((t) => t.id == teamId);
    
    if (teamIndex == -1) {
      throw Exception('Team not found');
    }
    
    final team = teams[teamIndex];
    final memberIndex = team.members.indexWhere((m) => m.userId == userId);
    
    if (memberIndex == -1) {
      throw Exception('Member not found');
    }
    
    // Update member role
    final updatedMember = TeamMember(
      userId: team.members[memberIndex].userId,
      name: team.members[memberIndex].name,
      email: team.members[memberIndex].email,
      role: role,
      status: team.members[memberIndex].status,
      joinedAt: team.members[memberIndex].joinedAt,
      avatarUrl: team.members[memberIndex].avatarUrl,
    );
    
    final updatedMembers = [...team.members];
    updatedMembers[memberIndex] = updatedMember;
    
    final updatedTeam = Team(
      id: team.id,
      name: team.name,
      description: team.description,
      createdBy: team.createdBy,
      createdAt: team.createdAt,
      members: updatedMembers,
      avatarUrl: team.avatarUrl,
      type: team.type,
      inviteCode: team.inviteCode,
    );
    
    await _updateTeam(updatedTeam);
    return true;
  }

  // Remove member from team
  Future<bool> removeMember({
    required String teamId,
    required String userId,
  }) async {
    final teams = await _getAllTeams();
    final teamIndex = teams.indexWhere((t) => t.id == teamId);
    
    if (teamIndex == -1) {
      throw Exception('Team not found');
    }
    
    final team = teams[teamIndex];
    final updatedMembers = team.members.where((m) => m.userId != userId).toList();
    
    final updatedTeam = Team(
      id: team.id,
      name: team.name,
      description: team.description,
      createdBy: team.createdBy,
      createdAt: team.createdAt,
      members: updatedMembers,
      avatarUrl: team.avatarUrl,
      type: team.type,
      inviteCode: team.inviteCode,
    );
    
    await _updateTeam(updatedTeam);
    return true;
  }

  // Leave team
  Future<bool> leaveTeam(String teamId) async {
    final userId = await getCurrentUserId();
    return await removeMember(teamId: teamId, userId: userId);
  }

  // Private helper methods
  Future<List<Team>> _getAllTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final teamsJson = prefs.getString(_teamsKey);
    
    if (teamsJson == null) return [];
    
    final List<dynamic> teamsList = json.decode(teamsJson);
    return teamsList.map((t) => Team.fromJson(t)).toList();
  }

  Future<void> _saveTeam(Team team) async {
    final teams = await _getAllTeams();
    teams.add(team);
    await _saveAllTeams(teams);
  }

  Future<void> _updateTeam(Team updatedTeam) async {
    final teams = await _getAllTeams();
    final index = teams.indexWhere((t) => t.id == updatedTeam.id);
    
    if (index != -1) {
      teams[index] = updatedTeam;
      await _saveAllTeams(teams);
    }
  }

  Future<void> _saveAllTeams(List<Team> teams) async {
    final prefs = await SharedPreferences.getInstance();
    final teamsJson = json.encode(teams.map((t) => t.toJson()).toList());
    await prefs.setString(_teamsKey, teamsJson);
  }

  Future<void> _inviteMemberByEmail(Team team, String email, TeamRole role) async {
    // In a real app, this would send an actual invitation email
    // For demo purposes, we'll just add a pending member
    
    final invitedMember = TeamMember(
      userId: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@')[0], // Use email prefix as name
      email: email,
      role: role,
      status: MemberStatus.invited,
      joinedAt: DateTime.now(),
    );
    
    final updatedMembers = [...team.members, invitedMember];
    final updatedTeam = Team(
      id: team.id,
      name: team.name,
      description: team.description,
      createdBy: team.createdBy,
      createdAt: team.createdAt,
      members: updatedMembers,
      avatarUrl: team.avatarUrl,
      type: team.type,
      inviteCode: team.inviteCode,
    );
    
    await _updateTeam(updatedTeam);
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<List<Team>> _createSampleTeams(String userId) async {
    final sampleTeams = [
      Team(
        id: 'team_sample_1',
        name: 'Mobile App Project',
        description: 'Developing a productivity app for students',
        createdBy: userId,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        members: [
          TeamMember(
            userId: userId,
            name: 'You',
            email: 'you@example.com',
            role: TeamRole.admin,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
          TeamMember(
            userId: 'user_alice',
            name: 'Alice Johnson',
            email: 'alice@example.com',
            role: TeamRole.manager,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          TeamMember(
            userId: 'user_bob',
            name: 'Bob Smith',
            email: 'bob@example.com',
            role: TeamRole.member,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
        type: TeamType.project,
        inviteCode: 'PROJ2024',
      ),
      Team(
        id: 'team_sample_2',
        name: 'CS Study Group',
        description: 'Preparing for final exams together',
        createdBy: 'user_alice',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        members: [
          TeamMember(
            userId: userId,
            name: 'You',
            email: 'you@example.com',
            role: TeamRole.member,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          TeamMember(
            userId: 'user_alice',
            name: 'Alice Johnson',
            email: 'alice@example.com',
            role: TeamRole.admin,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
        type: TeamType.study,
        inviteCode: 'STUDY24',
      ),
    ];

    await _saveAllTeams(sampleTeams);
    return sampleTeams.where((team) => team.isMember(userId)).toList();
  }
}
