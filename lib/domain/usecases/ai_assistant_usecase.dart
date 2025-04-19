import 'package:uuid/uuid.dart';
import '../../data/models/ai_message_model.dart';
import '../../data/services/ai_service.dart';

/// Use case for interacting with AI assistant
class AiAssistantUseCase {
  final AiService _aiService;
  final Uuid _uuid = const Uuid();

  /// Campus-specific system prompt to guide AI responses
  static const String defaultSystemPrompt = '''
You are Campus Buddy, an AI assistant for university students.
Your goal is to help students with academic questions, campus navigation, 
event information, and general university life advice.
Always be helpful, accurate, and concise.
If you don't know something, be honest about it.
''';

  AiAssistantUseCase({AiService? aiService})
      : _aiService = aiService ?? AiService();

  /// Send a message to the AI and get a response
  ///
  /// Parameters:
  /// - userMessage: The message from the user
  /// - systemPrompt: Optional custom system prompt
  /// - previousMessages: Optional list of previous messages for context
  ///
  /// Returns an AiMessage with the AI's response
  Future<AiMessage> sendMessage({
    required String userMessage,
    String? systemPrompt,
    List<AiMessage>? previousMessages,
  }) async {
    try {
      // Convert previous messages to API format if provided
      List<Map<String, dynamic>>? apiMessages;
      if (previousMessages != null && previousMessages.isNotEmpty) {
        apiMessages = previousMessages
            .where((msg) =>
                msg.type == MessageType.user || msg.type == MessageType.ai)
            .map((msg) => {
                  'role': msg.type == MessageType.user ? 'user' : 'assistant',
                  'content': msg.content,
                })
            .toList();
      }

      // Get response from AI service with the provided system prompt
      final response = await _aiService.getChatCompletion(
        prompt: userMessage,
        systemPrompt: systemPrompt ?? defaultSystemPrompt,
        previousMessages: apiMessages,
      );

      // Check if response contains an error
      if (response.startsWith('Error:')) {
        return AiMessage.error(
          id: _uuid.v4(),
          content: response,
        );
      }

      // Return AI message
      return AiMessage.ai(
        id: _uuid.v4(),
        content: response,
      );
    } catch (e) {
      return AiMessage.error(
        id: _uuid.v4(),
        content: 'An unexpected error occurred: $e',
      );
    }
  }
}
