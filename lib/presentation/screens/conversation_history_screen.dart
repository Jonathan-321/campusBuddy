import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/models/conversation_model.dart';
import '../../data/models/ai_message_model.dart';
import '../blocs/ai_assistant/ai_assistant_bloc.dart';
import '../blocs/ai_assistant/ai_assistant_event.dart';
import '../blocs/ai_assistant/ai_assistant_state.dart';

class ConversationHistoryScreen extends StatelessWidget {
  final Function onConversationSelected;

  const ConversationHistoryScreen({
    Key? key,
    required this.onConversationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Conversations'),
      ),
      body: BlocBuilder<AiAssistantBloc, AiAssistantState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.savedConversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved conversations yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your saved conversations will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: state.savedConversations.length,
            itemBuilder: (context, index) {
              final conversation = state.savedConversations[index];
              final firstUserMessage = conversation.messages.firstWhere(
                (msg) => msg.type == MessageType.user,
                orElse: () => conversation.messages.first,
              );

              final dateFormat = DateFormat('MMM d, yyyy');
              final timeFormat = DateFormat('h:mm a');
              final date = dateFormat.format(conversation.lastUpdatedAt);
              final time = timeFormat.format(conversation.lastUpdatedAt);

              return Dismissible(
                key: Key(conversation.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Conversation'),
                        content: const Text(
                            'Are you sure you want to delete this conversation?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('DELETE'),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  context.read<AiAssistantBloc>().add(
                        DeleteConversation(conversationId: conversation.id),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Conversation deleted'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(
                    conversation.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstUserMessage.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$date at $time',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  leading: const CircleAvatar(
                    child: Icon(Icons.chat),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.read<AiAssistantBloc>().add(
                          LoadConversation(conversationId: conversation.id),
                        );
                    onConversationSelected();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<AiAssistantBloc>().add(StartNewConversation());
          context.pop();
        },
        child: const Icon(Icons.add),
        tooltip: 'New Conversation',
      ),
    );
  }
}
