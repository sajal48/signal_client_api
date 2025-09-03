import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';
import 'package:signal_protocol_flutter/src/storage/hive_session_store.dart';
import 'package:signal_protocol_flutter/src/storage/hive_prekey_store.dart';
import 'package:signal_protocol_flutter/src/storage/hive_signed_prekey_store.dart';
import 'package:signal_protocol_flutter/src/storage/hive_sender_key_store.dart';
import 'package:signal_protocol_flutter/src/storage/hive_registry.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

void main() {
  group('Storage Components - Basic Tests', () {
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
        await sessionStore.close();
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
        expect(sessionStore.sessionCount, equals(0));
        
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
        
        // Delete all sessions for the user
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
        await preKeyStore.close();
      });

      test('should initialize successfully', () async {
        expect(preKeyStore, isNotNull);
      });

      test('should get pre-key count', () async {
        expect(preKeyStore.preKeyCount, equals(0));
      });

      test('should get all pre-key IDs', () async {
        final preKeyIds = await preKeyStore.getAllPreKeyIds();
        expect(preKeyIds, isA<List<int>>());
        expect(preKeyIds, isEmpty);
      });

      test('should clear all pre-keys', () async {
        await preKeyStore.clearAllPreKeys();
        expect(preKeyStore.preKeyCount, equals(0));
      });

      test('should check if pre-key exists (false for non-existent)', () async {
        expect(await preKeyStore.containsPreKey(999), isFalse);
      });
    });

    group('HiveSignedPreKeyStore Tests', () {
      late HiveSignedPreKeyStore signedPreKeyStore;

      setUp(() async {
        signedPreKeyStore = HiveSignedPreKeyStore();
        await signedPreKeyStore.initialize();
      });

      tearDown(() async {
        await signedPreKeyStore.close();
      });

      test('should initialize successfully', () async {
        expect(signedPreKeyStore, isNotNull);
      });

      test('should get signed pre-key count', () async {
        expect(signedPreKeyStore.signedPreKeyCount, equals(0));
      });

      test('should clear all signed pre-keys', () async {
        await signedPreKeyStore.clearAllSignedPreKeys();
        expect(signedPreKeyStore.signedPreKeyCount, equals(0));
      });

      test('should check if signed pre-key exists (false for non-existent)', () async {
        expect(await signedPreKeyStore.containsSignedPreKey(999), isFalse);
      });
    });

    group('HiveSenderKeyStore Tests', () {
      late HiveSenderKeyStore senderKeyStore;
      late SenderKeyName testSenderKeyName;
      late SenderKeyRecord testSenderKey;

      setUp(() async {
        senderKeyStore = HiveSenderKeyStore();
        await senderKeyStore.initialize();
        
        testSenderKeyName = SenderKeyName('group123', SignalProtocolAddress('user123', 1));
        testSenderKey = SenderKeyRecord();
      });

      tearDown(() async {
        await senderKeyStore.close();
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
        expect(senderKeyStore.senderKeyCount, equals(0));
        
        await senderKeyStore.storeSenderKey(testSenderKeyName, testSenderKey);
        expect(senderKeyStore.senderKeyCount, equals(1));
      });

      test('should clear all sender keys', () async {
        await senderKeyStore.storeSenderKey(testSenderKeyName, testSenderKey);
        expect(senderKeyStore.senderKeyCount, equals(1));
        
        await senderKeyStore.clearAllSenderKeys();
        expect(senderKeyStore.senderKeyCount, equals(0));
      });
    });

    group('HiveRegistry Tests', () {
      test('should register adapters without throwing', () {
        expect(() => HiveRegistry.registerAdapters(), returnsNormally);
      });

      test('should handle multiple registrations', () {
        HiveRegistry.registerAdapters();
        expect(() => HiveRegistry.registerAdapters(), returnsNormally);
      });
    });
  });
}
