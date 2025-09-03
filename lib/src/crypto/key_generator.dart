/// Key generation utilities for Signal Protocol
library;

import 'dart:typed_data';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import '../utils/logger.dart';
import '../utils/validators.dart';
import '../exceptions/signal_exceptions.dart';

/// Utility class for generating Signal Protocol cryptographic keys
class SignalKeyGenerator {
  SignalKeyGenerator._();

  /// Generates a new identity key pair for a user
  /// Returns both private and public identity keys
  static IdentityKeyPair createIdentityKeyPair() {
    try {
      final keyPair = generateIdentityKeyPair();
      SignalLogger.debug('Generated new identity key pair');
      return keyPair;
    } catch (e) {
      SignalLogger.error('Failed to generate identity key pair: $e');
      throw CryptographicException(message: 'Failed to generate identity key pair: $e');
    }
  }

  /// Generates a registration ID for a user
  /// 
  /// [extendedRange] - Whether to use extended range (14-bit vs 13-bit)
  static int createRegistrationId({bool extendedRange = false}) {
    try {
      final registrationId = generateRegistrationId(extendedRange);
      SignalLogger.debug('Generated registration ID: $registrationId');
      return registrationId;
    } catch (e) {
      SignalLogger.error('Failed to generate registration ID: $e');
      throw CryptographicException(message: 'Failed to generate registration ID: $e');
    }
  }

  /// Generates a list of one-time prekeys
  /// 
  /// [startId] - Starting ID for the prekey range
  /// [count] - Number of prekeys to generate
  static List<PreKeyRecord> createPreKeys({
    required int startId,
    required int count,
  }) {
    try {
      // Validate inputs
      if (startId < 0) {
        throw ValidationException(message: 'Start ID must be non-negative');
      }
      if (count <= 0) {
        throw ValidationException(message: 'Count must be positive');
      }
      if (count > 1000) {
        throw ValidationException(message: 'Count cannot exceed 1000 prekeys at once');
      }

      final preKeys = generatePreKeys(startId, count);
      SignalLogger.debug('Generated $count prekeys starting from ID $startId');
      return preKeys;
    } catch (e) {
      SignalLogger.error('Failed to generate prekeys: $e');
      if (e is ValidationException) rethrow;
      throw CryptographicException(message: 'Failed to generate prekeys: $e');
    }
  }

  /// Generates a signed prekey
  /// 
  /// [identityKeyPair] - The identity key pair to sign with
  /// [signedPreKeyId] - ID for the signed prekey
  static SignedPreKeyRecord createSignedPreKey({
    required IdentityKeyPair identityKeyPair,
    required int signedPreKeyId,
  }) {
    try {
      // Validate inputs
      if (signedPreKeyId < 0) {
        throw ValidationException(message: 'Signed prekey ID must be non-negative');
      }

      final signedPreKey = generateSignedPreKey(identityKeyPair, signedPreKeyId);
      SignalLogger.debug('Generated signed prekey with ID $signedPreKeyId');
      return signedPreKey;
    } catch (e) {
      SignalLogger.error('Failed to generate signed prekey: $e');
      if (e is ValidationException) rethrow;
      throw CryptographicException(message: 'Failed to generate signed prekey: $e');
    }
  }

  /// Generates a new sender key for group messaging
  static Uint8List createSenderKey() {
    try {
      final senderKey = generateSenderKey();
      SignalLogger.debug('Generated new sender key');
      return senderKey;
    } catch (e) {
      SignalLogger.error('Failed to generate sender key: $e');
      throw CryptographicException(message: 'Failed to generate sender key: $e');
    }
  }

  /// Generates a new sender key ID
  static int createSenderKeyId() {
    try {
      final keyId = generateSenderKeyId();
      SignalLogger.debug('Generated sender key ID: $keyId');
      return keyId;
    } catch (e) {
      SignalLogger.error('Failed to generate sender key ID: $e');
      throw CryptographicException(message: 'Failed to generate sender key ID: $e');
    }
  }

