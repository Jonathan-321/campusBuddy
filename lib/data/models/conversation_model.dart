import 'package:equatable/equatable.dart';
import 'ai_message_model.dart';

/// Model representing a stored conversation
class Conversation extends Equatable {
  final String id;
  final String title;
  final List<AiMessage> messages;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;

  const Conversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  /// Create a new conversation with a default title based on first message
  factory Conversation.create({
    required String id,
    required List<AiMessage> messages,
    String? title,
  }) {
    final now = DateTime.now();
    // Generate a title based on the first user message if not provided
    final defaultTitle =
        messages.isNotEmpty && messages.first.type == MessageType.user
            ? messages.first.content.split('\n').first.substring(
                0,
                messages.first.content.split('\n').first.length > 30
                    ? 30
                    : messages.first.content.split('\n').first.length)
            : 'New Conversation';

    return Conversation(
      id: id,
      title: title ?? defaultTitle,
      messages: messages,
      createdAt: now,
      lastUpdatedAt: now,
    );
  }

  /// Create a copy with updated values
  Conversation copyWith({
    String? id,
    String? title,
    List<AiMessage>? messages,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  /// Convert to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages
          .map((message) => {
                'id': message.id,
                'content': message.content,
                'type': message.type.toString().split('.').last,
                'timestamp': message.timestamp.toIso8601String(),
                'isLoading': message.isLoading,
              })
          .toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }

  /// Create from a JSON map
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'],
      messages: (json['messages'] as List).map((messageJson) {
        final typeString = messageJson['type'];
        final MessageType type = MessageType.values.firstWhere(
          (e) => e.toString().split('.').last == typeString,
          orElse: () => MessageType.user,
        );

        return AiMessage(
          id: messageJson['id'],
          content: messageJson['content'],
          type: type,
          timestamp: DateTime.parse(messageJson['timestamp']),
          isLoading: messageJson['isLoading'] ?? false,
        );
      }).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt']),
    );
  }

  @override
  List<Object?> get props => [id, title, messages, createdAt, lastUpdatedAt];
}
