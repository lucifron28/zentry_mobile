import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/common/glass_card.dart';
import '../services/ai_service.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  
  // Placeholder API key - to be replaced later
  static const String _apiKeyPlaceholder = 'your_api_key_here';

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text: "Hello! I'm Zenturion, your AI productivity assistant. I'm here to help you manage tasks, projects, and achieve your goals. How can I assist you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          text: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // Use AI service for response
      String aiResponse = await AIService.sendMessage(userMessage);
      
      setState(() {
        _messages.add(
          ChatMessage(
            text: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to placeholder response if service fails
      String aiResponse = _generatePlaceholderResponse(userMessage);
      
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Sorry, I'm having trouble connecting to my AI brain right now. Here's what I can tell you: $aiResponse",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  String _generatePlaceholderResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('task') || lowerMessage.contains('todo')) {
      return "I can help you manage your tasks! You can create new tasks, set priorities, and track your progress. Would you like me to help you create a new task or organize your existing ones?";
    } else if (lowerMessage.contains('project')) {
      return "Projects are a great way to organize your work! I can help you break down large projects into manageable tasks, set deadlines, and track progress. What project are you working on?";
    } else if (lowerMessage.contains('achievement') || lowerMessage.contains('goal')) {
      return "Achievements help you stay motivated! You're currently working toward several goals. Keep completing tasks and maintaining streaks to unlock new achievements and earn XP!";
    } else if (lowerMessage.contains('help') || lowerMessage.contains('how')) {
      return "I'm here to help you be more productive! I can assist with:\n• Creating and managing tasks\n• Organizing projects\n• Setting goals and tracking progress\n• Analyzing your productivity patterns\n• Providing motivation and tips\n\nWhat would you like help with?";
    } else {
      return "I understand you're looking for assistance with productivity. While I'm still learning about your specific needs, I'm here to help you stay organized and achieve your goals. Could you tell me more about what you'd like to accomplish?";
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMd),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.purpleGradient,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: const Icon(
                      Icons.psychology_outlined,
                      color: Colors.white,
                      size: AppSizes.iconMd,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zenturion AI',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Your AI Productivity Assistant',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Show info about API key placeholder
                      _showApiKeyInfo();
                    },
                    icon: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Chat messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSizes.paddingMd),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildTypingIndicator();
                  }
                  
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            
            // Input area
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMd),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask Zenturion anything...',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          borderSide: BorderSide(
                            color: AppColors.purpleGradient.first,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMd,
                          vertical: AppSizes.paddingSm,
                        ),
                      ),
                      style: TextStyle(color: AppColors.textPrimary),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingSm),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.purpleGradient,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: IconButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      icon: Icon(
                        _isLoading ? Icons.hourglass_empty : Icons.send,
                        color: Colors.white,
                      ),
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

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMd),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.purpleGradient.first,
              child: const Icon(
                Icons.psychology_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: AppSizes.paddingSm),
          ],
          Flexible(
            child: GlassCard(
              margin: EdgeInsets.zero,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.all(AppSizes.paddingMd),
                decoration: BoxDecoration(
                  gradient: message.isUser
                      ? const LinearGradient(
                          colors: AppColors.purpleGradient,
                        )
                      : null,
                  color: message.isUser ? null : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: message.isUser
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: AppSizes.paddingSm),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.tealGradient.first,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMd),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.purpleGradient.first,
            child: const Icon(
              Icons.psychology_outlined,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: AppSizes.paddingSm),
          GlassCard(
            margin: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.paddingMd),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Zenturion is thinking',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.purpleGradient.first,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _showApiKeyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.purpleGradient.first,
            ),
            const SizedBox(width: 8),
            Text(
              'AI Configuration',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zenturion AI Status',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  AIService.isConfigured ? Icons.check_circle : Icons.error,
                  color: AIService.isConfigured ? AppColors.success : AppColors.danger,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  AIService.isConfigured ? 'Configured' : 'Not Configured',
                  style: TextStyle(
                    color: AIService.isConfigured ? AppColors.success : AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'To connect to a real AI service:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '1. Replace the API key placeholder in AIService\n'
              '2. Update the base URL for your AI provider\n'
              '3. Implement the HTTP client integration\n'
              '4. Configure authentication headers\n\n'
              'For now, Zenturion uses smart placeholder responses to help you get started!',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it',
              style: TextStyle(color: AppColors.purpleGradient.first),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
