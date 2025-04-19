import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/ai_message_model.dart';
import '../../domain/usecases/ai_assistant_usecase.dart';
import '../blocs/ai_assistant/ai_assistant_bloc.dart';
import '../blocs/ai_assistant/ai_assistant_event.dart';
import '../blocs/ai_assistant/ai_assistant_state.dart';
import '../widgets/chat_message_bubble.dart';
import 'conversation_history_screen.dart';

class CampusOracleScreen extends StatefulWidget {
  const CampusOracleScreen({Key? key}) : super(key: key);

  @override
  State<CampusOracleScreen> createState() => _CampusOracleScreenState();
}

class _CampusOracleScreenState extends State<CampusOracleScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AiAssistantBloc _aiAssistantBloc;

  @override
  void initState() {
    super.initState();
    // Initialize AI assistant BLoC
    _aiAssistantBloc = AiAssistantBloc(
      aiAssistantUseCase: AiAssistantUseCase(),
    );

    // Load saved conversations
    _aiAssistantBloc.add(LoadAllConversations());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _aiAssistantBloc.close();
    super.dispose();
  }

  // Scroll to bottom of chat
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // Send message to AI assistant
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _aiAssistantBloc.add(SendMessage(message: message));
    _messageController.clear();
    _scrollToBottom();
  }

  // Show save conversation dialog
  void _showSaveDialog() {
    final TextEditingController titleController = TextEditingController();
    final state = _aiAssistantBloc.state;

    // Default title based on first user message
    if (state.messages.isNotEmpty) {
      final firstUserMsg = state.messages.firstWhere(
        (msg) => msg.type == MessageType.user,
        orElse: () => state.messages.first,
      );

      final title = firstUserMsg.content.split('\n').first;
      titleController.text =
          title.length > 30 ? '${title.substring(0, 30)}...' : title;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Conversation'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Conversation title',
            hintText: 'Enter a title for this conversation',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              _aiAssistantBloc.add(SaveConversation(
                title: titleController.text.isNotEmpty
                    ? titleController.text
                    : 'Conversation ${DateTime.now().toIso8601String().substring(0, 10)}',
              ));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conversation saved'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  // Show conversation history
  void _showConversationHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: _aiAssistantBloc,
          child: ConversationHistoryScreen(
            onConversationSelected: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _aiAssistantBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Campus Oracle'),
          actions: [
            // Saved conversations button
            BlocBuilder<AiAssistantBloc, AiAssistantState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: _showConversationHistory,
                  tooltip: 'Conversation history',
                );
              },
            ),
            // Save conversation button
            BlocBuilder<AiAssistantBloc, AiAssistantState>(
              builder: (context, state) {
                return IconButton(
                  icon: Icon(
                    Icons.bookmark,
                    color: state.isSaved ? Colors.yellow : null,
                  ),
                  onPressed: state.messages.isEmpty ? null : _showSaveDialog,
                  tooltip: 'Save conversation',
                );
              },
            ),
            // Clear conversation button
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _aiAssistantBloc.add(ClearConversation());
              },
              tooltip: 'Clear conversation',
            ),
          ],
        ),
        body: Column(
          children: [
            // Chat messages area
            Expanded(
              child: BlocConsumer<AiAssistantBloc, AiAssistantState>(
                listener: (context, state) {
                  if (state.messages.isNotEmpty) {
                    _scrollToBottom();
                  }
                },
                builder: (context, state) {
                  if (state.messages.isEmpty) {
                    return _buildEmptyState();
                  } else {
                    return _buildChatMessages(state.messages);
                  }
                },
              ),
            ),

            // Error message area
            BlocBuilder<AiAssistantBloc, AiAssistantState>(
              builder: (context, state) {
                if (state.errorMessage != null) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red.shade100,
                    width: double.infinity,
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Message input area
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Message input field
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Ask me anything...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Send button
                    BlocBuilder<AiAssistantBloc, AiAssistantState>(
                      builder: (context, state) {
                        return IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: state.isLoading ? null : _sendMessage,
                          color: Theme.of(context).primaryColor,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Campus Oracle',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask me anything about campus life!',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.smart_toy),
            label: const Text('Start a conversation'),
            onPressed: () {
              _messageController.text =
                  'Hello! Can you help me with something?';
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
        ],
      ),
    );
  }

  // Build chat messages list
  Widget _buildChatMessages(List<AiMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return ChatMessageBubble(message: messages[index]);
      },
    );
  }
}
