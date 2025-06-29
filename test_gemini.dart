#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Simple test script to verify Gemini API connectivity
// Usage: dart test_gemini.dart [your_api_key]

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart test_gemini.dart [your_api_key]');
    print('');
    print('This script tests the Gemini API integration.');
    print('Get your API key from: https://makersuite.google.com/app/apikey');
    exit(1);
  }

  final apiKey = args[0];
  print('🧪 Testing Gemini API with key: ${apiKey.substring(0, 7)}...');

  try {
    final response = await testGeminiAPI(apiKey);
    print('✅ Success! Gemini API is working correctly.');
    print('📝 Response: $response');
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}

Future<String> testGeminiAPI(String apiKey) async {
  const baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  const model = 'gemini-1.5-flash';
  
  final requestBody = {
    'contents': [
      {
        'parts': [
          {
            'text': 'Hello! Please respond with a brief greeting to confirm the API is working.',
          }
        ]
      }
    ],
    'generationConfig': {
      'temperature': 0.7,
      'maxOutputTokens': 100,
    }
  };

  final response = await http.post(
    Uri.parse('$baseUrl/models/$model:generateContent?key=$apiKey'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode(requestBody),
  ).timeout(const Duration(seconds: 30));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['candidates'] != null && 
        data['candidates'].isNotEmpty &&
        data['candidates'][0]['content'] != null &&
        data['candidates'][0]['content']['parts'] != null &&
        data['candidates'][0]['content']['parts'].isNotEmpty) {
      
      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } else {
      throw Exception('No valid response from Gemini API');
    }
  } else {
    final errorData = json.decode(response.body);
    final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
    throw Exception('API Error (${response.statusCode}): $errorMessage');
  }
}