  /// Generates a signing key pair for sender keys
  static ECKeyPair createSenderSigningKey() {
    try {
      final keyPair = generateSenderSigningKey();
      SignalLogger.debug('Generated sender signing key pair');
      return keyPair;
    } catch (e) {
      SignalLogger.error('Failed to generate sender signing key: $e');
      throw CryptographicException(message: 'Failed to generate sender signing key: $e');
    }
  }

  /// Generates random bytes for cryptographic purposes
  /// 
  /// [length] - Number of bytes to generate (default: 32)
  static Uint8List createRandomBytes({int length = 32}) {
    try {
      if (length <= 0) {
        throw ValidationException(message: 'Length must be positive');
      }
      if (length > 1024) {
        throw ValidationException(message: 'Length cannot exceed 1024 bytes');
      }

      final randomBytes = generateRandomBytes(length);
      SignalLogger.debug('Generated $length random bytes');
      return randomBytes;
    } catch (e) {
      SignalLogger.error('Failed to generate random bytes: $e');
      if (e is ValidationException) rethrow;
      throw CryptographicException(message: 'Failed to generate random bytes: $e');
    }
  }

  /// Generates a complete key bundle for a new user
  /// 
  /// [userId] - User identifier for logging purposes
  /// [preKeyCount] - Number of one-time prekeys to generate
  /// [extendedRegistrationId] - Whether to use extended registration ID range
  static Future<UserKeyBundle> createCompleteKeyBundle({
    required String userId,
    int preKeyCount = 100,
    bool extendedRegistrationId = false,
  }) async {
    try {
      // Validate inputs
      Validators.validateUserId(userId);
      if (preKeyCount <= 0 || preKeyCount > 1000) {
        throw ValidationException(message: 'PreKey count must be between 1 and 1000');
      }

      SignalLogger.info('Generating complete key bundle for user: $userId');

      // Generate all required keys
      final identityKeyPair = createIdentityKeyPair();
      final registrationId = createRegistrationId(extendedRange: extendedRegistrationId);
      final preKeys = createPreKeys(startId: 0, count: preKeyCount);
      final signedPreKey = createSignedPreKey(
        identityKeyPair: identityKeyPair,
        signedPreKeyId: 0,
      );

      final bundle = UserKeyBundle(
        userId: userId,
        identityKeyPair: identityKeyPair,
        registrationId: registrationId,
        preKeys: preKeys,
        signedPreKey: signedPreKey,
        generatedAt: DateTime.now(),
      );

      SignalLogger.info('Successfully generated complete key bundle for user: $userId');
      return bundle;
    } catch (e) {
      SignalLogger.error('Failed to generate complete key bundle for user $userId: $e');
      if (e is ValidationException) rethrow;
      throw CryptographicException(message: 'Failed to generate complete key bundle: $e');
    }
  }
}

/// Container for a complete user key bundle
class UserKeyBundle {
  const UserKeyBundle({
    required this.userId,
    required this.identityKeyPair,
    required this.registrationId,
    required this.preKeys,
    required this.signedPreKey,
    required this.generatedAt,
  });

  /// User identifier
  final String userId;

  /// Identity key pair (long-term)
  final IdentityKeyPair identityKeyPair;

  /// Registration ID
  final int registrationId;

  /// List of one-time prekeys
  final List<PreKeyRecord> preKeys;

  /// Signed prekey
  final SignedPreKeyRecord signedPreKey;

  /// Timestamp when the bundle was generated
  final DateTime generatedAt;

  /// Gets the public identity key
  IdentityKey get identityKey => identityKeyPair.getPublicKey();

  /// Gets the count of prekeys in this bundle
  int get preKeyCount => preKeys.length;

  @override
  String toString() {
    return 'UserKeyBundle(userId: $userId, registrationId: $registrationId, '
        'preKeyCount: $preKeyCount, generatedAt: $generatedAt)';
  }
}
