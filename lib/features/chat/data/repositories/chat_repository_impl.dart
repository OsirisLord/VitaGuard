import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore firestore;

  ChatRepositoryImpl({required this.firestore});

  // Helper to generate consistent Chat Room ID
  String _getChatId(String userA, String userB) {
    return userA.compareTo(userB) < 0 ? '${userA}_$userB' : '${userB}_$userA';
  }

  @override
  Future<Either<Failure, void>> sendMessage(ChatMessage message) async {
    try {
      final chatId = _getChatId(message.senderId, message.receiverId);
      final model = MessageModel.fromEntity(message);

      // Add to subcollection for the specific chat
      await firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(message.id)
          .set(model.toMap());

      // Update last message in the chat metadata for list view
      await firestore.collection('chats').doc(chatId).set({
        'lastMessage': message.content,
        'lastTimestamp': Timestamp.fromDate(message.timestamp),
        'participants': [message.senderId, message.receiverId],
        'lastSenderId': message.senderId,
        'hasUnread': true,
      }, SetOptions(merge: true));

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<ChatMessage>>> getMessages(
      String currentUserId, String otherUserId) {
    final chatId = _getChatId(currentUserId, otherUserId);

    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        final messages = snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList();
        return Right(messages);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    });
  }

  @override
  Stream<Either<Failure, List<String>>> getRecentChatPartners(String userId) {
    return firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        final partnerIds = snapshot.docs.map((doc) {
          final participants = List<String>.from(doc['participants']);
          return participants.firstWhere((id) => id != userId);
        }).toList();
        return Right(partnerIds);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    });
  }

  @override
  Future<Either<Failure, void>> markAsRead(
      String currentUserId, String senderId) async {
    try {
      final chatId = _getChatId(currentUserId, senderId);

      // Update local unread flag in chat metadata
      // Ideally we also update individual messages, but for MVP metadata is fine
      await firestore.collection('chats').doc(chatId).update({
        'hasUnread': false,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
