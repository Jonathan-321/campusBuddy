import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/usecases/ai_assistant_usecase.dart';
import '../../../data/models/ai_message_model.dart';
import '../../../data/models/conversation_model.dart';
import '../../../data/services/conversation_storage_service.dart';
import 'ai_assistant_event.dart';
import 'ai_assistant_state.dart';

/// BLoC for managing AI assistant state
class AiAssistantBloc extends Bloc<AiAssistantEvent, AiAssistantState> {
  final AiAssistantUseCase _aiAssistantUseCase;
  final ConversationStorageService _storageService;
  final Uuid _uuid = const Uuid();

  AiAssistantBloc({
    required AiAssistantUseCase aiAssistantUseCase,
    ConversationStorageService? storageService,
    String? initialSystemPrompt,
  })  : _aiAssistantUseCase = aiAssistantUseCase,
        _storageService = storageService ?? ConversationStorageService(),
        super(AiAssistantInitial(
          systemPrompt:
              initialSystemPrompt ?? AiAssistantUseCase.defaultSystemPrompt,
        )) {
    on<SendMessage>(_onSendMessage);
    on<ClearConversation>(_onClearConversation);
    on<ChangeSystemPrompt>(_onChangeSystemPrompt);
    on<LoadConversation>(_onLoadConversation);
    on<SaveConversation>(_onSaveConversation);
    on<LoadAllConversations>(_onLoadAllConversations);
    on<DeleteConversation>(_onDeleteConversation);
    on<StartNewConversation>(_onStartNewConversation);
  }

  /// Handle sending a message to the AI assistant
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<AiAssistantState> emit,
  ) async {
    // Create user message
    final userMessage = AiMessage.user(
      id: _uuid.v4(),
      content: event.message,
    );

    // Create temporary AI message for loading state
    final tempAiMessage = AiMessage.ai(
      id: _uuid.v4(),
      content: '',
      isLoading: true,
    );

    // Update state with user message and loading AI message
    final updatedMessages = List<AiMessage>.from(state.messages)
      ..add(userMessage)
      ..add(tempAiMessage);

    emit(state.copyWith(
      messages: updatedMessages,
      isLoading: true,
      isSaved: false,
    ));

    // Send message to AI assistant usecase
    final aiResponse = await _aiAssistantUseCase.sendMessage(
      userMessage: event.message,
      systemPrompt: event.systemPrompt ?? state.systemPrompt,
      previousMessages: state.messages,
    );

    // Remove loading message and add real response
    final finalMessages = List<AiMessage>.from(state.messages)
      ..removeLast() // Remove the loading message
      ..add(aiResponse);

    // Update state with AI response
    emit(state.copyWith(
      messages: finalMessages,
      isLoading: false,
      errorMessage:
          aiResponse.type == MessageType.error ? aiResponse.content : null,
    ));

    // If this is part of an existing conversation, update it
    if (state.currentConversationId != null) {
      await _storageService.updateConversation(
        state.currentConversationId!,
        finalMessages,
      );
      emit(state.copyWith(isSaved: true));
    }
  }

  /// Handle clearing the conversation
  void _onClearConversation(
    ClearConversation event,
    Emitter<AiAssistantState> emit,
  ) {
    emit(state.copyWith(
      messages: [],
      errorMessage: null,
      currentConversationId: null,
      isSaved: false,
    ));
  }

  /// Handle changing the system prompt
  void _onChangeSystemPrompt(
    ChangeSystemPrompt event,
    Emitter<AiAssistantState> emit,
  ) {
    emit(state.copyWith(
      systemPrompt: event.systemPrompt,
    ));
  }

  /// Handle loading a conversation by ID
  Future<void> _onLoadConversation(
    LoadConversation event,
    Emitter<AiAssistantState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final conversation =
        await _storageService.getConversation(event.conversationId);

    if (conversation != null) {
      emit(state.copyWith(
        messages: conversation.messages,
        currentConversationId: conversation.id,
        isLoading: false,
        isSaved: true,
      ));
    } else {
      emit(state.copyWith(
        errorMessage: 'Conversation not found',
        isLoading: false,
      ));
    }
  }

  /// Handle saving the current conversation
  Future<void> _onSaveConversation(
    SaveConversation event,
    Emitter<AiAssistantState> emit,
  ) async {
    if (state.messages.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Cannot save an empty conversation',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      Conversation conversation;

      if (state.currentConversationId != null) {
        // Update existing conversation
        final existing =
            await _storageService.getConversation(state.currentConversationId!);
        if (existing != null) {
          conversation = existing.copyWith(
            messages: state.messages,
            title: event.title ?? existing.title,
            lastUpdatedAt: DateTime.now(),
          );
          await _storageService.saveConversation(conversation);
        } else {
          // Create new if not found
          conversation = await _storageService.createConversation(
            state.messages,
            title: event.title,
          );
        }
      } else {
        // Create new conversation
        conversation = await _storageService.createConversation(
          state.messages,
          title: event.title,
        );
      }

      // Update conversations list
      final conversations = await _storageService.getAllConversations();

      emit(state.copyWith(
        currentConversationId: conversation.id,
        savedConversations: conversations,
        isLoading: false,
        isSaved: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to save conversation: $e',
        isLoading: false,
      ));
    }
  }

  /// Handle loading all saved conversations
  Future<void> _onLoadAllConversations(
    LoadAllConversations event,
    Emitter<AiAssistantState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final conversations = await _storageService.getAllConversations();

      emit(state.copyWith(
        savedConversations: conversations,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load conversations: $e',
        isLoading: false,
      ));
    }
  }

  /// Handle deleting a conversation
  Future<void> _onDeleteConversation(
    DeleteConversation event,
    Emitter<AiAssistantState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      await _storageService.deleteConversation(event.conversationId);

      // Update conversations list
      final conversations = await _storageService.getAllConversations();

      // If we're deleting the current conversation, clear it
      final updatedCurrentId =
          state.currentConversationId == event.conversationId
              ? null
              : state.currentConversationId;

      final updatedMessages =
          state.currentConversationId == event.conversationId
              ? <AiMessage>[]
              : state.messages;

      emit(state.copyWith(
        savedConversations: conversations,
        currentConversationId: updatedCurrentId,
        messages: updatedMessages,
        isLoading: false,
        isSaved: updatedCurrentId != null,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to delete conversation: $e',
        isLoading: false,
      ));
    }
  }

  /// Handle starting a new conversation
  void _onStartNewConversation(
    StartNewConversation event,
    Emitter<AiAssistantState> emit,
  ) {
    emit(state.copyWith(
      messages: [],
      currentConversationId: null,
      errorMessage: null,
      isSaved: false,
    ));
  }
}
