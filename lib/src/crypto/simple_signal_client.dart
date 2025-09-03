/// Simple Signal Protocol client wrapper for basic encryption/decryption
library;

import 'dart:typed_data';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import '../storage/hive_session_store.dart';
import '../storage/hive_prekey_store.dart';
import '../storage/hive_signed_prekey_store.dart';
import '../storage/hive_sender_key_store.dart';
import '../utils/logger.dart';
import '../utils/validators.dart';
import '../exceptions/signal_exceptions.dart';
import 'key_generator.dart';
import 'secure_identity_store_wrapper.dart';

/// Simplified Signal Protocol client for basic operations
class SimpleSignalClient {
  SimpleSignalClient._({
    required this.userId,
    required this.deviceId,
    required this.identityStore,
    required this.preKeyStore,
    required this.signedPreKeyStore,
    required this.sessionStore,
    required this.senderKeyStore,
  });

  /// Current user ID
  final String userId;

  /// Current device ID
  final int deviceId;

  /// Identity key store
  final SecureIdentityStoreWrapper identityStore;

  /// PreKey store
  final HivePreKeyStore preKeyStore;

  /// Signed PreKey store
  final HiveSignedPreKeyStore signedPreKeyStore;

  /// Session store
  final HiveSessionStore sessionStore;

  /// Sender key store (for group messaging)
  final HiveSenderKeyStore senderKeyStore;

  /// Initialize a new Signal client
  /// 
  /// [userId] - Unique identifier for the user
  /// [deviceId] - Device identifier for multi-device support
  /// [generateKeys] - Whether to generate new keys if they don't exist
  static Future<SimpleSignalClient> initialize({
    required String userId,
    required int deviceId,
    bool generateKeys = true,
  }) async {
    try {
      // Validate inputs
      Validators.validateUserId(userId);
      Validators.validateDeviceId(deviceId);

      SignalLogger.info('Initializing Simple Signal client for user: $userId, device: $deviceId');

      // Initialize stores
      final identityStore = SecureIdentityStoreWrapper();
      final preKeyStore = HivePreKeyStore();
      final signedPreKeyStore = HiveSignedPreKeyStore();
      final sessionStore = HiveSessionStore();
      final senderKeyStore = HiveSenderKeyStore();

      // Initialize stores
      await identityStore.initialize();
      await preKeyStore.initialize();
      await signedPreKeyStore.initialize();
      await sessionStore.initialize();
      await senderKeyStore.initialize();

      final client = SimpleSignalClient._(
        userId: userId,
        deviceId: deviceId,
        identityStore: identityStore,
        preKeyStore: preKeyStore,
        signedPreKeyStore: signedPreKeyStore,
        sessionStore: sessionStore,
        senderKeyStore: senderKeyStore,
      );

      // Generate keys if required and they don't exist
      if (generateKeys) {
        await client._ensureKeysExist();
      }

      SignalLogger.info('Simple Signal client initialized successfully');
      return client;
    } catch (e) {
      SignalLogger.error('Failed to initialize Simple Signal client: $e');
      throw InitializationException(message: 'Failed to initialize Signal client: $e');
    }
  }

  /// Generate a complete key bundle for this user
  Future<UserKeyBundle> generateKeyBundle({int preKeyCount = 100}) async {
    try {
      SignalLogger.info('Generating key bundle for user: $userId');

      final keyBundle = await SignalKeyGenerator.createCompleteKeyBundle(
        userId: userId,
        preKeyCount: preKeyCount,
      );

      // Store the generated keys
      await identityStore.setIdentityKeyPair(keyBundle.identityKeyPair);
      await identityStore.setLocalRegistrationId(keyBundle.registrationId);

      // Store prekeys (use index as ID for now)
      for (int i = 0; i < keyBundle.preKeys.length; i++) {
        await preKeyStore.storePreKey(i, keyBundle.preKeys[i]);
      }

      // Store signed prekey (use ID 0 for first signed prekey)
      await signedPreKeyStore.storeSignedPreKey(0, keyBundle.signedPreKey);

      SignalLogger.info('Key bundle generated and stored successfully');
      return keyBundle;
    } catch (e) {
      SignalLogger.error('Failed to generate key bundle: $e');
      throw KeyException(message: 'Failed to generate key bundle: $e');
    }
  }

