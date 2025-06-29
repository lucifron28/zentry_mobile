import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

/// Environment Configuration Service
/// 
/// Manages environment variables and app configuration.
/// Call EnvConfig.init() in main() before runApp().
class EnvConfig {
  static bool _initialized = false;
  
  /// Initialize environment configuration
  /// Call this in main() before runApp()
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
      _initialized = true;
    } catch (e) {
      // Handle missing .env file gracefully
      if (kDebugMode) {
        print('Warning: .env file not found or invalid. Using default values.');
      }
      _initialized = false;
    }
  }
  
  /// Check if environment is properly initialized
  static bool get isInitialized => _initialized;
  
  // Google Gemini Configuration (Primary AI Service)
  static String get geminiApiKey => 
      dotenv.env['GEMINI_API_KEY'] ?? 'your_gemini_api_key_here';
  
  static String get geminiModel => 
      dotenv.env['GEMINI_MODEL'] ?? 'gemini-1.5-flash';
  
  static int get geminiMaxTokens => 
      int.tryParse(dotenv.env['GEMINI_MAX_TOKENS'] ?? '2048') ?? 2048;
  
  static double get geminiTemperature => 
      double.tryParse(dotenv.env['GEMINI_TEMPERATURE'] ?? '0.7') ?? 0.7;

  // OpenAI Configuration (Legacy - for backward compatibility)
  static String get openAIApiKey => 
      dotenv.env['OPENAI_API_KEY'] ?? 'your_openai_api_key_here';
  
  static String get openAIModel => 
      dotenv.env['OPENAI_MODEL'] ?? 'gpt-3.5-turbo';
  
  static int get openAIMaxTokens => 
      int.tryParse(dotenv.env['OPENAI_MAX_TOKENS'] ?? '500') ?? 500;
  
  static double get openAITemperature => 
      double.tryParse(dotenv.env['OPENAI_TEMPERATURE'] ?? '0.7') ?? 0.7;
  
  // App Configuration
  static String get appName => 
      dotenv.env['APP_NAME'] ?? 'Zentry Mobile';
  
  static String get appVersion => 
      dotenv.env['APP_VERSION'] ?? '1.0.0';
  
  static bool get debugMode => 
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  
  // Optional: Additional AI Services
  static String? get anthropicApiKey => 
      dotenv.env['ANTHROPIC_API_KEY'];
  
  static String? get googleAIApiKey => 
      dotenv.env['GOOGLE_AI_API_KEY'];
  
  // Optional: Backend API
  static String? get apiBaseUrl => 
      dotenv.env['API_BASE_URL'];
  
  static int get apiTimeout => 
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30') ?? 30;
  
  // Optional: Analytics
  static String? get firebaseProjectId => 
      dotenv.env['FIREBASE_PROJECT_ID'];
  
  static String? get mixpanelToken => 
      dotenv.env['MIXPANEL_TOKEN'];
  
  /// Check if Gemini is properly configured
  static bool get isGeminiConfigured => 
      geminiApiKey != 'your_gemini_api_key_here' && 
      geminiApiKey.isNotEmpty;

  /// Check if OpenAI is properly configured (legacy)
  static bool get isOpenAIConfigured => 
      openAIApiKey != 'your_openai_api_key_here' && 
      openAIApiKey.isNotEmpty &&
      openAIApiKey.startsWith('sk-');

  /// Check if any AI service is configured (prioritize Gemini)
  static bool get isAIConfigured => isGeminiConfigured || isOpenAIConfigured;
  
  /// Get configuration summary for debugging
  static Map<String, dynamic> getConfigSummary() {
    return {
      'initialized': _initialized,
      'gemini_configured': isGeminiConfigured,
      'gemini_model': geminiModel,
      'gemini_maxTokens': geminiMaxTokens,
      'gemini_temperature': geminiTemperature,
      'openAI_configured': isOpenAIConfigured,
      'openAI_model': openAIModel,
      'openAI_maxTokens': openAIMaxTokens,
      'openAI_temperature': openAITemperature,
      'ai_configured': isAIConfigured,
      'app_name': appName,
      'app_version': appVersion,
      'debug_mode': debugMode,
      'api_timeout': apiTimeout,
      'has_anthropic_key': anthropicApiKey != null,
      'has_google_ai_key': googleAIApiKey != null,
      'has_backend_url': apiBaseUrl != null,
      'has_firebase_config': firebaseProjectId != null,
      'has_mixpanel_token': mixpanelToken != null,
    };
  }
  
  /// Validate critical configuration
  static List<String> validateConfig() {
    final issues = <String>[];
    
    if (!_initialized) {
      issues.add('.env file not loaded');
    }
    
    if (!isAIConfigured) {
      issues.add('No AI service configured (Gemini or OpenAI)');
    }
    
    if (isGeminiConfigured) {
      if (geminiMaxTokens <= 0) {
        issues.add('Invalid Gemini max tokens value');
      }
      
      if (geminiTemperature < 0 || geminiTemperature > 2) {
        issues.add('Invalid Gemini temperature value (should be 0-2)');
      }
    }
    
    if (isOpenAIConfigured) {
      if (openAIMaxTokens <= 0) {
        issues.add('Invalid OpenAI max tokens value');
      }
      
      if (openAITemperature < 0 || openAITemperature > 2) {
        issues.add('Invalid OpenAI temperature value (should be 0-2)');
      }
    }
    
    return issues;
  }
}
