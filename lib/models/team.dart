class Team {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final List<TeamMember> members;
  final String? avatarUrl;
  final TeamType type;
  final String? inviteCode;

  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.members,
    this.avatarUrl,
    required this.type,
    this.inviteCode,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      members: (json['members'] as List)
          .map((m) => TeamMember.fromJson(m))
          .toList(),
      avatarUrl: json['avatarUrl'],
      type: TeamType.values.firstWhere(
        (t) => t.toString().split('.').last == json['type'],
        orElse: () => TeamType.project,
      ),
      inviteCode: json['inviteCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'members': members.map((m) => m.toJson()).toList(),
      'avatarUrl': avatarUrl,
      'type': type.toString().split('.').last,
      'inviteCode': inviteCode,
    };
  }

  int get memberCount => members.length;
  
  List<TeamMember> get activeMembers => 
      members.where((m) => m.status == MemberStatus.active).toList();
      
  TeamMember? getMember(String userId) =>
      members.where((m) => m.userId == userId).firstOrNull;
      
  bool isAdmin(String userId) =>
      getMember(userId)?.role == TeamRole.admin || createdBy == userId;
      
  bool isMember(String userId) =>
      members.any((m) => m.userId == userId && m.status == MemberStatus.active);
}

class TeamMember {
  final String userId;
  final String name;
  final String email;
  final TeamRole role;
  final MemberStatus status;
  final DateTime joinedAt;
  final String? avatarUrl;

  TeamMember({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.avatarUrl,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      role: TeamRole.values.firstWhere(
        (r) => r.toString().split('.').last == json['role'],
        orElse: () => TeamRole.member,
      ),
      status: MemberStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => MemberStatus.active,
      ),
      joinedAt: DateTime.parse(json['joinedAt']),
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'status': status.toString().split('.').last,
      'joinedAt': joinedAt.toIso8601String(),
      'avatarUrl': avatarUrl,
    };
  }
}

enum TeamType {
  project,      // Software/academic projects
  study,        // Study groups
  work,         // Work teams
  personal,     // Personal/family
}

enum TeamRole {
  admin,        // Full permissions
  manager,      // Can manage tasks and members
  member,       // Can work on assigned tasks
  viewer,       // Read-only access
}

enum MemberStatus {
  active,
  invited,
  inactive,
  removed,
}

extension TeamTypeExtension on TeamType {
  String get displayName {
    switch (this) {
      case TeamType.project:
        return 'Project Team';
      case TeamType.study:
        return 'Study Group';
      case TeamType.work:
        return 'Work Team';
      case TeamType.personal:
        return 'Personal Team';
    }
  }

  String get description {
    switch (this) {
      case TeamType.project:
        return 'For software development, academic projects, and group assignments';
      case TeamType.study:
        return 'For study groups, exam preparation, and learning together';
      case TeamType.work:
        return 'For workplace teams and professional collaboration';
      case TeamType.personal:
        return 'For family projects and personal group activities';
    }
  }
}

extension TeamRoleExtension on TeamRole {
  String get displayName {
    switch (this) {
      case TeamRole.admin:
        return 'Administrator';
      case TeamRole.manager:
        return 'Project Manager';
      case TeamRole.member:
        return 'Team Member';
      case TeamRole.viewer:
        return 'Viewer';
    }
  }

  String get description {
    switch (this) {
      case TeamRole.admin:
        return 'Full access to manage team, projects, and members';
      case TeamRole.manager:
        return 'Can create projects, assign tasks, and manage workflows';
      case TeamRole.member:
        return 'Can work on assigned tasks and contribute to projects';
      case TeamRole.viewer:
        return 'Can view projects and progress but cannot edit';
    }
  }
}
