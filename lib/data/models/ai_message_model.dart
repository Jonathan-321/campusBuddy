import 'package:equatable/equatable.dart';

/// Type of message in AI conversation
enum MessageType {
  user,
  ai,
  error,
  systemPrompt,
}

/// Model representing a message in an AI conversation
class AiMessage extends Equatable {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isLoading;

  const AiMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isLoading = false,
  });

  /// Create a user message
  factory AiMessage.user({
    required String id,
    required String content,
  }) {
    return AiMessage(
      id: id,
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
  }

  /// Create an AI response message
  factory AiMessage.ai({
    required String id,
    required String content,
    bool isLoading = false,
  }) {
    return AiMessage(
      id: id,
      content: content,
      type: MessageType.ai,
      timestamp: DateTime.now(),
      isLoading: isLoading,
    );
  }

  /// Create an error message
  factory AiMessage.error({
    required String id,
    required String content,
  }) {
    return AiMessage(
      id: id,
      content: content,
      type: MessageType.error,
      timestamp: DateTime.now(),
    );
  }

  /// Create a system prompt message
  factory AiMessage.systemPrompt({
    required String id,
    required String content,
  }) {
    return AiMessage(
      id: id,
      content: content,
      type: MessageType.systemPrompt,
      timestamp: DateTime.now(),
    );
  }

  /// Create a copy of this message with updated properties
  AiMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return AiMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [id, content, type, timestamp, isLoading];
}
