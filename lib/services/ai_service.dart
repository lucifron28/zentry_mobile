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
  static Future<String> sendMessage(String message, {
    List<Map<String, String>>? conversationHistory,
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
    
    try {
      if (EnvConfig.debugMode) {
        print('🚀 Making Gemini API request...');
      }
      
      // Prepare conversation content for Gemini
      String fullPrompt = _getSystemPrompt();
      
      // Add conversation history if provided
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        fullPrompt += '\n\n--- Previous conversation ---\n';
        for (final entry in conversationHistory) {
          fullPrompt += '${entry['role'] == 'user' ? 'User' : 'Assistant'}: ${entry['content']}\n';
        }
        fullPrompt += '--- End conversation ---\n\n';
      }
      
      // Add the current user message
      fullPrompt += 'User: $message\n\nAssistant:';
      
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
