import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vitaguard/core/errors/failures.dart';
import 'package:vitaguard/features/chat/data/models/message_model.dart';
import 'package:vitaguard/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:vitaguard/features/chat/domain/entities/chat_message.dart';

import 'chat_repository_impl_test.mocks.dart';

@GenerateMocks([FirebaseFirestore, CollectionReference, DocumentReference, DocumentSnapshot])
void main() {
  late ChatRepositoryImpl repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockCollectionReference<Map<String, dynamic>> mockSubCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockDocumentReference<Map<String, dynamic>> mockSubDocRef;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockSubCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockSubDocRef = MockDocumentReference();

    // Setup partial mock chain for Firestore
    // firestore.collection('chats').doc(id).collection('messages').doc(id)
    when(mockFirestore.collection('chats')).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDocRef);
    when(mockDocRef.collection('messages')).thenReturn(mockSubCollection);
    when(mockSubCollection.doc(any)).thenReturn(mockSubDocRef);

    repository = ChatRepositoryImpl(firestore: mockFirestore);
  });

  const tMessage = ChatMessage(
    id: 'msg1',
    senderId: 'u1',
    receiverId: 'u2',
    content: 'Hello',
    timestamp: null, // We'll handle this in creating valid object usually
  );

  // Correction for timestamp in test object
  final tValidMessage = ChatMessage(
    id: 'msg1',
    senderId: 'u1',
    receiverId: 'u2',
    content: 'Hello',
    timestamp: DateTime.now(),
  );

  test('sendMessage should add message to firestore and update metadata', () async {
    // Arrange
    when(mockSubDocRef.set(any)).thenAnswer((_) async => {});
    when(mockDocRef.set(any, any)).thenAnswer((_) async => {}); // For metadata merge

    // Act
    final result = await repository.sendMessage(tValidMessage);

    // Assert
    expect(result, const Right(null));
    verify(mockSubDocRef.set(any)).called(1);
    verify(mockDocRef.set(any, any)).called(1); // Metadata update
  });

  test('sendMessage should return ServerFailure on exception', () async {
    // Arrange
    when(mockSubDocRef.set(any)).thenThrow(Exception('Firestore Error'));

    // Act
    final result = await repository.sendMessage(tValidMessage);

    // Assert
    expect(result, isA<Left<Failure, void>>());
  });
}
