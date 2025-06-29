import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'env_config.dart';

/// Zenturion AI Service - Google Gemini Integration with Environment Configuration
/// 
/// SETUP INSTRUCTIONS:
/// 1. Get your Gemini API key from: https://makersuite.google.com/app/apikey
/// 2. Copy .env.example to .env
/// 3. Replace 'your_gemini_api_key_here' in .env with your actual API key
/// 4. Test the integration by chatting with Zenturion
/// 
/// FEATURES:
/// - Environment-based configuration (.env file)
/// - Gemini 1.5 Flash for fast, accurate responses
/// - Conversation history support (last 10 messages)
/// - Smart error handling with fallback responses
/// - Mobile-optimized response length (configurable via .env)
/// 
/// ADVANTAGES OF GEMINI:
/// - Free tier with generous limits
/// - Fast response times
/// - Better understanding of context
/// - Multimodal capabilities (text, images)
/// - Higher quality responses
class AIService {
  // Gemini API base URL
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  
  // Configuration getters from environment
  static String get _apiKey => EnvConfig.geminiApiKey;
  static String get _model => EnvConfig.geminiModel;
  static int get _maxTokens => EnvConfig.geminiMaxTokens;
  static double get _temperature => EnvConfig.geminiTemperature;
  
  static bool get isConfigured => EnvConfig.isGeminiConfigured;
  
