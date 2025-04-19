import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/conversation_model.dart';
import '../models/ai_message_model.dart';

/// Service to handle storage and retrieval of AI conversations
class ConversationStorageService {
  static const String _conversationsKey = 'ai_conversations';
  static const int _maxStoredConversations = 50;
  final Uuid _uuid = const Uuid();

  /// Get all stored conversations
  Future<List<Conversation>> getAllConversations() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? conversationsJson = prefs.getString(_conversationsKey);

      if (conversationsJson == null || conversationsJson.isEmpty) {
        return [];
      }

      final List<dynamic> conversationsData = json.decode(conversationsJson);
      final List<Conversation> conversations =
          conversationsData.map((data) => Conversation.fromJson(data)).toList();

      // Sort by most recent first
      conversations.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));

      return conversations;
    } catch (e) {
      debugPrint('Error getting conversations: $e');
      return [];
    }
  }

  /// Get a specific conversation by ID
  Future<Conversation?> getConversation(String id) async {
    try {
      final List<Conversation> conversations = await getAllConversations();
      return conversations.firstWhere((conversation) => conversation.id == id);
    } catch (e) {
      debugPrint('Error getting conversation: $e');
      return null;
    }
  }

  /// Save a new conversation
  Future<bool> saveConversation(Conversation conversation) async {
    try {
      final List<Conversation> conversations = await getAllConversations();

      // Check if the conversation already exists
      final existingIndex =
          conversations.indexWhere((c) => c.id == conversation.id);

      if (existingIndex >= 0) {
        // Update existing conversation
        conversations[existingIndex] = conversation;
      } else {
        // Add new conversation
        conversations.add(conversation);
      }

      // Limit the number of stored conversations
      if (conversations.length > _maxStoredConversations) {
        conversations
            .sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
        conversations.removeRange(
            _maxStoredConversations, conversations.length);
      }

      // Save to shared preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String conversationsJson =
          json.encode(conversations.map((c) => c.toJson()).toList());

      return await prefs.setString(_conversationsKey, conversationsJson);
    } catch (e) {
      debugPrint('Error saving conversation: $e');
      return false;
    }
  }

  /// Delete a conversation by ID
  Future<bool> deleteConversation(String id) async {
    try {
      final List<Conversation> conversations = await getAllConversations();
      conversations.removeWhere((conversation) => conversation.id == id);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String conversationsJson =
          json.encode(conversations.map((c) => c.toJson()).toList());

      return await prefs.setString(_conversationsKey, conversationsJson);
    } catch (e) {
      debugPrint('Error deleting conversation: $e');
      return false;
    }
  }

  /// Create a new conversation from messages
  Future<Conversation> createConversation(List<AiMessage> messages,
      {String? title}) async {
    final id = _uuid.v4();
    final conversation = Conversation.create(
      id: id,
      messages: messages,
      title: title,
    );

    await saveConversation(conversation);
    return conversation;
  }

  /// Update an existing conversation with new messages
  Future<bool> updateConversation(String id, List<AiMessage> messages) async {
    try {
      final conversation = await getConversation(id);

      if (conversation == null) {
        return false;
      }

      final updatedConversation = conversation.copyWith(
        messages: messages,
        lastUpdatedAt: DateTime.now(),
      );

      return await saveConversation(updatedConversation);
    } catch (e) {
      debugPrint('Error updating conversation: $e');
      return false;
    }
  }

  /// Clear all stored conversations
  Future<bool> clearAllConversations() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_conversationsKey);
    } catch (e) {
      debugPrint('Error clearing conversations: $e');
      return false;
    }
  }
}
