import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../utils/env_config.dart';

/// Service to interact with Claude API
class ClaudeApiService {
  // Direct API URL
  final String baseUrl = 'https://api.anthropic.com/v1/messages';

  // CORS proxy URL for web platform - this is a public CORS proxy for development
  // In production, you should use your own backend proxy
  final String corsProxyUrl =
      'https://cors-anywhere.herokuapp.com/https://api.anthropic.com/v1/messages';

  final String apiKey;
  final String model;

  /// Creates a ClaudeApiService with the given API key and model
  ClaudeApiService({
    String? apiKey,
    String? model,
  })  : apiKey = apiKey ?? EnvConfig.claudeApiKey,
        model = model ?? EnvConfig.claudeModel;

  /// Send a message to Claude API with conversation history for context
  Future<Map<String, dynamic>> sendMessage(
      {required String userMessage,
      required List<Map<String, String>> messageHistory,
      double temperature = 0.7,
      int maxTokens = 1024,
      String systemPrompt = 'You are Campus Buddy, the official AI assistant for Oklahoma Christian University students. '
          'You have comprehensive and authoritative information about Oklahoma Christian University (OC) including: '
          'course offerings, class schedules, academic departments, campus locations, contact information, '
          'housing options, meal plans, upcoming events, services, and important academic dates. '
          'When answering questions about course offerings and schedules: '
          '- Provide specific details about what classes are being offered in the current or upcoming semesters '
          '- State when classes are scheduled (days, times, building locations) '
          '- Identify which professors are teaching specific courses when known '
          '- Include information about course prerequisites and credit hours '
          '- Reference registration deadlines and procedures '
          '- Suggest related or complementary courses when relevant '
          'Be confident and direct with your knowledge. Do not use phrases like "I believe," "I think," or "I\'m not sure." '
          'If information is factual and in your knowledge base, state it authoritatively. '
          'Never apologize for providing information that\'s correct and helpful. '
          'When answering questions, always prioritize Oklahoma Christian University data provided to you. '
          'Be comprehensive about OC\'s academic colleges, departments, programs, course offerings, and degree requirements. '
          'Provide specific details like room numbers, phone numbers, email addresses, operating hours, costs, and deadlines. '
          'Focus on helping students navigate academic planning, course selection, and registration. '
          'For student life questions, provide detailed information about OC\'s housing options, meal plans, spiritual life, and athletics. '
          'If asked about something for which you genuinely don\'t have specific information, briefly acknowledge this '
          'and immediately suggest the most relevant OC resource (specific department, office, website) where the student can find that information. '
          'Always respond in the same language as the user\'s message. '
          'If the user\'s message is in English, respond in English. '
          'If the user\'s message is in Spanish, respond in Spanish. '
          'If the user\'s message is in French, respond in French. '
          'If the user\'s message is in Kinyarwanda, respond in Kinyarwanda.'}) async {
    try {
      // For web platform, we need to handle CORS issues
      // In a real-world scenario, you should have a backend proxy
      final effectiveUrl = kIsWeb ? corsProxyUrl : baseUrl;

      // Headers for the request
      final headers = {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      };

      // For web platform using the CORS proxy, we need to add additional headers
      if (kIsWeb) {
        headers['Origin'] = 'https://campus-buddy.example.com';
        headers['X-Requested-With'] = 'XMLHttpRequest';
      }

      // Ensure messageHistory contains valid content
      final validMessageHistory = messageHistory.where((msg) {
        return msg.containsKey('content') &&
            msg['content'] != null &&
            msg['content']!.isNotEmpty;
      }).toList();

      // Add the current user message
      validMessageHistory.add({
        'role': 'user',
        'content': userMessage,
      });

      // Make the API request
      debugPrint(
          'Sending request to Claude API with ${validMessageHistory.length} messages');
      debugPrint('System prompt length: ${systemPrompt.length} characters');

      final response = await http.post(
        Uri.parse(effectiveUrl),
        headers: headers,
        body: jsonEncode({
          'model': model,
          'messages': validMessageHistory,
          'system': systemPrompt,
          'max_tokens': maxTokens,
          'temperature': temperature,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('Received successful response from Claude API');
        return responseData;
      } else {
        debugPrint('API Error [${response.statusCode}]: ${response.body}');
        throw Exception(
            'Failed to get response: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception in sendMessage: $e');

      // For web platform, provide more helpful error message about CORS
      if (kIsWeb) {
        // When testing on web, show a more informative error message
        return {
          'content': [
            {
              'type': 'text',
              'text': 'Due to CORS restrictions in web browsers, direct API calls to Anthropic\'s API are not possible. '
                  'For a production application, you would need to implement a backend proxy service. '
                  'For testing purposes, you can use a mobile or desktop platform instead.'
            }
          ]
        };
      }

      rethrow;
    }
  }

  /// Convert a simple message to the format Claude expects
  Future<String> getSimpleCompletion(String message) async {
    try {
      final response = await sendMessage(
        userMessage: message,
        messageHistory: [],
      );

      if (response.containsKey('content') &&
          response['content'] is List &&
          response['content'].isNotEmpty) {
        return response['content'][0]['text'];
      }

      return 'Error: Unable to parse response from Claude API';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