  /// Create a session with another user
  Future<void> createSession(SignalProtocolAddress address, PreKeyBundle bundle) async {
    try {
      SignalLogger.debug('Creating session with ${address.getName()}:${address.getDeviceId()}');

      final sessionBuilder = SessionBuilder(
        sessionStore,
        preKeyStore,
        signedPreKeyStore,
        identityStore,
        address,
      );

      await sessionBuilder.processPreKeyBundle(bundle);
      
      SignalLogger.debug('Session created successfully');
    } catch (e) {
      SignalLogger.error('Failed to create session: $e');
      throw SessionException(message: 'Failed to create session: $e');
    }
  }

  /// Encrypt a message for a specific recipient
  Future<CiphertextMessage> encryptMessage({
    required String recipientUserId,
    required int recipientDeviceId,
    required String message,
  }) async {
    try {
      // Validate inputs
      Validators.validateUserId(recipientUserId);
      Validators.validateDeviceId(recipientDeviceId);
      Validators.validateMessage(message);

      SignalLogger.debug('Encrypting message for $recipientUserId:$recipientDeviceId');

      final recipientAddress = SignalProtocolAddress(recipientUserId, recipientDeviceId);
      
      // Check if session exists
      if (!await sessionStore.containsSession(recipientAddress)) {
        throw SessionException(
          message: 'No session exists for recipient. Create session first.',
        );
      }

      // Create session cipher and encrypt
      final sessionCipher = SessionCipher(
        sessionStore,
        preKeyStore,
        signedPreKeyStore,
        identityStore,
        recipientAddress,
      );

      final messageBytes = Uint8List.fromList(message.codeUnits);
      final ciphertext = await sessionCipher.encrypt(messageBytes);

      SignalLogger.debug('Message encrypted successfully');
      return ciphertext;
    } catch (e) {
      SignalLogger.error('Failed to encrypt message: $e');
      if (e is SignalException) rethrow;
      throw CryptographicException(message: 'Failed to encrypt message: $e');
    }
  }

  /// Decrypt a message from a specific sender
  Future<String> decryptMessage({
    required String senderUserId,
    required int senderDeviceId,
    required CiphertextMessage ciphertext,
  }) async {
    try {
      // Validate inputs
      Validators.validateUserId(senderUserId);
      Validators.validateDeviceId(senderDeviceId);

      SignalLogger.debug('Decrypting message from $senderUserId:$senderDeviceId');

      final senderAddress = SignalProtocolAddress(senderUserId, senderDeviceId);
      
      // Create session cipher and decrypt
      final sessionCipher = SessionCipher(
        sessionStore,
        preKeyStore,
        signedPreKeyStore,
        identityStore,
        senderAddress,
      );

      Uint8List plaintextBytes;
      
      // Handle different message types
      if (ciphertext is PreKeySignalMessage) {
        plaintextBytes = await sessionCipher.decrypt(ciphertext);
      } else if (ciphertext is SignalMessage) {
        plaintextBytes = await sessionCipher.decryptFromSignal(ciphertext);
      } else {
        throw CryptographicException(message: 'Unsupported ciphertext type');
      }

      final plaintext = String.fromCharCodes(plaintextBytes);

      SignalLogger.debug('Message decrypted successfully');
      return plaintext;
    } catch (e) {
      SignalLogger.error('Failed to decrypt message: $e');
      if (e is SignalException) rethrow;
      throw CryptographicException(message: 'Failed to decrypt message: $e');
    }
  }

  /// Get registration ID
  Future<int> getRegistrationId() async {
    try {
      return await identityStore.getLocalRegistrationId();
    } catch (e) {
      SignalLogger.error('Failed to get registration ID: $e');
      throw StorageException(message: 'Failed to get registration ID: $e');
    }
  }

  /// Get identity key pair
  Future<IdentityKeyPair> getIdentityKeyPair() async {
    try {
      return await identityStore.getIdentityKeyPair();
    } catch (e) {
      SignalLogger.error('Failed to get identity key pair: $e');
      throw StorageException(message: 'Failed to get identity key pair: $e');
    }
  }

  /// Get all available prekeys
  Future<List<PreKeyRecord>> getAvailablePreKeys() async {
    try {
      final preKeyIds = await preKeyStore.getAllPreKeyIds();
      final preKeys = <PreKeyRecord>[];
      
      for (final id in preKeyIds) {
        try {
          final preKey = await preKeyStore.loadPreKey(id);
          preKeys.add(preKey);
        } catch (e) {
          SignalLogger.warning('Failed to load prekey $id: $e');
        }
      }
      
      return preKeys;
    } catch (e) {
      SignalLogger.error('Failed to get available prekeys: $e');
      throw StorageException(message: 'Failed to get available prekeys: $e');
    }
  }

