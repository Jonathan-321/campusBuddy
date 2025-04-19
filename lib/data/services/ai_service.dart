import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../utils/env_config.dart';
import 'claude_api_service.dart';

/// Service to interact with AI models API
class AiService {
  final ClaudeApiService _claudeApiService;
  String? _universityData;

  AiService({ClaudeApiService? claudeApiService})
      : _claudeApiService = claudeApiService ?? ClaudeApiService();

  /// Load the Oklahoma Christian University data from JSON file
  Future<void> loadUniversityData() async {
    try {
      debugPrint('Attempting to load university data from assets...');
      final String data = await rootBundle
          .loadString('assets/oklahoma_christian_university_data.json');

      if (data.isNotEmpty) {
        // Validate JSON data
        try {
          // Try to parse the JSON to verify it's valid
          final jsonData = json.decode(data);
          debugPrint(
              'University data loaded and parsed successfully (${data.length} characters)');
          _universityData = data;
        } catch (parseError) {
          debugPrint('Error parsing university data JSON: $parseError');
          _universityData = null;
        }
      } else {
        debugPrint('University data file was empty');
        _universityData = null;
      }
    } catch (e) {
      debugPrint('Error loading university data: $e');
      _universityData = null;
    }
  }

  /// Get the enhanced system prompt with university data
  Future<String> getEnhancedSystemPrompt(String? basePrompt) async {
    // Load university data if not already loaded
    if (_universityData == null) {
      debugPrint('University data not loaded yet, loading now...');
      await loadUniversityData();
    }

    final systemPrompt = basePrompt ?? AiService.defaultSystemPrompt;

    // If university data was loaded successfully, enhance the prompt
    if (_universityData != null) {
      debugPrint('Enhancing system prompt with university data');
      final enhancedPrompt = '''
$systemPrompt

Use the following detailed information about Oklahoma Christian University as a reference:
$_universityData

When answering questions about Oklahoma Christian University, use this information as the primary source.
''';

      // Log the first 200 characters of the enhanced prompt for debugging
      debugPrint(
          'Enhanced prompt created (total length: ${enhancedPrompt.length} characters)');
      return enhancedPrompt;
    } else {
      debugPrint(
          'Warning: Using base system prompt without university data enhancement');
    }

    // Otherwise, just return the original system prompt
    return systemPrompt;
  }

  /// Send a message to Claude API and get a response
  ///
  /// Parameters:
  /// - prompt: The user's message to send to the AI
  /// - systemPrompt: Optional system instructions to guide the AI
  /// - previousMessages: Optional list of previous messages for context
  ///
  /// Returns the AI's response as a String
  Future<String> getChatCompletion({
    required String prompt,
    String? systemPrompt,
    List<Map<String, dynamic>>? previousMessages,
  }) async {
    try {
      // Get enhanced system prompt with university data
      final enhancedSystemPrompt = await getEnhancedSystemPrompt(systemPrompt);

      // Convert previous messages to format expected by Claude API
      List<Map<String, String>> claudeMessages = [];

      if (previousMessages != null && previousMessages.isNotEmpty) {
        for (final msg in previousMessages) {
          if (msg.containsKey('role') && msg.containsKey('content')) {
            final role = msg['role'] as String;
            final content = msg['content'] as String;

            // Only add messages with non-empty content
            if (content.isNotEmpty) {
              claudeMessages.add({
                'role': role,
                'content': content,
              });
            }
          }
        }
      }

      // Send request to Claude API
      final response = await _claudeApiService.sendMessage(
        userMessage: prompt,
        messageHistory: claudeMessages,
        systemPrompt: enhancedSystemPrompt,
      );

      // Extract text from response
      if (response.containsKey('content') &&
          response['content'] is List &&
          response['content'].isNotEmpty) {
        return response['content'][0]['text'];
      }

      return 'Error: Unable to parse response from Claude API';
    } catch (e) {
      debugPrint('Exception in AI service: $e');
      return 'Error: Failed to connect to AI service. Please try again later.';
    }
  }

  /// Default system prompt for the AI assistant
  static const String defaultSystemPrompt = '''
You are Campus Buddy, an AI assistant for university students.
Your goal is to help students with academic questions, campus navigation, 
event information, and general university life advice.
Always be helpful, accurate, and concise.
If you don't know something, be honest about it.
''';
}
