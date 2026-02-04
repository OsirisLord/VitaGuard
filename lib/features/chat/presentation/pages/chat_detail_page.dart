import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../depedency_injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/chat_message.dart';
import '../bloc/chat_bloc.dart';

class ChatDetailPage extends StatelessWidget {
  final String otherUserId;
  final String? otherUserName;

  const ChatDetailPage({
    super.key,
    required this.otherUserId,
    this.otherUserName,
  });

  @override
  Widget build(BuildContext context) {
    // Get current user
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    final currentUserId = authState.user.id;

    return BlocProvider(
      create: (context) => ChatBloc(
        repository: sl(),
        currentUserId: currentUserId,
      )..add(LoadMessages(otherUserId))..addInternalHandlers(), // Initialize handlers
      child: _ChatDetailView(
        otherUserName: otherUserName ?? 'Chat',
        otherUserId: otherUserId,
        currentUserId: currentUserId,
      ),
    );
  }
}

class _ChatDetailView extends StatefulWidget {
  final String otherUserName;
  final String otherUserId;
  final String currentUserId;

  const _ChatDetailView({
    required this.otherUserName,
    required this.otherUserId,
    required this.currentUserId,
  });

  @override
  State<_ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<_ChatDetailView> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading && state is! ChatLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (state is ChatLoaded) {
                  final messages = state.messages;
                  if (messages.isEmpty) {
                    return const Center(child: Text('Say hello!'));
                  }

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == widget.currentUserId;
                      return _MessageBubble(message: message, isMe: isMe);
                    },
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // TODO: Attachments
              },
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.primary),
              onPressed: () {
                final content = _controller.text.trim();
                if (content.isNotEmpty) {
                  context.read<ChatBloc>().add(
                    SendMessage(
                      receiverId: widget.otherUserId,
                      content: content,
                    ),
                  );
                  _controller.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? AppColors.primary : Colors.grey.shade200;
    final fg = isMe ? Colors.white : Colors.black87;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: fg),
        ),
      ),
    );
  }
}