  /// Get current signed prekey
  Future<SignedPreKeyRecord?> getCurrentSignedPreKey() async {
    try {
      // Try to get the current signed prekey (ID 0 by convention)
      try {
        return await signedPreKeyStore.loadSignedPreKey(0);
      } catch (e) {
        SignalLogger.debug('No signed prekey with ID 0 found');
        return null;
      }
    } catch (e) {
      SignalLogger.error('Failed to get current signed prekey: $e');
      throw StorageException(message: 'Failed to get current signed prekey: $e');
    }
  }

  /// Check if session exists with a user
  Future<bool> hasSessionWith(String userId, int deviceId) async {
    try {
      final address = SignalProtocolAddress(userId, deviceId);
      return await sessionStore.containsSession(address);
    } catch (e) {
      SignalLogger.error('Failed to check session existence: $e');
      return false;
    }
  }

  /// Get all active sessions
  Future<List<SignalProtocolAddress>> getActiveSessions() async {
    try {
      final sessions = await sessionStore.getAllSessions();
      return sessions.map((session) {
        // Parse address string to extract userId and deviceId
        final parts = session.address.split(':');
        if (parts.length == 2) {
          final userId = parts[0];
          final deviceId = int.tryParse(parts[1]) ?? 0;
          return SignalProtocolAddress(userId, deviceId);
        } else {
          // Fallback for malformed address
          return SignalProtocolAddress(session.address, 0);
        }
      }).toList();
    } catch (e) {
      SignalLogger.error('Failed to get active sessions: $e');
      throw StorageException(message: 'Failed to get active sessions: $e');
    }
  }

  /// Delete a session with a specific user/device
  Future<void> deleteSession(String userId, int deviceId) async {
    try {
      final address = SignalProtocolAddress(userId, deviceId);
      await sessionStore.deleteSession(address);
      SignalLogger.debug('Deleted session with $userId:$deviceId');
    } catch (e) {
      SignalLogger.error('Failed to delete session: $e');
      throw SessionException(message: 'Failed to delete session: $e');
    }
  }

  /// Delete all sessions for a user (all devices)
  Future<void> deleteAllSessionsForUser(String userId) async {
    try {
      await sessionStore.deleteAllSessions(userId);
      SignalLogger.debug('Deleted all sessions for user: $userId');
    } catch (e) {
      SignalLogger.error('Failed to delete all sessions for user: $e');
      throw SessionException(message: 'Failed to delete all sessions for user: $e');
    }
  }

  /// Regenerate prekeys
  Future<List<PreKeyRecord>> regeneratePreKeys({
    int startId = 0, 
    int count = 100,
  }) async {
    try {
      SignalLogger.info('Regenerating $count prekeys starting from ID $startId');

      // Generate new prekeys
      final newPreKeys = SignalKeyGenerator.createPreKeys(
        startId: startId,
        count: count,
      );

      // Store the new prekeys
      for (final preKey in newPreKeys) {
        await preKeyStore.storePreKey(preKey.id, preKey);
      }

      SignalLogger.info('Successfully regenerated ${newPreKeys.length} prekeys');
      return newPreKeys;
    } catch (e) {
      SignalLogger.error('Failed to regenerate prekeys: $e');
      throw KeyException(message: 'Failed to regenerate prekeys: $e');
    }
  }

  /// Regenerate signed prekey
  Future<SignedPreKeyRecord> regenerateSignedPreKey({int? signedPreKeyId}) async {
    try {
      final keyId = signedPreKeyId ?? DateTime.now().millisecondsSinceEpoch;
      SignalLogger.info('Regenerating signed prekey with ID $keyId');

      // Get identity key pair
      final identityKeyPair = await getIdentityKeyPair();

      // Generate new signed prekey
      final newSignedPreKey = SignalKeyGenerator.createSignedPreKey(
        identityKeyPair: identityKeyPair,
        signedPreKeyId: keyId,
      );

      // Store the new signed prekey
      await signedPreKeyStore.storeSignedPreKey(keyId, newSignedPreKey);

      SignalLogger.info('Successfully regenerated signed prekey with ID $keyId');
      return newSignedPreKey;
    } catch (e) {
      SignalLogger.error('Failed to regenerate signed prekey: $e');
      throw KeyException(message: 'Failed to regenerate signed prekey: $e');
    }
  }

