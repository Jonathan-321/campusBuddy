import 'package:equatable/equatable.dart';
import '../../../data/models/ai_message_model.dart';

/// Base class for AI assistant events
abstract class AiAssistantEvent extends Equatable {
  const AiAssistantEvent();

  @override
  List<Object?> get props => [];
}

/// Event to send a message to the AI assistant
class SendMessage extends AiAssistantEvent {
  final String message;
  final String? systemPrompt;
  final String? conversationId;

  const SendMessage({
    required this.message,
    this.systemPrompt,
    this.conversationId,
  });

  @override
  List<Object?> get props => [message, systemPrompt, conversationId];
}

/// Event to clear the conversation history
class ClearConversation extends AiAssistantEvent {}

/// Event to change the system prompt
class ChangeSystemPrompt extends AiAssistantEvent {
  final String systemPrompt;

  const ChangeSystemPrompt({required this.systemPrompt});

  @override
  List<Object> get props => [systemPrompt];
}

/// Event to load a conversation by ID
class LoadConversation extends AiAssistantEvent {
  final String conversationId;

  const LoadConversation({required this.conversationId});

  @override
  List<Object> get props => [conversationId];
}

/// Event to save the current conversation
class SaveConversation extends AiAssistantEvent {
  final String? title;

  const SaveConversation({this.title});

  @override
  List<Object?> get props => [title];
}

/// Event to load all saved conversations
class LoadAllConversations extends AiAssistantEvent {}

/// Event to delete a conversation
class DeleteConversation extends AiAssistantEvent {
  final String conversationId;

  const DeleteConversation({required this.conversationId});

  @override
  List<Object> get props => [conversationId];
}

/// Event to start a new conversation
class StartNewConversation extends AiAssistantEvent {}
