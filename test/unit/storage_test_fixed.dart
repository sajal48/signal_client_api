import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';
import 'package:signal_protocol_flutter/src/storage/hive_session_store.dart';
import 'package:signal_protocol_flutter/src/storage/hive_prekey_store.dart';
import 'package:signal_protocol_flutter/src/storage/hive_signed_prekey_store.dart';
import 'package:signal_protocol_flutter/src/storage/hive_sender_key_store.dart';
import 'package:signal_protocol_flutter/src/storage/hive_registry.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import 'package:fixnum/fixnum.dart';
import 'dart:typed_data';

void main() {
  group('Storage Components Tests - Fixed', () {
    setUp(() async {
      await setUpTestHive();
      HiveRegistry.registerAdapters();
    });

    tearDown(() async {
      await tearDownTestHive();
    });

    group('HiveSessionStore Tests', () {
      late HiveSessionStore sessionStore;
      late SignalProtocolAddress testAddress;
      late SessionRecord testRecord;

      setUp(() async {
        sessionStore = HiveSessionStore();
        await sessionStore.initialize();
        
        testAddress = SignalProtocolAddress('user123', 1);
        testRecord = SessionRecord();
      });

      tearDown(() async {
        await sessionStore.close(); // Use close() instead of dispose()
      });

      test('should initialize successfully', () async {
        expect(sessionStore, isNotNull);
      });

      test('should store and load session', () async {
        // Store session
        await sessionStore.storeSession(testAddress, testRecord);
        
        // Load session
        final loadedRecord = await sessionStore.loadSession(testAddress);
        expect(loadedRecord, isNotNull);
      });

      test('should check if session exists', () async {
        // Initially no session
        expect(await sessionStore.containsSession(testAddress), isFalse);
        
        // Store session
        await sessionStore.storeSession(testAddress, testRecord);
        
        // Now session exists
        expect(await sessionStore.containsSession(testAddress), isTrue);
      });

      test('should delete session', () async {
        // Store session
        await sessionStore.storeSession(testAddress, testRecord);
        expect(await sessionStore.containsSession(testAddress), isTrue);
        
        // Delete session
        await sessionStore.deleteSession(testAddress);
        expect(await sessionStore.containsSession(testAddress), isFalse);
      });

      test('should get session count', () async {
        expect(sessionStore.sessionCount, equals(0)); // Use getter instead of method
        
        await sessionStore.storeSession(testAddress, testRecord);
        expect(sessionStore.sessionCount, equals(1));
      });

      test('should get sub-device sessions', () async {
        final sessions = await sessionStore.getSubDeviceSessions('user123');
        expect(sessions, isA<List<int>>());
      });

      test('should delete all sessions for a user', () async {
        // Store session
        await sessionStore.storeSession(testAddress, testRecord);
        expect(sessionStore.sessionCount, equals(1));
        
        // Delete all sessions for the user (requires parameter)
        await sessionStore.deleteAllSessions('user123');
        expect(sessionStore.sessionCount, equals(0));
      });

      test('should clear all sessions', () async {
        await sessionStore.storeSession(testAddress, testRecord);
        expect(sessionStore.sessionCount, equals(1));
        
        await sessionStore.clearAllSessions();
        expect(sessionStore.sessionCount, equals(0));
      });
    });

    group('HivePreKeyStore Tests', () {
      late HivePreKeyStore preKeyStore;

      setUp(() async {
        preKeyStore = HivePreKeyStore();
        await preKeyStore.initialize();
      });

      tearDown(() async {
        await preKeyStore.close(); // Use close() instead of dispose()
      });

      test('should initialize successfully', () async {
        expect(preKeyStore, isNotNull);
      });

      test('should get pre-key count', () async {
        expect(preKeyStore.preKeyCount, equals(0)); // Use getter instead of method
      });

      test('should get all pre-key IDs', () async {
        final preKeyIds = await preKeyStore.getAllPreKeyIds();
        expect(preKeyIds, isA<List<int>>());
        expect(preKeyIds, isEmpty); // Initially empty
      });

      test('should clear all pre-keys', () async {
        await preKeyStore.clearAllPreKeys(); // Use clearAllPreKeys() instead of deleteAllPreKeys()
        expect(preKeyStore.preKeyCount, equals(0));
      });
    });

    group('HiveSignedPreKeyStore Tests', () {
      late HiveSignedPreKeyStore signedPreKeyStore;
      late SignedPreKeyRecord testSignedPreKey;
      final testSignedPreKeyId = 456;

      setUp(() async {
        signedPreKeyStore = HiveSignedPreKeyStore();
        await signedPreKeyStore.initialize();
        
        // Create a test signed pre-key record
        final keyPair = generateKeyPair();
        final signature = Uint8List.fromList([1, 2, 3, 4, 5]);
        final timestamp = Int64(DateTime.now().millisecondsSinceEpoch); // Use Int64
        testSignedPreKey = SignedPreKeyRecord(
          testSignedPreKeyId,
          timestamp,
          keyPair,
          signature,
        );
      });

      tearDown(() async {
        await signedPreKeyStore.close(); // Use close() instead of dispose()
      });

      test('should initialize successfully', () async {
        expect(signedPreKeyStore, isNotNull);
      });

      test('should store and load signed pre-key', () async {
        // Store signed pre-key
        await signedPreKeyStore.storeSignedPreKey(testSignedPreKeyId, testSignedPreKey);
        
        // Load signed pre-key
        final loadedSignedPreKey = await signedPreKeyStore.loadSignedPreKey(testSignedPreKeyId);
        expect(loadedSignedPreKey, isNotNull);
        expect(loadedSignedPreKey.id, equals(testSignedPreKeyId)); // Use .id instead of .getId()
      });

      test('should check if signed pre-key exists', () async {
        // Initially no signed pre-key
        expect(await signedPreKeyStore.containsSignedPreKey(testSignedPreKeyId), isFalse);
        
        // Store signed pre-key
        await signedPreKeyStore.storeSignedPreKey(testSignedPreKeyId, testSignedPreKey);
        
        // Now signed pre-key exists
        expect(await signedPreKeyStore.containsSignedPreKey(testSignedPreKeyId), isTrue);
      });

      test('should remove signed pre-key', () async {
        // Store signed pre-key
        await signedPreKeyStore.storeSignedPreKey(testSignedPreKeyId, testSignedPreKey);
        expect(await signedPreKeyStore.containsSignedPreKey(testSignedPreKeyId), isTrue);
        
        // Remove signed pre-key
        await signedPreKeyStore.removeSignedPreKey(testSignedPreKeyId);
        expect(await signedPreKeyStore.containsSignedPreKey(testSignedPreKeyId), isFalse);
      });

      test('should get signed pre-key count', () async {
        expect(signedPreKeyStore.signedPreKeyCount, equals(0)); // Use getter instead of method
        
        await signedPreKeyStore.storeSignedPreKey(testSignedPreKeyId, testSignedPreKey);
        expect(signedPreKeyStore.signedPreKeyCount, equals(1));
      });

      test('should clear all signed pre-keys', () async {
        await signedPreKeyStore.storeSignedPreKey(testSignedPreKeyId, testSignedPreKey);
        expect(signedPreKeyStore.signedPreKeyCount, equals(1));
        
        await signedPreKeyStore.clearAllSignedPreKeys(); // Use clearAllSignedPreKeys() instead of deleteAllSignedPreKeys()
        expect(signedPreKeyStore.signedPreKeyCount, equals(0));
      });
    });

    group('HiveSenderKeyStore Tests', () {
      late HiveSenderKeyStore senderKeyStore;
      late SenderKeyRecord testSenderKey;
      late SenderKeyName testSenderKeyName;

      setUp(() async {
        senderKeyStore = HiveSenderKeyStore();
        await senderKeyStore.initialize();
        
        // Create test sender key name and record
        testSenderKeyName = SenderKeyName('group123', SignalProtocolAddress('user123', 1));
        testSenderKey = SenderKeyRecord();
      });

      tearDown(() async {
        await senderKeyStore.close(); // Use close() instead of dispose()
      });

      test('should initialize successfully', () async {
        expect(senderKeyStore, isNotNull);
      });

      test('should store and load sender key', () async {
        // Store sender key
        await senderKeyStore.storeSenderKey(testSenderKeyName, testSenderKey);
        
        // Load sender key
        final loadedSenderKey = await senderKeyStore.loadSenderKey(testSenderKeyName);
        expect(loadedSenderKey, isNotNull);
      });

      test('should get sender key count', () async {
        expect(senderKeyStore.senderKeyCount, equals(0)); // Use getter instead of method
        
        await senderKeyStore.storeSenderKey(testSenderKeyName, testSenderKey);
        expect(senderKeyStore.senderKeyCount, equals(1));
      });

      test('should clear all sender keys', () async {
        await senderKeyStore.storeSenderKey(testSenderKeyName, testSenderKey);
        expect(senderKeyStore.senderKeyCount, equals(1));
        
        await senderKeyStore.clearAllSenderKeys(); // Use clearAllSenderKeys() instead of deleteAllSenderKeys()
        expect(senderKeyStore.senderKeyCount, equals(0));
      });
    });

    group('HiveRegistry Tests', () {
      test('should register adapters without throwing', () {
        expect(() => HiveRegistry.registerAdapters(), returnsNormally); // Remove await since it's void
      });

      test('should handle multiple registrations', () {
        HiveRegistry.registerAdapters();
        expect(() => HiveRegistry.registerAdapters(), returnsNormally); // Remove await since it's void
      });
    });
  });
}

/// Helper function to generate a key pair for testing
ECKeyPair generateKeyPair() {
  // For testing purposes, we'll create a mock key pair
  // In real implementation, this would use proper cryptographic key generation
  try {
    // Use a simple approach to create keys for testing
    return Curve.generateKeyPair();
  } catch (e) {
    // Fallback: Create a simple test key pair structure
    // This won't be cryptographically valid but will work for testing
    final privateKey = Uint8List(32);
    final publicKey = Uint8List(33);
    
    // Fill with test data
    for (int i = 0; i < privateKey.length; i++) {
      privateKey[i] = i % 256;
    }
    for (int i = 0; i < publicKey.length; i++) {
      publicKey[i] = (i + 100) % 256;
    }
    
    // This is a workaround for testing - create a minimal key pair
    // In real usage, proper key generation would be used
    throw UnsupportedError('Key generation not available in test environment. Consider mocking this test.');
  }
}