  /// Remove used prekey
  Future<void> removeUsedPreKey(int preKeyId) async {
    try {
      await preKeyStore.removePreKey(preKeyId);
      SignalLogger.debug('Removed used prekey with ID $preKeyId');
    } catch (e) {
      SignalLogger.warning('Failed to remove used prekey $preKeyId: $e');
      // Don't throw here as this is a cleanup operation
    }
  }

  /// Get prekey bundle for sharing with other users
  Future<PreKeyBundle> getPreKeyBundle() async {
    try {
      // Get identity key
      final identityKeyPair = await getIdentityKeyPair();
      final identityKey = identityKeyPair.getPublicKey();

      // Get registration ID
      final registrationId = await getRegistrationId();

      // Get signed prekey
      final signedPreKey = await getCurrentSignedPreKey();
      if (signedPreKey == null) {
        throw KeyException(message: 'No signed prekey available');
      }

      // Get an available prekey
      final availablePreKeys = await getAvailablePreKeys();
      if (availablePreKeys.isEmpty) {
        throw KeyException(message: 'No prekeys available');
      }

      final preKey = availablePreKeys.first;

      return PreKeyBundle(
        registrationId,
        deviceId,
        preKey.id,
        preKey.getKeyPair().publicKey,
        signedPreKey.id,
        signedPreKey.getKeyPair().publicKey,
        signedPreKey.signature,
        identityKey,
      );
    } catch (e) {
      SignalLogger.error('Failed to create prekey bundle: $e');
      if (e is KeyException) rethrow;
      throw KeyException(message: 'Failed to create prekey bundle: $e');
    }
  }

  /// Trust an identity key
  Future<void> trustIdentityKey(String userId, IdentityKey identityKey) async {
    try {
      await identityStore.saveIdentity(
        SignalProtocolAddress(userId, 0),
        identityKey,
      );
      SignalLogger.debug('Trusted identity key for user: $userId');
    } catch (e) {
      SignalLogger.error('Failed to trust identity key: $e');
      throw SecurityException(message: 'Failed to trust identity key: $e');
    }
  }

  /// Get trusted identity key for a user
  Future<IdentityKey?> getTrustedIdentityKey(String userId) async {
    try {
      return await identityStore.getIdentity(
        SignalProtocolAddress(userId, 0),
      );
    } catch (e) {
      SignalLogger.error('Failed to get trusted identity key: $e');
      return null;
    }
  }

  /// Check if an identity key is trusted
  Future<bool> isIdentityKeyTrusted(String userId, IdentityKey identityKey) async {
    try {
      return await identityStore.isTrustedIdentity(
        SignalProtocolAddress(userId, 0),
        identityKey,
        Direction.sending,
      );
    } catch (e) {
      SignalLogger.error('Failed to check identity key trust: $e');
      return false;
    }
  }

  /// Dispose the client and clean up resources
  Future<void> dispose() async {
    try {
      SignalLogger.info('Disposing Simple Signal client');

      await identityStore.dispose();
      // Note: Other stores don't have dispose methods in current implementation

      SignalLogger.info('Simple Signal client disposed');
    } catch (e) {
      SignalLogger.error('Failed to dispose Simple Signal client: $e');
    }
  }

  /// Ensure identity keys exist
  Future<void> _ensureKeysExist() async {
    try {
      // Check if identity key pair exists
      await identityStore.getIdentityKeyPair();
      SignalLogger.debug('Identity keys already exist');
    } catch (e) {
      // Keys don't exist, generate them
      SignalLogger.info('Generating initial identity keys');
      await generateKeyBundle();
    }
  }
}

/// Simple encryption result
class EncryptionResult {
  const EncryptionResult({
    required this.ciphertext,
    required this.recipientAddress,
    required this.timestamp,
  });

  final CiphertextMessage ciphertext;
  final SignalProtocolAddress recipientAddress;
  final DateTime timestamp;
}

/// Simple decryption result
class DecryptionResult {
  const DecryptionResult({
    required this.plaintext,
    required this.senderAddress,
    required this.timestamp,
  });

  final String plaintext;
  final SignalProtocolAddress senderAddress;
  final DateTime timestamp;
}