  /// Send a message to the Gemini assistant
  static Future<String> sendMessage(
    String message, {
    List<Map<String, String>>? conversationHistory,
    String? currentScreen,
    Map<String, dynamic>? userStats,
    List<Map<String, dynamic>>? recentTasks,
  }) async {
    // Debug logging
    if (EnvConfig.debugMode) {
      print('🔧 AIService.sendMessage called');
      print('🔧 isConfigured: $isConfigured');
      print('🔧 API Key length: ${_apiKey.length}');
      print('🔧 Model: $_model');
      print('🔧 Max tokens: $_maxTokens');
    }
    
    if (!isConfigured) {
      if (EnvConfig.debugMode) {
        print('⚠️ AI Service not configured, using placeholder response');
      }
      // Fallback to placeholder response if not configured
      await Future.delayed(const Duration(seconds: 1));
      return _generatePlaceholderResponse(message);
    }

    // Check for quick responses first
    final quickResponse = _getQuickResponse(message);
    if (quickResponse != null) {
      return quickResponse;
    }
    
    try {
      if (EnvConfig.debugMode) {
        print('🚀 Making Gemini API request...');
      }
      
      // Build comprehensive prompt with context
      String systemPrompt = _getSystemPrompt();
      String contextualPrompt = _getContextualPrompt(
        recentTasks: recentTasks,
        userStats: userStats,
        currentScreen: currentScreen,
      );
      
      // Detect scenario and add specialized guidance
      String scenarioPrompt = '';
      if (message.toLowerCase().contains(RegExp(r'overwhelm|too much|stressed|busy'))) {
        scenarioPrompt = _getScenarioPrompt('overwhelmed');
      } else if (message.toLowerCase().contains(RegExp(r'procrastinat|delay|avoid|put off'))) {
        scenarioPrompt = _getScenarioPrompt('procrastination');
      } else if (message.toLowerCase().contains(RegExp(r'plan|organiz|schedul|priorit'))) {
        scenarioPrompt = _getScenarioPrompt('planning');
      } else if (message.toLowerCase().contains(RegExp(r'motivat|encourag|inspir|give up'))) {
        scenarioPrompt = _getScenarioPrompt('motivation');
      } else if (message.toLowerCase().contains(RegExp(r'habit|routine|consist|daily'))) {
        scenarioPrompt = _getScenarioPrompt('habits');
      }
      
      // Combine all prompts
      String fullPrompt = systemPrompt + contextualPrompt + scenarioPrompt;
      
      // Add conversation history if provided
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        fullPrompt += '\n\n--- CONVERSATION HISTORY ---\n';
        for (final entry in conversationHistory.take(10)) {
          String role = entry['role'] == 'user' ? 'Ron' : 'Zenturion';
          fullPrompt += '$role: ${entry['content']}\n';
        }
      }
      
      // Add the current user message
      fullPrompt += '\n--- CURRENT MESSAGE ---\nRon: $message\n\nZenturion: ';
      
      final requestBody = {
        'contents': [
          {
            'parts': [
              {
                'text': fullPrompt,
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': _temperature,
          'maxOutputTokens': _maxTokens,
          'topP': 0.95,
          'topK': 40,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          }
        ]
      };
      
      if (EnvConfig.debugMode) {
        print('🔧 Request body: ${json.encode(requestBody)}');
      }
      
      // Make API call to Gemini
      final response = await http.post(
        Uri.parse('$_baseUrl/models/$_model:generateContent?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 30), // 30-second timeout
      );
      
      if (EnvConfig.debugMode) {
        print('🔧 Response status: ${response.statusCode}');
        print('🔧 Response body: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check if we have candidates and content
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          
          final aiResponse = data['candidates'][0]['content']['parts'][0]['text'] as String;
          return aiResponse.trim();
        } else {
          throw Exception('No valid response from Gemini API');
        }
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Invalid request';
        throw Exception('Gemini API error: $errorMessage');
      } else if (response.statusCode == 403) {
        throw Exception('Invalid Gemini API key or quota exceeded. Please check your configuration.');
      } else if (response.statusCode == 429) {
        throw Exception('Gemini API rate limit exceeded. Please try again later.');
      } else if (response.statusCode == 500) {
        throw Exception('Gemini service is currently unavailable. Please try again later.');
      } else {
        throw Exception('Failed to get AI response: ${response.statusCode} - ${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on http.ClientException {
      throw Exception('Network error. Please try again.');
    } catch (e) {
      if (EnvConfig.debugMode) {
        print('❌ AI Service error: $e');
      }
      // Fallback to placeholder response on any error
      return _generatePlaceholderResponse(message);
    }
  }
  
  static String _getSystemPrompt() {
    return '''You are Zenturion, the intelligent AI assistant for Zentry Mobile - a gamified productivity and task management application. You help users maximize their productivity while making work fun and engaging.

## ABOUT ZENTRY MOBILE:

**Core Features:**
- Task Management: Create, organize, and complete tasks with priorities (High, Medium, Low)
- Project Management: Organize tasks into projects with progress tracking
- Gamification System: Earn XP points, level up, and unlock achievements
- Achievement System: Complete challenges to earn badges and rewards
- Streak Tracking: Maintain daily productivity streaks
- Progress Analytics: Track productivity metrics and patterns

**User Profile:**
- User Name: Ron Vincent Cada
- Current Level: Dynamically tracked based on XP
- XP System: Points earned for completing tasks and achieving milestones
- Streaks: Daily task completion tracking

**App Sections:**
1. Dashboard: Overview of tasks, projects, achievements, and progress
2. Tasks: Full task management with filtering and organization
3. Projects: Group related tasks and track project progress  
4. Achievements: Badge system with various categories
5. Profile: User stats, level progression, and settings
6. AI Assistant (You): Productivity coaching and app guidance

## YOUR ROLE AS ZENTURION:

**Primary Functions:**
✅ Productivity coaching and motivation
✅ Task organization and prioritization advice
✅ Goal setting and achievement strategies
✅ Time management tips and techniques
✅ App feature explanations and tutorials
✅ Progress analysis and insights
✅ Gamification encouragement and celebration
✅ Habit formation guidance

**What You Should Help With:**
- Breaking down large projects into manageable tasks
- Suggesting task priorities based on deadlines and importance
- Recommending productivity techniques (Pomodoro, time blocking, etc.)
- Celebrating user achievements and milestones
- Providing motivation during productivity slumps
- Explaining how to use Zentry features effectively
- Analyzing productivity patterns and suggesting improvements
- Setting realistic goals and timelines
- Building sustainable productivity habits

**What You Should NOT Do:**
❌ Provide advice unrelated to productivity or the app
❌ Discuss topics outside of task management and productivity
❌ Give medical, legal, or financial advice
❌ Share personal information about other users
❌ Provide technical support for device/OS issues unrelated to the app
❌ Engage in controversial topics or debates
❌ Generate inappropriate or harmful content

## RESPONSE STYLE:

**Tone:** Encouraging, professional, and gamification-friendly
**Length:** Concise but comprehensive (aim for 2-4 sentences for simple questions, longer for complex advice)
**Personality:** Enthusiastic about productivity, supportive, and slightly playful to match the gamified nature
**Language:** Clear, actionable, and motivating

**Key Phrases to Use:**
- "Level up your productivity"
- "Earn those XP points"
- "Let's crush those goals"
- "Achievement unlocked"
- "Build that streak"
- "Progress over perfection"

## CONVERSATION CONTEXT:

Always consider:
- The user is Ron Vincent Cada
- They're using a gamified productivity app
- Focus on actionable productivity advice
- Encourage continued app engagement
- Celebrate progress and achievements
- Provide specific, practical suggestions

## EXAMPLE RESPONSES:

User: "I have too many tasks and don't know where to start"
You: "Let's level up your task game, Ron! Start by using Zentry's priority system - tackle your High priority tasks first, especially those with approaching deadlines. Try the 2-minute rule: if a task takes less than 2 minutes, do it now and earn those quick XP points. For bigger tasks, break them into smaller subtasks in your projects section. You've got this! 🎯"

User: "I keep procrastinating"
You: "Procrastination is the final boss we all face! Here's your power-up strategy: Set a 15-minute timer and commit to working on just ONE task - often starting is the hardest part. Use Zentry's achievement system as motivation - each completed task gets you closer to unlocking new badges. Also, check your daily streak - maintaining it can become a powerful motivator. Remember, progress beats perfection every time! 💪"

Stay focused on productivity, be encouraging, and help Ron make the most of Zentry's features!''';
  }
  
  static String _generatePlaceholderResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Check for Zentry-specific quick responses first
    if (lowerMessage.contains('task') || lowerMessage.contains('todo')) {
      return "Ready to level up your task game, Ron! I can help you organize tasks, set priorities, and earn XP through Zentry's gamified system. To unlock my full AI coaching capabilities, make sure your Gemini API key is configured in the app settings! 🎯";
    } else if (lowerMessage.contains('project')) {
      return "Projects are perfect for organizing your bigger goals! I can help you break them down into manageable tasks and track progress. Enable my full AI features to get personalized project management advice tailored to Zentry's system! 📁";
    } else if (lowerMessage.contains('achievement') || lowerMessage.contains('goal')) {
      return "Achievements are the best way to stay motivated in Zentry! I'm designed to help you unlock badges, build streaks, and celebrate your wins. Configure my AI settings to get customized achievement strategies! 🏆";
    } else if (lowerMessage.contains('help') || lowerMessage.contains('how')) {
      return "I'm Zenturion, your productivity AI coach for Zentry! I can help with task management, goal setting, time optimization, and making the most of Zentry's gamification features. Set up my Gemini API configuration to unlock advanced coaching! 🚀";
    } else if (lowerMessage.contains('motivation') || lowerMessage.contains('productive')) {
      return "Let's crush those productivity goals, Ron! I'm built specifically for Zentry users to provide personalized motivation and strategies. Enable my full AI capabilities through the settings to get tailored advice for your productivity journey! 💪";
    } else {
      // Randomized Zentry-specific responses
      final responses = [
        "Hey Ron! I'm Zenturion, your productivity AI assistant. I'd love to help you level up your task management game! To unlock my full potential, make sure your Gemini API key is configured in the app settings. 🚀",
        
        "Ready to crush those goals, Ron? I'm here to help you maximize Zentry's features! Check your achievements screen - you might have some badges ready to claim. Configure my AI settings to get personalized productivity advice! 🎯",
        
        "Looking to boost your productivity streak? I can help you organize tasks, set priorities, and build better habits using Zentry's gamified system. Just set up my AI configuration and let's get started! 💪",
        
        "Time to level up! I'm your AI productivity coach, designed to help you make the most of Zentry's task management and achievement system. Enable my full features through the API settings! ⭐",
        
        "Hey there, productivity champion! I'm Zenturion, built specifically for Zentry users like you. I can help with task prioritization, goal setting, and motivation. Just configure my AI settings to unlock advanced coaching! 🏆"
      ];
      
      return responses[DateTime.now().millisecond % responses.length];
    }
  }

  /// Get contextual prompt based on user's current app state
  static String _getContextualPrompt({
    List<Map<String, dynamic>>? recentTasks,
    Map<String, dynamic>? userStats,
    String? currentScreen,
  }) {
    String contextPrompt = '';
    
    // Add context based on current screen
    if (currentScreen != null) {
      switch (currentScreen) {
        case 'dashboard':
          contextPrompt += '\nCONTEXT: User is on the Dashboard. They can see their overview stats, recent tasks, and achievements progress.';
          break;
        case 'tasks':
          contextPrompt += '\nCONTEXT: User is on the Tasks screen. They can create, edit, filter, and manage their tasks here.';
          break;
        case 'projects':
          contextPrompt += '\nCONTEXT: User is on the Projects screen. They can organize tasks into projects and track project progress.';
          break;
        case 'achievements':
          contextPrompt += '\nCONTEXT: User is on the Achievements screen. They can view earned badges, progress toward new achievements, and claim rewards.';
          break;
        case 'profile':
          contextPrompt += '\nCONTEXT: User is on the Profile screen. They can view their level, XP, stats, and account settings.';
          break;
        case 'ai_assistant':
          contextPrompt += '\nCONTEXT: User is chatting with Zenturion, the AI assistant.';
          break;
      }
    }
    
    // Add context about recent activity
    if (recentTasks != null && recentTasks.isNotEmpty) {
      contextPrompt += '\nRECENT ACTIVITY: User has ${recentTasks.length} recent tasks. ';
      int completedTasks = recentTasks.where((task) => task['completed'] == true).length;
      contextPrompt += '$completedTasks completed, ${recentTasks.length - completedTasks} pending.';
    }
    
    // Add context about user stats
    if (userStats != null) {
      contextPrompt += '\nUSER STATS: ';
      if (userStats['level'] != null) contextPrompt += 'Level ${userStats['level']}, ';
      if (userStats['xp'] != null) contextPrompt += '${userStats['xp']} XP, ';
      if (userStats['streak'] != null) contextPrompt += '${userStats['streak']}-day streak, ';
      if (userStats['completedTasks'] != null) contextPrompt += '${userStats['completedTasks']} tasks completed total.';
    }
    
    return contextPrompt;
  }

  /// Get specialized prompt for specific productivity scenarios
  static String _getScenarioPrompt(String scenario) {
    switch (scenario.toLowerCase()) {
      case 'overwhelmed':
        return '''
SCENARIO: User feels overwhelmed with tasks.
RESPONSE FOCUS: Provide calming, actionable advice. Suggest using Zentry's priority system, breaking tasks down, and focusing on one thing at a time. Encourage using the achievement system for motivation.
''';
      
      case 'procrastination':
        return '''
SCENARIO: User is struggling with procrastination.
RESPONSE FOCUS: Offer practical anti-procrastination techniques. Suggest starting with 2-minute tasks for quick wins, using Zentry's streak system for accountability, and celebrating small victories through achievements.
''';
      
      case 'planning':
        return '''
SCENARIO: User needs help with planning and organization.
RESPONSE FOCUS: Guide them through Zentry's project and task organization features. Suggest time-blocking, priority setting, and using the app's progress tracking tools.
''';
      
      case 'motivation':
        return '''
SCENARIO: User needs motivation and encouragement.
RESPONSE FOCUS: Be extra encouraging and enthusiastic. Reference their progress, achievements earned, and potential future rewards. Use gamification language heavily.
''';
      
      case 'habits':
        return '''
SCENARIO: User wants to build better productivity habits.
RESPONSE FOCUS: Provide habit formation advice using Zentry's features. Emphasize consistency, streak tracking, and gradual improvement. Reference the achievement system as a habit reinforcement tool.
''';
      
      default:
        return '';
    }
  }

  /// Quick responses for common Zentry app questions
  static String? _getQuickResponse(String message) {
    String lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('how') && lowerMessage.contains('xp')) {
      return "You earn XP in Zentry by completing tasks! High priority tasks give more XP than low priority ones. You also earn bonus XP for maintaining streaks and unlocking achievements. Keep crushing those tasks to level up! 🎯⭐";
    }
    
    if (lowerMessage.contains('achievement') && lowerMessage.contains('unlock')) {
      return "Achievements in Zentry are unlocked by completing specific challenges! Check your Achievements screen to see what badges you're close to earning. Some are for task completion milestones, others for maintaining streaks, and special ones for unique accomplishments. Each achievement comes with XP rewards too! 🏆✨";
    }
    
    if (lowerMessage.contains('priority') && lowerMessage.contains('task')) {
      return "Great question! In Zentry, set task priorities based on urgency and importance: 🔴 High Priority for urgent deadlines and critical tasks, 🟡 Medium Priority for important but not urgent items, and 🟢 Low Priority for nice-to-have tasks. High priority tasks give more XP when completed! Start with red, then yellow, then green. 📊";
    }
    
    if (lowerMessage.contains('streak') || lowerMessage.contains('daily')) {
      return "Your streak in Zentry tracks consecutive days of task completion! Even completing just one task keeps your streak alive. Longer streaks unlock special achievements and show your consistency. Don't break the chain, Ron - every day counts! 🔥📅";
    }
    
    if (lowerMessage.contains('project') && (lowerMessage.contains('organize') || lowerMessage.contains('group'))) {
      return "Projects in Zentry help you group related tasks together! Create a project, then assign tasks to it to track overall progress. Perfect for big goals like 'Launch Website' or 'Learn Spanish'. You can see project completion percentages and stay motivated by your progress! 📁📈";
    }
    
    return null; // No quick response found
  }
  
  /// Get the current configuration status with details
  static Map<String, dynamic> getConfigurationStatus() {
    return {
      'isConfigured': isConfigured,
      'model': _model,
      'maxTokens': _maxTokens,
      'temperature': _temperature,
      'apiKeySet': isConfigured,
      'apiKeyPreview': isConfigured ? '${_apiKey.substring(0, 7)}...' : 'Not set',
      'envInitialized': EnvConfig.isInitialized,
      'service': 'Google Gemini',
    };
  }
  
  /// Validate API key format (basic check)
  static bool isValidApiKeyFormat(String apiKey) {
    return apiKey.isNotEmpty && apiKey.length > 10;
  }
  
  /// Get pricing and feature information
  static Map<String, String> getServiceInfo() {
    return {
      'service': 'Google Gemini',
      'model': _model,
      'maxTokens': _maxTokens.toString(),
      'temperature': _temperature.toString(),
      'pricing': 'Free tier available',
      'features': 'Fast, accurate, multimodal',
      'provider': 'Google AI',
    };
  }
}
