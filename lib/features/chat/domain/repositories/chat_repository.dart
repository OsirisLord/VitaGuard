import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  /// Sends a message.
  Future<Either<Failure, void>> sendMessage(ChatMessage message);

  /// Gets a real-time stream of messages for a chat room.
  Stream<Either<Failure, List<ChatMessage>>> getMessages(
      String currentUserId, String otherUserId);

  /// Gets a list of recent chats/conversations for the user.
  /// Returns a list of user IDs or detailed convo objects involved.
  Stream<Either<Failure, List<String>>> getRecentChatPartners(String userId);

  /// Marks messages as read.
  Future<Either<Failure, void>> markAsRead(String currentUserId, String senderId);
}
