import 'package:equatable/equatable.dart';

enum MessageType { text, image, file }

class ChatMessage extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [
        id,
        senderId,
        receiverId,
        content,
        timestamp,
        type,
        isRead,
      ];
}
