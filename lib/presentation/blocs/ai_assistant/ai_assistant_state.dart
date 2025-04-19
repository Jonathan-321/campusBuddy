import 'package:equatable/equatable.dart';
import '../../../data/models/ai_message_model.dart';
import '../../../data/models/conversation_model.dart';

/// Base class for AI assistant states
class AiAssistantState extends Equatable {
  final List<AiMessage> messages;
  final String systemPrompt;
  final bool isLoading;
  final String? errorMessage;
  final String? currentConversationId;
  final List<Conversation> savedConversations;
  final bool isSaved;

  const AiAssistantState({
    this.messages = const [],
    required this.systemPrompt,
    this.isLoading = false,
    this.errorMessage,
    this.currentConversationId,
    this.savedConversations = const [],
    this.isSaved = false,
  });

  @override
  List<Object?> get props => [
        messages,
        systemPrompt,
        isLoading,
        errorMessage,
        currentConversationId,
        savedConversations,
        isSaved,
      ];

  AiAssistantState copyWith({
    List<AiMessage>? messages,
    String? systemPrompt,
    bool? isLoading,
    String? errorMessage,
    String? currentConversationId,
    List<Conversation>? savedConversations,
    bool? isSaved,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentConversationId:
          currentConversationId ?? this.currentConversationId,
      savedConversations: savedConversations ?? this.savedConversations,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

/// Initial state when the AI assistant is first loaded
class AiAssistantInitial extends AiAssistantState {
  AiAssistantInitial({required String systemPrompt})
      : super(systemPrompt: systemPrompt);
}
