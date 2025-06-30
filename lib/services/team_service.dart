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

  // Delete team (only admin can delete)
  Future<bool> deleteTeam(String teamId) async {
    final userId = await getCurrentUserId();
    final teams = await _getAllTeams();
    final team = teams.firstWhere((t) => t.id == teamId, 
        orElse: () => throw Exception('Team not found'));
    
    // Check if user is admin
    if (!team.isAdmin(userId)) {
      throw Exception('Only team admins can delete the team');
    }
    
    // Remove team from storage
    teams.removeWhere((t) => t.id == teamId);
    await _saveAllTeams(teams);
    
    return true;
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
      // Team 1: Development Team
      Team(
        id: 'team_zentry_dev',
        name: 'Zentry Development Team',
        description: 'Building the next-generation productivity app with gamification features, AI integration, and team collaboration tools.',
        createdBy: userId,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        members: [
          TeamMember(
            userId: userId,
            name: 'Ron Vincent Cada',
            email: 'ron.cada@zentry.app',
            role: TeamRole.admin,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 15)),
          ),
          TeamMember(
            userId: 'user_sarah_dev',
            name: 'Sarah Mitchell',
            email: 'sarah.mitchell@zentry.app',
            role: TeamRole.manager,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 12)),
          ),
          TeamMember(
            userId: 'user_alex_ui',
            name: 'Alex Chen',
            email: 'alex.chen@zentry.app',
            role: TeamRole.member,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 10)),
          ),
          TeamMember(
            userId: 'user_maria_qa',
            name: 'Maria Rodriguez',
            email: 'maria.rodriguez@zentry.app',
            role: TeamRole.member,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 8)),
          ),
          TeamMember(
            userId: 'user_james_backend',
            name: 'James Thompson',
            email: 'james.thompson@zentry.app',
            role: TeamRole.member,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ],
        type: TeamType.project,
        inviteCode: 'ZENTRY2024',
      ),
      
      // Team 2: Academic Team
      Team(
        id: 'team_msu_cs',
        name: 'MSU Computer Science Research',
        description: 'Advanced research group focusing on AI applications in productivity software, mobile development, and user experience design.',
        createdBy: 'user_prof_garcia',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        members: [
          TeamMember(
            userId: userId,
            name: 'Ron Vincent Cada',
            email: 'r.cada@student.msu.edu',
            role: TeamRole.member,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 6)),
          ),
          TeamMember(
            userId: 'user_prof_garcia',
            name: 'Prof. Dr. Elena Garcia',
            email: 'e.garcia@msu.edu',
            role: TeamRole.admin,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 8)),
          ),
          TeamMember(
            userId: 'user_emily_phd',
            name: 'Emily Watson',
            email: 'e.watson@student.msu.edu',
            role: TeamRole.manager,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
          TeamMember(
            userId: 'user_david_research',
            name: 'David Kim',
            email: 'd.kim@student.msu.edu',
            role: TeamRole.member,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          TeamMember(
            userId: 'user_lisa_intern',
            name: 'Lisa Zhang',
            email: 'l.zhang@student.msu.edu',
            role: TeamRole.member,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
        type: TeamType.study,
        inviteCode: 'MSUCSR24',
      ),
      
      // Team 3: Startup Team
      Team(
        id: 'team_techstars',
        name: 'TechStars Accelerator Cohort',
        description: 'Innovative startup teams building cutting-edge productivity solutions. Focus on rapid development, user acquisition, and market validation.',
        createdBy: 'user_mentor_john',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        members: [
          TeamMember(
            userId: userId,
            name: 'Ron Vincent Cada',
            email: 'ron@zentrystartup.com',
            role: TeamRole.member,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 10)),
          ),
          TeamMember(
            userId: 'user_mentor_john',
            name: 'John Anderson',
            email: 'j.anderson@techstars.com',
            role: TeamRole.admin,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 12)),
          ),
          TeamMember(
            userId: 'user_sophie_founder',
            name: 'Sophie Williams',
            email: 'sophie@productivehub.co',
            role: TeamRole.manager,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 11)),
          ),
          TeamMember(
            userId: 'user_marcus_tech',
            name: 'Marcus Johnson',
            email: 'marcus@smarttask.io',
            role: TeamRole.member,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 9)),
          ),
          TeamMember(
            userId: 'user_anna_design',
            name: 'Anna Petrov',
            email: 'anna@focusflow.app',
            role: TeamRole.member,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 8)),
          ),
          TeamMember(
            userId: 'user_carlos_marketing',
            name: 'Carlos Mendez',
            email: 'carlos@growthhack.co',
            role: TeamRole.member,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 6)),
          ),
        ],
        type: TeamType.work,
        inviteCode: 'TECHSTAR24',
      ),
      
      // Team 4: Open Source Team
      Team(
        id: 'team_opensource',
        name: 'Flutter Open Source Contributors',
        description: 'Contributing to Flutter ecosystem with productivity apps, UI components, and developer tools. Building the future of mobile development.',
        createdBy: 'user_flutter_lead',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        members: [
          TeamMember(
            userId: userId,
            name: 'Ron Vincent Cada',
            email: 'ron.cada@flutter-contrib.org',
            role: TeamRole.member,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 4)),
          ),
          TeamMember(
            userId: 'user_flutter_lead',
            name: 'Maya Patel',
            email: 'maya@flutter-contrib.org',
            role: TeamRole.admin,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          TeamMember(
            userId: 'user_flutter_senior',
            name: 'Thomas Mueller',
            email: 'thomas@flutter-contrib.org',
            role: TeamRole.manager,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 4)),
          ),
          TeamMember(
            userId: 'user_flutter_dev1',
            name: 'Priya Sharma',
            email: 'priya@flutter-contrib.org',
            role: TeamRole.member,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          TeamMember(
            userId: 'user_flutter_dev2',
            name: 'Ahmed Hassan',
            email: 'ahmed@flutter-contrib.org',
            role: TeamRole.member,
            status: MemberStatus.active,
            joinedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
        type: TeamType.project,
        inviteCode: 'FLUTTER24',
      ),
    ];

    await _saveAllTeams(sampleTeams);
    return sampleTeams.where((team) => team.isMember(userId)).toList();
  }
}
