import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Service for encrypting and decrypting sensitive data.
/// Uses AES-256 encryption for HIPAA compliance.
abstract class EncryptionService {
  /// Encrypts a plaintext string.
  String encryptString(String plaintext, String key);

  /// Decrypts an encrypted string.
  String decryptString(String ciphertext, String key);

  /// Generates a secure encryption key.
  String generateKey();

  /// Generates a secure IV (Initialization Vector).
  String generateIV();

  /// Hashes a string using SHA-256.
  String hashString(String input);

  /// Verifies a hash against an input.
  bool verifyHash(String input, String hash);
}

/// Implementation of EncryptionService using AES-256.
class EncryptionServiceImpl implements EncryptionService {
  @override
  String encryptString(String plaintext, String key) {
    final keyBytes = _deriveKey(key);
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc),
    );

    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    // Combine IV and ciphertext for storage
    final combined = '${iv.base64}:${encrypted.base64}';
    return combined;
  }

  @override
  String decryptString(String ciphertext, String key) {
    try {
      final parts = ciphertext.split(':');
      if (parts.length != 2) {
        throw const FormatException('Invalid ciphertext format');
      }

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);

      final keyBytes = _deriveKey(key);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc),
      );

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  @override
  String generateKey() {
    final key = encrypt.Key.fromSecureRandom(32);
    return key.base64;
  }

  @override
  String generateIV() {
    final iv = encrypt.IV.fromSecureRandom(16);
    return iv.base64;
  }

  @override
  String hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  bool verifyHash(String input, String hash) {
    final inputHash = hashString(input);
    return inputHash == hash;
  }

  /// Derives a 256-bit key from the provided key string.
  encrypt.Key _deriveKey(String key) {
    final keyBytes = utf8.encode(key);
    final hash = sha256.convert(keyBytes);
    return encrypt.Key(Uint8List.fromList(hash.bytes));
  }
}
