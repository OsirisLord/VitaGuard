import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitaguard/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:vitaguard/features/chat/domain/entities/chat_message.dart';

void main() {
  late ChatRepositoryImpl repository;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = ChatRepositoryImpl(firestore: fakeFirestore);
  });

  final tValidMessage = ChatMessage(
    id: 'msg1',
    senderId: 'u1',
    receiverId: 'u2',
    content: 'Hello',
    timestamp: DateTime.now(),
  );

  test('sendMessage should add message to firestore and update metadata',
      () async {
    // Act
    final result = await repository.sendMessage(tValidMessage);

    // Assert
    expect(result.isRight(), true);

    // Verify data in fake firestore
    final messages = await fakeFirestore
        .collection('chats')
        .doc('u1_u2')
        .collection('messages')
        .get();
    expect(messages.docs.length, 1);
    expect(messages.docs.first.data()['content'], 'Hello');

    final chatDoc = await fakeFirestore.collection('chats').doc('u1_u2').get();
    expect(chatDoc.exists, true);
    expect(chatDoc.data()?['lastMessage'], 'Hello');
  });
}
