import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Remote data source for authentication using Firebase.
abstract class AuthRemoteDataSource {
  /// Signs in with email and password.
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  /// Creates a new user account.
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String role,
    required String displayName,
    String? phoneNumber,
    Map<String, dynamic>? roleSpecificData,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Gets the current user.
  Future<UserModel?> getCurrentUser();

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail({required String email});

  /// Updates user profile.
  Future<UserModel> updateProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    Map<String, dynamic>? roleSpecificData,
  });

  /// Sends email verification.
  Future<void> sendEmailVerification();

  /// Stream of auth state changes.
  Stream<UserModel?> get authStateChanges;
}

/// Implementation of AuthRemoteDataSource using Firebase.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      firestore.collection('users');

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(
          message: 'Failed to sign in',
          code: 'SIGN_IN_FAILED',
        );
      }

      // Update last login time
      await _usersCollection.doc(credential.user!.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      // Get user data from Firestore
      final userDoc = await _usersCollection.doc(credential.user!.uid).get();
      if (!userDoc.exists) {
        throw const AuthException(
          message: 'User profile not found',
          code: 'PROFILE_NOT_FOUND',
        );
      }

      return UserModel.fromFirestore(userDoc);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String role,
    required String displayName,
    String? phoneNumber,
    Map<String, dynamic>? roleSpecificData,
  }) async {
    try {
      // Create Firebase Auth user
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(
          message: 'Failed to create account',
          code: 'SIGN_UP_FAILED',
        );
      }

      // Update display name
      await credential.user!.updateDisplayName(displayName);

      // Create user document in Firestore
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        role: role,
        displayName: displayName,
        phoneNumber: phoneNumber,
        emailVerified: credential.user!.emailVerified,
        createdAt: DateTime.now(),
      );

      final userData = userModel.toMap();
      if (roleSpecificData != null) {
        userData['profile'] = {...?userData['profile'], ...roleSpecificData};
      }

      await _usersCollection.doc(credential.user!.uid).set(userData);

      // Also create role-specific document
      await _createRoleSpecificDocument(
        userId: credential.user!.uid,
        role: role,
        userData: userData,
      );

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: e.toString());
    }
  }

  Future<void> _createRoleSpecificDocument({
    required String userId,
    required String role,
    required Map<String, dynamic> userData,
  }) async {
    // Create document in role-specific collection
    switch (role.toLowerCase()) {
      case 'patient':
        await firestore.collection('patients').doc(userId).set({
          'userId': userId,
          'assignedDoctorId': null,
          'companions': [],
          'facilityId': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
        break;
      case 'doctor':
        await firestore.collection('doctors').doc(userId).set({
          'userId': userId,
          'licenseNumber': userData['profile']?['licenseNumber'] ?? '',
          'specialization': userData['profile']?['specialization'] ?? '',
          'patients': [],
          'isVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        break;
      case 'companion':
        await firestore.collection('companions').doc(userId).set({
          'userId': userId,
          'patients': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
        break;
      case 'facility':
        await firestore.collection('facilities').doc(userId).set({
          'userId': userId,
          'registrationNumber':
              userData['profile']?['registrationNumber'] ?? '',
          'facilityType': userData['profile']?['facilityType'] ?? '',
          'doctors': [],
          'patients': [],
          'isVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        break;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final userDoc = await _usersCollection.doc(firebaseUser.uid).get();
      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code);
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    Map<String, dynamic>? roleSpecificData,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (displayName != null) updates['displayName'] = displayName;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;

      if (roleSpecificData != null) {
        for (final entry in roleSpecificData.entries) {
          updates['profile.${entry.key}'] = entry.value;
        }
      }

      if (updates.isNotEmpty) {
        await _usersCollection.doc(userId).update(updates);
      }

      // Also update Firebase Auth display name
      if (displayName != null) {
        await firebaseAuth.currentUser?.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await firebaseAuth.currentUser?.updatePhotoURL(photoUrl);
      }

      final userDoc = await _usersCollection.doc(userId).get();
      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      throw AuthException(message: 'Failed to update profile: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await firebaseAuth.currentUser?.sendEmailVerification();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code);
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final userDoc = await _usersCollection.doc(firebaseUser.uid).get();
        if (!userDoc.exists) return null;
        return UserModel.fromFirestore(userDoc);
      } catch (e) {
        return null;
      }
    });
  }
}
