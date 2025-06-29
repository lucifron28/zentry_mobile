import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../widgets/common/glass_card.dart';
import '../../providers/team_provider.dart';
import '../../models/team.dart';

class TeamDetailsScreen extends StatefulWidget {
  final String teamId;

  const TeamDetailsScreen({
    super.key,
    required this.teamId,
  });

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Team? _team;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTeamDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTeamDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final teamProvider = context.read<TeamProvider>();
      await teamProvider.loadTeams();
      _team = teamProvider.teams.firstWhere(
        (team) => team.id == widget.teamId,
        orElse: () => throw Exception('Team not found'),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading team: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Team Details'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_team == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Team Details'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'Team not found',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _team!.name,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          if (_team!.isAdmin('current_user_id')) // TODO: Replace with actual user ID
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit Team'),
                ),
                const PopupMenuItem(
                  value: 'invite',
                  child: Text('Invite Members'),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Text('Team Settings'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Team'),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Members'),
            Tab(text: 'Projects'),
          ],
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.success,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildMembersTab(),
          _buildProjectsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team Header
          GlassCard(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getTeamTypeGradient(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getTeamTypeIcon(),
                        size: 32,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _team!.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _team!.type.toString().split('.').last.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _team!.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Team Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Members',
                  _team!.members.length.toString(),
                  Icons.people,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Projects',
                  '0', // TODO: Implement project count
                  Icons.folder,
                  AppColors.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Created',
                  _formatDate(_team!.createdAt),
                  Icons.calendar_today,
                  AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Invite Code',
                  _team!.inviteCode ?? 'No Code',
                  Icons.key,
                  AppColors.danger,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _team!.members.length,
      itemBuilder: (context, index) {
        final member = _team!.members[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.success,
                child: Text(
                  member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                member.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${member.role.toString().split('.').last} • ${member.status.toString().split('.').last}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: _buildMemberActions(member),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'No Projects Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Team projects will appear here when created',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Invite Members',
                Icons.person_add,
                AppColors.success,
                () => _showInviteDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Create Project',
                Icons.add_box,
                AppColors.warning,
                () {
                  // TODO: Navigate to create project screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Project creation coming soon!'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Team Settings',
                Icons.settings,
                AppColors.textSecondary,
                () {
                  // TODO: Navigate to team settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Team settings coming soon!'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Leave Team',
                Icons.exit_to_app,
                AppColors.danger,
                () => _showLeaveTeamDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberActions(TeamMember member) {
    if (!_team!.isAdmin('current_user_id')) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
      onSelected: (value) => _handleMemberAction(value, member),
      itemBuilder: (context) => [
        if (member.role != TeamRole.admin)
          const PopupMenuItem(
            value: 'promote',
            child: Text('Promote to Admin'),
          ),
        if (member.role == TeamRole.admin && member.userId != 'current_user_id')
          const PopupMenuItem(
            value: 'demote',
            child: Text('Remove Admin'),
          ),
        if (member.userId != 'current_user_id')
          const PopupMenuItem(
            value: 'remove',
            child: Text('Remove from Team'),
          ),
      ],
    );
  }

  List<Color> _getTeamTypeGradient() {
    switch (_team!.type) {
      case TeamType.project:
        return AppColors.blueGradient;
      case TeamType.study:
        return AppColors.greenGradient;
      case TeamType.work:
        return AppColors.purpleGradient;
      case TeamType.personal:
        return AppColors.orangeGradient;
    }
  }

  IconData _getTeamTypeIcon() {
    switch (_team!.type) {
      case TeamType.project:
        return Icons.work;
      case TeamType.study:
        return Icons.school;
      case TeamType.work:
        return Icons.business;
      case TeamType.personal:
        return Icons.person;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit team screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit team coming soon!')),
        );
        break;
      case 'invite':
        _showInviteDialog();
        break;
      case 'settings':
        // TODO: Navigate to team settings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team settings coming soon!')),
        );
        break;
      case 'delete':
        _showDeleteTeamDialog();
        break;
    }
  }

  void _handleMemberAction(String action, TeamMember member) {
    switch (action) {
      case 'promote':
        // TODO: Implement promote member
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Promoted ${member.name} to admin')),
        );
        break;
      case 'demote':
        // TODO: Implement demote member
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed admin role from ${member.name}')),
        );
        break;
      case 'remove':
        _showRemoveMemberDialog(member);
        break;
    }
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Invite Members',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share this invite code with your team members:',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _team!.inviteCode ?? 'No invite code available',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'monospace',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Copy to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard!')),
                      );
                    },
                    icon: const Icon(Icons.copy, color: AppColors.success),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLeaveTeamDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Leave Team',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to leave "${_team!.name}"? You\'ll need an invite code to rejoin.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // TODO: Implement leave team
              final teamProvider = context.read<TeamProvider>();
              await teamProvider.leaveTeam(_team!.id);
              if (mounted) {
                Navigator.of(context).pop(); // Go back to teams screen
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _showDeleteTeamDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Delete Team',
          style: TextStyle(color: AppColors.danger),
        ),
        content: Text(
          'Are you sure you want to delete "${_team!.name}"? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // TODO: Implement delete team
              final teamProvider = context.read<TeamProvider>();
              await teamProvider.deleteTeam(_team!.id);
              if (mounted) {
                Navigator.of(context).pop(); // Go back to teams screen
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRemoveMemberDialog(TeamMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Remove Member',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to remove ${member.name} from the team?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement remove member
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Removed ${member.name} from team')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
