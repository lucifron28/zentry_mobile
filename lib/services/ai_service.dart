import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'env_config.dart';

/// Zenturion AI Service - OpenAI Integration with Environment Configuration
/// 
/// SETUP INSTRUCTIONS:
/// 1. Get your OpenAI API key from: https://platform.openai.com/api-keys
/// 2. Copy .env.example to .env
/// 3. Replace 'your_openai_api_key_here' in .env with your actual API key
/// 4. Ensure you have credits in your OpenAI account
/// 5. Test the integration by chatting with Zenturion
/// 
/// FEATURES:
/// - Environment-based configuration (.env file)
/// - GPT-3.5-turbo for fast, cost-effective responses
/// - Conversation history support (last 10 messages)
/// - Smart error handling with fallback responses
/// - Mobile-optimized response length (configurable via .env)
/// 
/// ESTIMATED COSTS:
/// - Input: $0.0015 per 1K tokens
/// - Output: $0.002 per 1K tokens  
/// - Typical conversation: ~$0.001-0.005 per message
class AIService {
  // OpenAI API base URL
  static const String _baseUrl = 'https://api.openai.com/v1';
  
  // Configuration getters from environment
  static String get _apiKey => EnvConfig.openAIApiKey;
  static String get _model => EnvConfig.openAIModel;
  static int get _maxTokens => EnvConfig.openAIMaxTokens;
  static double get _temperature => EnvConfig.openAITemperature;
  
  static bool get isConfigured => EnvConfig.isOpenAIConfigured;
  
  /// Send a message to the OpenAI assistant
  static Future<String> sendMessage(String message, {
    List<Map<String, String>>? conversationHistory,
  }) async {
    if (!isConfigured) {
      // Fallback to placeholder response if not configured
      await Future.delayed(const Duration(seconds: 1));
      return _generatePlaceholderResponse(message);
    }
    
    try {
      // Prepare conversation messages for OpenAI
      final List<Map<String, String>> messages = [
        {
          'role': 'system',
          'content': _getSystemPrompt(),
        },
      ];
      
      // Add conversation history if provided
      if (conversationHistory != null) {
        messages.addAll(conversationHistory);
      }
      
      // Add the current user message
      messages.add({
        'role': 'user',
        'content': message,
      });
      
      // Make API call to OpenAI
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': _model,
          'messages': messages,
          'max_tokens': _maxTokens, // From environment config
          'temperature': _temperature, // From environment config
          'top_p': 1.0,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
        }),
      ).timeout(
        const Duration(seconds: 30), // 30-second timeout
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aiResponse = data['choices'][0]['message']['content'] as String;
        return aiResponse.trim();
      } else if (response.statusCode == 401) {
        throw Exception('Invalid OpenAI API key. Please check your configuration.');
      } else if (response.statusCode == 429) {
        throw Exception('OpenAI API rate limit exceeded. Please try again later.');
      } else if (response.statusCode == 500) {
        throw Exception('OpenAI service is currently unavailable. Please try again later.');
      } else {
        throw Exception('Failed to get AI response: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on http.ClientException {
      throw Exception('Network error. Please try again.');
    } catch (e) {
      // Fallback to placeholder response on any error
      return _generatePlaceholderResponse(message);
    }
  }
  
  static String _getSystemPrompt() {
    return '''You are Zenturion, an AI productivity assistant integrated into a Flutter mobile app called Zentry. You are designed to help users manage their tasks, projects, and achieve their productivity goals through gamification.

CONTEXT: Users interact with you through a mobile chat interface. Keep responses concise, helpful, and engaging.

KEY FEATURES YOU CAN HELP WITH:
• Task management and prioritization
• Project organization and planning  
• Achievement tracking and motivation
• Productivity tips and insights
• Goal setting and progress monitoring
• Time management strategies
• Habit formation and maintenance

PERSONALITY: Be encouraging, supportive, and motivational. Use a friendly but professional tone. Celebrate user achievements and provide actionable advice.

RESPONSE GUIDELINES:
• Keep responses under 200 words for mobile readability
• Use bullet points or numbered lists when appropriate
• Provide specific, actionable advice
• Ask follow-up questions to better understand user needs
• Reference gamification elements (XP, achievements, levels) when relevant
• Be empathetic and understanding of productivity challenges

Remember: You're helping users build better productivity habits through the Zentry app's gamified system.''';
  }
  
  static String _generatePlaceholderResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('task') || lowerMessage.contains('todo')) {
      return "I can help you manage your tasks! You can create new tasks, set priorities, and track your progress. Would you like me to help you create a new task or organize your existing ones?";
    } else if (lowerMessage.contains('project')) {
      return "Projects are a great way to organize your work! I can help you break down large projects into manageable tasks, set deadlines, and track progress. What project are you working on?";
    } else if (lowerMessage.contains('achievement') || lowerMessage.contains('goal')) {
      return "Achievements help you stay motivated! You're currently working toward several goals. Keep completing tasks and maintaining streaks to unlock new achievements and earn XP!";
    } else if (lowerMessage.contains('help') || lowerMessage.contains('how')) {
      return "I'm here to help you be more productive! I can assist with:\n• Creating and managing tasks\n• Organizing projects\n• Setting goals and tracking progress\n• Analyzing your productivity patterns\n• Providing motivation and tips\n\nWhat would you like help with?";
    } else if (lowerMessage.contains('motivation') || lowerMessage.contains('productive')) {
      return "Staying motivated is key to productivity! Here are some tips:\n• Break large tasks into smaller, manageable steps\n• Celebrate small wins along the way\n• Set clear, achievable goals\n• Take regular breaks to avoid burnout\n• Track your progress to see how far you've come!";
    } else {
      return "I understand you're looking for assistance with productivity. While I'm still learning about your specific needs, I'm here to help you stay organized and achieve your goals. Could you tell me more about what you'd like to accomplish?";
    }
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
    };
  }
  
  /// Validate API key format (basic check)
  static bool isValidApiKeyFormat(String apiKey) {
    return apiKey.startsWith('sk-') && apiKey.length > 20;
  }
  
  /// Get estimated cost information
  static Map<String, String> getCostInfo() {
    return {
      'model': _model,
      'maxTokens': _maxTokens.toString(),
      'temperature': _temperature.toString(),
      'inputCost': '\$0.0015 per 1K tokens',
      'outputCost': '\$0.002 per 1K tokens',
      'estimatedPerMessage': '~\$0.001-0.005',
    };
  }
}
