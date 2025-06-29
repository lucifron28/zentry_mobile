import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../widgets/common/glass_card.dart';
import '../providers/team_provider.dart';
import '../models/team.dart';
import 'teams/create_team_screen.dart';
import 'teams/team_details_screen.dart';
import 'teams/join_team_screen.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamProvider>().loadTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Teams',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            onPressed: () => _showTeamActions(context),
            icon: const Icon(Icons.add),
            tooltip: 'Create or Join Team',
          ),
        ],
      ),
      body: Consumer<TeamProvider>(
        builder: (context, teamProvider, child) {
          if (teamProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (teamProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.danger,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    teamProvider.error!,
                    style: const TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => teamProvider.loadTeams(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final teams = teamProvider.myTeams;

          if (teams.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () => teamProvider.loadTeams(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStatsSection(teams),
                const SizedBox(height: 24),
                _buildTeamsSection(teams),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.purpleGradient,
                ),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                Icons.groups,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to Team Collaboration!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Create or join teams to collaborate on projects, manage group assignments, and achieve goals together.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _createTeam(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Team'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purpleGradient.first,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _joinTeam(context),
                    icon: const Icon(Icons.group_add),
                    label: const Text('Join Team'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.purpleGradient.first,
                      side: BorderSide(color: AppColors.purpleGradient.first),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(List<Team> teams) {
    final adminTeams = teams.where((t) => t.isAdmin('current_user_id')).length;
    final totalMembers = teams.fold<int>(0, (sum, team) => sum + team.memberCount);
    final activeProjects = teams.where((t) => t.type == TeamType.project).length;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Team Stats',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.groups,
                    label: 'Teams',
                    value: teams.length.toString(),
                    color: AppColors.purpleGradient.first,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.admin_panel_settings,
                    label: 'Admin',
                    value: adminTeams.toString(),
                    color: AppColors.tealGradient.first,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.people,
                    label: 'Members',
                    value: totalMembers.toString(),
                    color: AppColors.orangeGradient.first,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.folder,
                    label: 'Projects',
                    value: activeProjects.toString(),
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamsSection(List<Team> teams) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Teams',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showTeamActions(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('New'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.purpleGradient.first,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...teams.map((team) => _buildTeamCard(team)),
      ],
    );
  }

  Widget _buildTeamCard(Team team) {
    final isAdmin = team.isAdmin('current_user_id');
    
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openTeamDetails(team),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _getTeamColor(team.type),
                    child: Icon(
                      _getTeamIcon(team.type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          team.type.displayName,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Admin',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                team.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${team.activeMembers.length} member${team.activeMembers.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getTimeAgo(team.createdAt),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTeamColor(TeamType type) {
    switch (type) {
      case TeamType.project:
        return AppColors.purpleGradient.first;
      case TeamType.study:
        return AppColors.tealGradient.first;
      case TeamType.work:
        return AppColors.orangeGradient.first;
      case TeamType.personal:
        return AppColors.success;
    }
  }

  IconData _getTeamIcon(TeamType type) {
    switch (type) {
      case TeamType.project:
        return Icons.code;
      case TeamType.study:
        return Icons.school;
      case TeamType.work:
        return Icons.work;
      case TeamType.personal:
        return Icons.home;
    }
  }

  String _getTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }

  void _showTeamActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Team Actions',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.purpleGradient.first.withValues(alpha: 0.1),
                child: Icon(
                  Icons.add,
                  color: AppColors.purpleGradient.first,
                ),
              ),
              title: const Text(
                'Create New Team',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Start a new project or study group',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              onTap: () {
                Navigator.pop(context);
                _createTeam(context);
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.tealGradient.first.withValues(alpha: 0.1),
                child: Icon(
                  Icons.group_add,
                  color: AppColors.tealGradient.first,
                ),
              ),
              title: const Text(
                'Join Existing Team',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Enter an invite code to join',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              onTap: () {
                Navigator.pop(context);
                _joinTeam(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _createTeam(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateTeamScreen(),
      ),
    );
  }

  void _joinTeam(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JoinTeamScreen(),
      ),
    );
  }

  void _openTeamDetails(Team team) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamDetailsScreen(teamId: team.id),
      ),
    );
  }
}
