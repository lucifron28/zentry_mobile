import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../widgets/common/glass_card.dart';
import '../services/ai_service.dart';
import '../services/env_config.dart';
import '../providers/task_provider.dart';
import '../providers/achievement_provider.dart';

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
  bool _showDebugInfo = false;

  @override
  void initState() {
    super.initState();
    // Start with empty chat - no demo message
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
      // Debug: Log the attempt
      if (EnvConfig.debugMode) {
        print('🚀 Sending message to AI: $userMessage');
        print('🔧 AI Service configured: ${AIService.isConfigured}');
        print('🔑 API Key configured: ${EnvConfig.geminiApiKey.isNotEmpty}');
      }
      
      // Prepare conversation history for Gemini (last 10 messages to keep context manageable)
      final conversationHistory = <Map<String, String>>[];
      final recentMessages = _messages.length > 10 
          ? _messages.sublist(_messages.length - 10)
          : _messages;
      
      for (final msg in recentMessages) {
        if (msg != _messages.last) { // Exclude the message we just added
          conversationHistory.add({
            'role': msg.isUser ? 'user' : 'assistant',
            'content': msg.text,
          });
        }
      }
      
      // Get real user context
      final userContext = _getUserContext(context);
      
      // Use AI service for response with enhanced context
      String aiResponse = await AIService.sendMessage(
        userMessage,
        conversationHistory: conversationHistory,
        currentScreen: 'ai_assistant',
        userStats: userContext['userStats'],
        recentTasks: userContext['recentTasks'],
      );
      
      if (EnvConfig.debugMode) {
        print('✅ AI Response received: ${aiResponse.substring(0, aiResponse.length > 50 ? 50 : aiResponse.length)}...');
      }
      
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
      if (EnvConfig.debugMode) {
        print('❌ AI Error: $e');
      }
      
      String errorMessage;
      if (e.toString().contains('Invalid Gemini API key') || e.toString().contains('403')) {
        errorMessage = "🔑 I need a valid Gemini API key to access my full capabilities. Please check your .env file configuration!";
      } else if (e.toString().contains('rate limit')) {
        errorMessage = "⏰ I'm getting too many requests right now. Please wait a moment and try again!";
      } else if (e.toString().contains('No internet') || e.toString().contains('SocketException')) {
        errorMessage = "📶 It looks like you're offline. Please check your internet connection and try again!";
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = "⏱️ The request took too long. Please try again!";
      } else {
        errorMessage = "🤖 I'm having a technical issue: ${e.toString()}";
      }
      
      // Generate fallback response
      String fallbackResponse = _generatePlaceholderResponse(userMessage);
      
      setState(() {
        _messages.add(
          ChatMessage(
            text: "$errorMessage\n\n$fallbackResponse",
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

  /// Get real user context from app providers
  Map<String, dynamic> _getUserContext(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
    
    // Get user stats
    final userStats = {
      'level': (achievementProvider.earnedAchievements / 5).floor() + 1, // Simple level calculation
      'xp': achievementProvider.totalXpFromAchievements + (taskProvider.completedTasks * 10),
      'streak': 7, // This would come from actual streak tracking
      'completedTasks': taskProvider.completedTasks,
      'totalTasks': taskProvider.totalTasks,
      'achievementsEarned': achievementProvider.earnedAchievements,
      'totalAchievements': achievementProvider.totalAchievements,
    };
    
    // Get recent tasks (last 5)
    final recentTasks = taskProvider.allTasks
        .take(5)
        .map((task) => {
          'title': task.title,
          'completed': task.isCompleted,
          'priority': task.priority,
          'dueDate': task.dueDate?.toIso8601String(),
        })
        .toList();
    
    return {
      'userStats': userStats,
      'recentTasks': recentTasks,
    };
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
                      setState(() {
                        _showDebugInfo = !_showDebugInfo;
                      });
                    },
                    icon: Icon(
                      _showDebugInfo ? Icons.bug_report : Icons.bug_report_outlined,
                      color: Colors.white,
                    ),
                    tooltip: 'Toggle Debug Info',
                  ),
                ],
              ),
            ),
            
            // Debug panel (if enabled)
            if (_showDebugInfo) _buildDebugPanel(),
            
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

  Widget _buildDebugPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
      padding: const EdgeInsets.all(AppSizes.paddingSm),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Text(
                'Debug Panel',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showDebugInfo = false;
                  });
                },
                icon: const Icon(Icons.close, color: Colors.orange, size: 16),
                iconSize: 16,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getDebugInfo(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  // Test configuration
                  try {
                    await EnvConfig.init();
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuration reloaded'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to reload: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reload Config'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDebugInfo() {
    final apiKey = EnvConfig.geminiApiKey;
    final hasValidKey = apiKey.isNotEmpty && 
                       apiKey != 'your_gemini_api_key_here';
    
    return """
Environment Status:
• Initialized: ${EnvConfig.isInitialized ? '✅' : '❌'}
• Debug Mode: ${EnvConfig.debugMode ? '✅' : '❌'}

Google Gemini Configuration:
• API Key Present: ${hasValidKey ? '✅' : '❌'}
• API Key Length: ${apiKey.length} characters
• API Key Prefix: ${apiKey.length > 10 ? '${apiKey.substring(0, 10)}...' : apiKey}
• Model: ${EnvConfig.geminiModel}
• Max Tokens: ${EnvConfig.geminiMaxTokens}
• Temperature: ${EnvConfig.geminiTemperature}

Service Status:
• AI Service Configured: ${AIService.isConfigured ? '✅' : '❌'}

Setup Instructions (if not configured):
1. Visit: https://makersuite.google.com/app/apikey
2. Create or get your Gemini API key
3. Copy .env.example to .env
4. Replace 'your_gemini_api_key_here' with your actual key
5. Restart the app completely (not hot reload)

Note: Gemini offers a generous free tier, making it ideal for personal productivity apps.
""";
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
