import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../widgets/common/glass_card.dart';
import '../../providers/team_provider.dart';
import '../../models/team.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  
  TeamType _selectedType = TeamType.project;
  final List<String> _inviteEmails = [];
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Create Team',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildTeamTypeSection(),
              const SizedBox(height: 24),
              _buildInviteMembersSection(),
              const SizedBox(height: 32),
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.purpleGradient,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.groups,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create New Team',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Set up your team for better collaboration',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Team Name',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                hintText: 'e.g., Mobile App Development Team',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group, color: AppColors.textSecondary),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a team name';
                }
                if (value.trim().length < 3) {
                  return 'Team name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                hintText: 'Describe your team\'s purpose and goals...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description, color: AppColors.textSecondary),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamTypeSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Team Type',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...TeamType.values.map((type) => _buildTeamTypeOption(type)),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamTypeOption(TeamType type) {
    final isSelected = _selectedType == type;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.purpleGradient.first.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border.all(
              color: isSelected 
                  ? AppColors.purpleGradient.first
                  : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                _getTeamIcon(type),
                color: isSelected 
                    ? AppColors.purpleGradient.first
                    : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: TextStyle(
                        color: isSelected 
                            ? AppColors.purpleGradient.first
                            : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.purpleGradient.first,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInviteMembersSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invite Members (Optional)',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can invite team members now or add them later',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      hintText: 'member@example.com',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email, color: AppColors.textSecondary),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleGradient.first,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            if (_inviteEmails.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Invited Members:',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...(_inviteEmails.map((email) => _buildEmailChip(email))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmailChip(String email) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.tealGradient.first.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: AppColors.tealGradient.first,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      email,
                      style: TextStyle(
                        color: AppColors.tealGradient.first,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeEmail(email),
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                    ),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCreating ? null : _createTeam,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purpleGradient.first,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isCreating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Create Team',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
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

  void _addEmail() {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) return;
    
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    if (_inviteEmails.contains(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email already added'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    setState(() {
      _inviteEmails.add(email);
      _emailController.clear();
    });
  }

  void _removeEmail(String email) {
    setState(() {
      _inviteEmails.remove(email);
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _createTeam() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isCreating = true;
    });
    
    try {
      final teamProvider = context.read<TeamProvider>();
      
      final team = await teamProvider.createTeam(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        initialMemberEmails: _inviteEmails.isNotEmpty ? _inviteEmails : null,
      );
      
      if (team != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Team created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create team. Please try again.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }
}
