import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

// --- Events ---
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object> get props => [];
}

class LoadMessages extends ChatEvent {
  final String otherUserId;
  const LoadMessages(this.otherUserId);
  @override
  List<Object> get props => [otherUserId];
}

class SendMessage extends ChatEvent {
  final String receiverId;
  final String content;
  final MessageType type;

  const SendMessage({
    required this.receiverId,
    required this.content,
    this.type = MessageType.text,
  });

  @override
  List<Object> get props => [receiverId, content, type];
}

class LoadRecentChats extends ChatEvent {}

// --- States ---
abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  const ChatLoaded(this.messages);
  @override
  List<Object> get props => [messages];
}

class RecentChatsLoaded extends ChatState {
  final List<String> partnerIds;
  const RecentChatsLoaded(this.partnerIds);
  @override
  List<Object> get props => [partnerIds];
}

class ChatOperationFailure extends ChatState {
  final String message;
  const ChatOperationFailure(this.message);
  @override
  List<Object> get props => [message];
}

// --- BLoC ---
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  final String currentUserId; // Injected
  StreamSubscription? _messagesSubscription;

  ChatBloc({required this.repository, required this.currentUserId})
      : super(ChatInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<LoadRecentChats>(_onLoadRecentChats);
    addInternalHandlers();
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    await _messagesSubscription?.cancel();

    _messagesSubscription = repository
        .getMessages(currentUserId, event.otherUserId)
        .listen((failureOrMessages) {
      // Since this is a stream inside BLoC, we usually add another event or emit directly
      // But emit is safer if we are not using transformers that can conflict
      // However, listen callback is outside the handler's async scope if we are not careful
      // The proper Bloc way is usually: await emit.forEach(...)
      // But for simplicity with Either, we'll dispatch an internal event or just use this callback carefully
      // Actually, emit.forEach is better.
      // Let's rewrite using a different approach or just manual subscription management which is fine
      // provided we don't emit after close.
      if (!isClosed) {
        failureOrMessages.fold(
          (failure) => add(_InternalChatError(failure.message)),
          (messages) => add(_InternalMessagesUpdated(messages)),
        );
      }
    });

    // Mark as read immediately when entering chat
    repository.markAsRead(currentUserId, event.otherUserId);
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final message = ChatMessage(
      id: const Uuid().v4(),
      senderId: currentUserId,
      receiverId: event.receiverId,
      content: event.content,
      timestamp: DateTime.now(),
      type: event.type,
    );

    // Optimistic update could happen here if we manage local list
    // But since we listen to the stream, it will update automatically

    final result = await repository.sendMessage(message);
    result.fold(
      (failure) => emit(ChatOperationFailure(failure.message)),
      (_) => null, // Success, stream will update
    );
  }

  Future<void> _onLoadRecentChats(
    LoadRecentChats event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    // Using emit.forEach for the partners stream
    await emit.forEach<Either<Failure, List<String>>>(
      repository.getRecentChatPartners(currentUserId),
      onData: (failureOrPartners) => failureOrPartners.fold(
        (failure) => ChatOperationFailure(failure.message),
        (partners) => RecentChatsLoaded(partners),
      ),
    );
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}

// Internal events for stream bridging
class _InternalMessagesUpdated extends ChatEvent {
  final List<ChatMessage> messages;
  const _InternalMessagesUpdated(this.messages);
}

class _InternalChatError extends ChatEvent {
  final String message;
  const _InternalChatError(this.message);
}

// Register internal handlers extension
extension InternalHandlers on ChatBloc {
  void addInternalHandlers() {
    on<_InternalMessagesUpdated>((event, emit) {
      emit(ChatLoaded(event.messages));
    });
    on<_InternalChatError>((event, emit) {
      emit(ChatOperationFailure(event.message));
    });
  }
}
