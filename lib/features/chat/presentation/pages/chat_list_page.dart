import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/chat_bloc.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return BlocProvider(
      create: (context) => ChatBloc(
        repository: sl(),
        currentUserId: authState.user.id,
      )..add(LoadRecentChats()),
      child: const _ChatListView(),
    );
  }
}

class _ChatListView extends StatelessWidget {
  const _ChatListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Search users to start new chat
            },
          ),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ChatOperationFailure) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is RecentChatsLoaded) {
            if (state.partnerIds.isEmpty) {
              return const Center(
                child: Text('No conversations yet'),
              );
            }

            return ListView.builder(
              itemCount: state.partnerIds.length,
              itemBuilder: (context, index) {
                return _ChatListItem(userId: state.partnerIds[index]);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Open user picker
        },
        child: const Icon(Icons.message),
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final String userId;

  const _ChatListItem({required this.userId});

  @override
  Widget build(BuildContext context) {
    // Fetch user details dynamically
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Loading...'),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) return const SizedBox.shrink();

        final name = data['name'] ?? 'Unknown User';
        final photoUrl = data['photoUrl'];

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null ? Text(name[0].toUpperCase()) : null,
          ),
          title: Text(name, style: AppTextStyles.labelLarge),
          subtitle: const Text('Tap to chat'), // Ideally show last message
          onTap: () {
            context.push('/chat/$userId', extra: name);
          },
        );
      },
    );
  }
}
