import 'package:flutter_test/flutter_test.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import 'dart:typed_data';
import 'dart:convert';

/// Test real Signal Protocol encryption/decryption using in-memory stores
/// This tests the actual crypto operations without external dependencies
void main() {
  group('Signal Protocol Encryption/Decryption Tests (Real Crypto)', () {
    late SignalProtocolAddress aliceAddress;
    late SignalProtocolAddress bobAddress;
    
    late InMemorySessionStore aliceSessionStore;
    late InMemoryPreKeyStore alicePreKeyStore;
    late InMemorySignedPreKeyStore aliceSignedPreKeyStore;
    late InMemoryIdentityKeyStore aliceIdentityStore;
    
    late InMemorySessionStore bobSessionStore;
    late InMemoryPreKeyStore bobPreKeyStore;
    late InMemorySignedPreKeyStore bobSignedPreKeyStore;
    late InMemoryIdentityKeyStore bobIdentityStore;
    
    setUpAll(() async {
      // Initialize test environment
      TestWidgetsFlutterBinding.ensureInitialized();
    });
    
    setUp(() async {
      // Create protocol addresses
      aliceAddress = SignalProtocolAddress('alice', 1);
      bobAddress = SignalProtocolAddress('bob', 1);
      
      // Initialize Alice's stores
      final aliceIdentityKeyPair = generateIdentityKeyPair();
      final aliceRegistrationId = generateRegistrationId(false);
      aliceSessionStore = InMemorySessionStore();
      alicePreKeyStore = InMemoryPreKeyStore();
      aliceSignedPreKeyStore = InMemorySignedPreKeyStore();
      aliceIdentityStore = InMemoryIdentityKeyStore(aliceIdentityKeyPair, aliceRegistrationId);
      
      // Initialize Bob's stores
      final bobIdentityKeyPair = generateIdentityKeyPair();
      final bobRegistrationId = generateRegistrationId(false);
      bobSessionStore = InMemorySessionStore();
      bobPreKeyStore = InMemoryPreKeyStore();
      bobSignedPreKeyStore = InMemorySignedPreKeyStore();
      bobIdentityStore = InMemoryIdentityKeyStore(bobIdentityKeyPair, bobRegistrationId);
      
      // Generate and store Alice's keys
      final alicePreKeys = generatePreKeys(0, 10);
      for (final preKey in alicePreKeys) {
        await alicePreKeyStore.storePreKey(preKey.id, preKey);
      }
      final aliceSignedPreKey = generateSignedPreKey(aliceIdentityKeyPair, 0);
      await aliceSignedPreKeyStore.storeSignedPreKey(aliceSignedPreKey.id, aliceSignedPreKey);
      
      // Generate and store Bob's keys
      final bobPreKeys = generatePreKeys(0, 10);
      for (final preKey in bobPreKeys) {
        await bobPreKeyStore.storePreKey(preKey.id, preKey);
      }
      final bobSignedPreKey = generateSignedPreKey(bobIdentityKeyPair, 0);
      await bobSignedPreKeyStore.storeSignedPreKey(bobSignedPreKey.id, bobSignedPreKey);
      
      // Create prekey bundles for session establishment
      final alicePreKeyBundle = PreKeyBundle(
        aliceRegistrationId,
        aliceAddress.getDeviceId(),
        alicePreKeys.first.id,
        alicePreKeys.first.getKeyPair().publicKey,
        aliceSignedPreKey.id,
        aliceSignedPreKey.getKeyPair().publicKey,
        aliceSignedPreKey.signature,
        aliceIdentityKeyPair.getPublicKey(),
      );
      
      final bobPreKeyBundle = PreKeyBundle(
        bobRegistrationId,
        bobAddress.getDeviceId(),
        bobPreKeys.first.id,
        bobPreKeys.first.getKeyPair().publicKey,
        bobSignedPreKey.id,
        bobSignedPreKey.getKeyPair().publicKey,
        bobSignedPreKey.signature,
        bobIdentityKeyPair.getPublicKey(),
      );
      
      // Establish sessions between Alice and Bob
      final aliceSessionBuilder = SessionBuilder(
        aliceSessionStore,
        alicePreKeyStore,
        aliceSignedPreKeyStore,
        aliceIdentityStore,
        bobAddress,
      );
      await aliceSessionBuilder.processPreKeyBundle(bobPreKeyBundle);
      
      final bobSessionBuilder = SessionBuilder(
        bobSessionStore,
        bobPreKeyStore,
        bobSignedPreKeyStore,
        bobIdentityStore,
        aliceAddress,
      );
      await bobSessionBuilder.processPreKeyBundle(alicePreKeyBundle);
      
      print('✓ Setup complete: Alice and Bob have established sessions');
    });
    
    test('Alice can encrypt a message for Bob and Bob can decrypt it', () async {
      const originalMessage = 'Hello from Alice to Bob!';
      final messageBytes = Uint8List.fromList(utf8.encode(originalMessage));
      
      // Alice encrypts message for Bob
      final aliceSessionCipher = SessionCipher(
        aliceSessionStore,
        alicePreKeyStore,
        aliceSignedPreKeyStore,
        aliceIdentityStore,
        bobAddress,
      );
      
      final ciphertext = await aliceSessionCipher.encrypt(messageBytes);
      
      // Verify we got a ciphertext
      expect(ciphertext, isNotNull);
      expect(ciphertext, isA<CiphertextMessage>());
      
      // Bob decrypts the message
      final bobSessionCipher = SessionCipher(
        bobSessionStore,
        bobPreKeyStore,
        bobSignedPreKeyStore,
        bobIdentityStore,
        aliceAddress,
      );
      
      Uint8List decryptedBytes;
      if (ciphertext is PreKeySignalMessage) {
        decryptedBytes = await bobSessionCipher.decrypt(ciphertext);
      } else {
        decryptedBytes = await bobSessionCipher.decryptFromSignal(ciphertext as SignalMessage);
      }
      
      final decryptedMessage = utf8.decode(decryptedBytes);
      
      // Verify decryption was successful
      expect(decryptedMessage, equals(originalMessage));
      print('✓ Alice → Bob: Message encrypted and decrypted successfully');
    });
    
    test('Bob can encrypt a message for Alice and Alice can decrypt it', () async {
      const originalMessage = 'Hello from Bob to Alice!';
      final messageBytes = Uint8List.fromList(utf8.encode(originalMessage));
      
      // Bob encrypts message for Alice
      final bobSessionCipher = SessionCipher(
        bobSessionStore,
        bobPreKeyStore,
        bobSignedPreKeyStore,
        bobIdentityStore,
        aliceAddress,
      );
      
      final ciphertext = await bobSessionCipher.encrypt(messageBytes);
      
      // Verify we got a ciphertext
      expect(ciphertext, isNotNull);
      expect(ciphertext, isA<CiphertextMessage>());
      
      // Alice decrypts the message
      final aliceSessionCipher = SessionCipher(
        aliceSessionStore,
        alicePreKeyStore,
        aliceSignedPreKeyStore,
        aliceIdentityStore,
        bobAddress,
      );
      
      Uint8List decryptedBytes;
      if (ciphertext is PreKeySignalMessage) {
        decryptedBytes = await aliceSessionCipher.decrypt(ciphertext);
      } else {
        decryptedBytes = await aliceSessionCipher.decryptFromSignal(ciphertext as SignalMessage);
      }
      
      final decryptedMessage = utf8.decode(decryptedBytes);
      
      // Verify decryption was successful
      expect(decryptedMessage, equals(originalMessage));
      print('✓ Bob → Alice: Message encrypted and decrypted successfully');
    });
    
    test('Bidirectional messaging works correctly', () async {
      const aliceMessage = 'Hi Bob, this is Alice!';
      const bobReply = 'Hello Alice, Bob here!';
      
      // Alice sends to Bob
      final aliceSessionCipher = SessionCipher(
        aliceSessionStore,
        alicePreKeyStore,
        aliceSignedPreKeyStore,
        aliceIdentityStore,
        bobAddress,
      );
      
      final aliceCiphertext = await aliceSessionCipher.encrypt(
        Uint8List.fromList(utf8.encode(aliceMessage)),
      );
      
      // Bob decrypts Alice's message
      final bobSessionCipher = SessionCipher(
        bobSessionStore,
        bobPreKeyStore,
        bobSignedPreKeyStore,
        bobIdentityStore,
        aliceAddress,
      );
      
      Uint8List bobDecryptedBytes;
      if (aliceCiphertext is PreKeySignalMessage) {
        bobDecryptedBytes = await bobSessionCipher.decrypt(aliceCiphertext);
      } else {
        bobDecryptedBytes = await bobSessionCipher.decryptFromSignal(aliceCiphertext as SignalMessage);
      }
      
      final bobDecryptedMessage = utf8.decode(bobDecryptedBytes);
      expect(bobDecryptedMessage, equals(aliceMessage));
      
      // Bob replies to Alice
      final bobCiphertext = await bobSessionCipher.encrypt(
        Uint8List.fromList(utf8.encode(bobReply)),
      );
      
      // Alice decrypts Bob's reply
      Uint8List aliceDecryptedBytes;
      if (bobCiphertext is PreKeySignalMessage) {
        aliceDecryptedBytes = await aliceSessionCipher.decrypt(bobCiphertext);
      } else {
        aliceDecryptedBytes = await aliceSessionCipher.decryptFromSignal(bobCiphertext as SignalMessage);
      }
      
      final aliceDecryptedMessage = utf8.decode(aliceDecryptedBytes);
      expect(aliceDecryptedMessage, equals(bobReply));
      
      print('✓ Bidirectional messaging works correctly');
    });
    
    test('Multiple sequential messages maintain order and integrity', () async {
      final messages = [
        'Message 1',
        'Message 2',
        'Message 3',
        'Message 4',
        'Message 5',
      ];
      
      final aliceSessionCipher = SessionCipher(
        aliceSessionStore,
        alicePreKeyStore,
        aliceSignedPreKeyStore,
        aliceIdentityStore,
        bobAddress,
      );
      
      final bobSessionCipher = SessionCipher(
        bobSessionStore,
        bobPreKeyStore,
        bobSignedPreKeyStore,
        bobIdentityStore,
        aliceAddress,
      );
      
      final encryptedMessages = <CiphertextMessage>[];
      final decryptedMessages = <String>[];
      
      // Alice encrypts all messages
      for (final message in messages) {
        final ciphertext = await aliceSessionCipher.encrypt(
          Uint8List.fromList(message.codeUnits),
        );
        encryptedMessages.add(ciphertext);
      }
      
      // Bob decrypts all messages in order
      for (final ciphertext in encryptedMessages) {
        Uint8List decryptedBytes;
        if (ciphertext is PreKeySignalMessage) {
          decryptedBytes = await bobSessionCipher.decrypt(ciphertext);
        } else {
          decryptedBytes = await bobSessionCipher.decryptFromSignal(ciphertext as SignalMessage);
        }
        
        final decryptedMessage = String.fromCharCodes(decryptedBytes);
        decryptedMessages.add(decryptedMessage);
      }
      
      // Verify all messages were decrypted correctly and in order
      expect(decryptedMessages.length, equals(messages.length));
      for (int i = 0; i < messages.length; i++) {
        expect(decryptedMessages[i], equals(messages[i]));
      }
      
      print('✓ Sequential messages maintain order and integrity');
    });
    
    test('Different message types and encodings work correctly', () async {
      final testCases = [
        'Simple ASCII message',
        'Unicode: 你好世界 🌍 مرحبا بالعالم',
        'Numbers and symbols: 123!@#\$%^&*()_+-=[]{}|;:,.<>?',
        'Long message: ' + 'A' * 1000,
        'Empty: ',
        'JSON: {"key": "value", "number": 42, "array": [1,2,3]}',
        'Newlines:\nLine 1\nLine 2\nLine 3',
      ];
      
      final aliceSessionCipher = SessionCipher(
        aliceSessionStore,
        alicePreKeyStore,
        aliceSignedPreKeyStore,
        aliceIdentityStore,
        bobAddress,
      );
      
      final bobSessionCipher = SessionCipher(
        bobSessionStore,
        bobPreKeyStore,
        bobSignedPreKeyStore,
        bobIdentityStore,
        aliceAddress,
      );
      
      for (final testMessage in testCases) {
        // Encrypt with Alice using proper UTF-8 encoding
        final messageBytes = Uint8List.fromList(utf8.encode(testMessage));
        final ciphertext = await aliceSessionCipher.encrypt(messageBytes);
        
        // Decrypt with Bob
        Uint8List decryptedBytes;
        if (ciphertext is PreKeySignalMessage) {
          decryptedBytes = await bobSessionCipher.decrypt(ciphertext);
        } else {
          decryptedBytes = await bobSessionCipher.decryptFromSignal(ciphertext as SignalMessage);
        }
        
        final decryptedMessage = utf8.decode(decryptedBytes);
        expect(decryptedMessage, equals(testMessage));
      }
      
      print('✓ Different message types and encodings work correctly');
    });
    
    test('Session state verification', () async {
      // Verify sessions exist
      expect(await aliceSessionStore.containsSession(bobAddress), isTrue);
      expect(await bobSessionStore.containsSession(aliceAddress), isTrue);
      
      print('✓ Session states verified');
    });
    
    test('Key ratcheting works with multiple messages', () async {
      final aliceSessionCipher = SessionCipher(
        aliceSessionStore,
        alicePreKeyStore,
        aliceSignedPreKeyStore,
        aliceIdentityStore,
        bobAddress,
      );
      
      final bobSessionCipher = SessionCipher(
        bobSessionStore,
        bobPreKeyStore,
        bobSignedPreKeyStore,
        bobIdentityStore,
        aliceAddress,
      );
      
      // Send multiple messages back and forth to test ratcheting
      for (int i = 1; i <= 5; i++) {
        // Alice to Bob
        final aliceMessage = 'Alice message $i';
        final aliceCiphertext = await aliceSessionCipher.encrypt(
          Uint8List.fromList(aliceMessage.codeUnits),
        );
        
        Uint8List bobDecryptedBytes;
        if (aliceCiphertext is PreKeySignalMessage) {
          bobDecryptedBytes = await bobSessionCipher.decrypt(aliceCiphertext);
        } else {
          bobDecryptedBytes = await bobSessionCipher.decryptFromSignal(aliceCiphertext as SignalMessage);
        }
        
        final bobDecryptedMessage = String.fromCharCodes(bobDecryptedBytes);
        expect(bobDecryptedMessage, equals(aliceMessage));
        
        // Bob to Alice
        final bobMessage = 'Bob reply $i';
        final bobCiphertext = await bobSessionCipher.encrypt(
          Uint8List.fromList(bobMessage.codeUnits),
        );
        
        Uint8List aliceDecryptedBytes;
        if (bobCiphertext is PreKeySignalMessage) {
          aliceDecryptedBytes = await aliceSessionCipher.decrypt(bobCiphertext);
        } else {
          aliceDecryptedBytes = await aliceSessionCipher.decryptFromSignal(bobCiphertext as SignalMessage);
        }
        
        final aliceDecryptedMessage = String.fromCharCodes(aliceDecryptedBytes);
        expect(aliceDecryptedMessage, equals(bobMessage));
      }
      
      print('✓ Key ratcheting works correctly with multiple messages');
    });
    
    test('Error handling: Invalid ciphertext fails gracefully', () async {
      final bobSessionCipher = SessionCipher(
        bobSessionStore,
        bobPreKeyStore,
        bobSignedPreKeyStore,
        bobIdentityStore,
        aliceAddress,
      );
      
      // Try to decrypt invalid data
      expect(
        () async {
          // Create an invalid SignalMessage
          final invalidData = Uint8List.fromList([1, 2, 3, 4, 5]);
          final invalidMessage = SignalMessage.fromSerialized(invalidData);
          await bobSessionCipher.decryptFromSignal(invalidMessage);
        },
        throwsA(isA<Exception>()),
      );
      
      print('✓ Invalid ciphertext handling works correctly');
    });
    
    test('Performance: Encrypt/decrypt multiple messages efficiently', () async {
      const messageCount = 100;
      final stopwatch = Stopwatch()..start();
      
      final aliceSessionCipher = SessionCipher(
        aliceSessionStore,
        alicePreKeyStore,
        aliceSignedPreKeyStore,
        aliceIdentityStore,
        bobAddress,
      );
      
      final bobSessionCipher = SessionCipher(
        bobSessionStore,
        bobPreKeyStore,
        bobSignedPreKeyStore,
        bobIdentityStore,
        aliceAddress,
      );
      
      // Encrypt messages
      final encryptedMessages = <CiphertextMessage>[];
      for (int i = 0; i < messageCount; i++) {
        final message = 'Performance test message $i';
        final ciphertext = await aliceSessionCipher.encrypt(
          Uint8List.fromList(message.codeUnits),
        );
        encryptedMessages.add(ciphertext);
      }
      
      // Decrypt messages
      final decryptedMessages = <String>[];
      for (final ciphertext in encryptedMessages) {
        Uint8List decryptedBytes;
        if (ciphertext is PreKeySignalMessage) {
          decryptedBytes = await bobSessionCipher.decrypt(ciphertext);
        } else {
          decryptedBytes = await bobSessionCipher.decryptFromSignal(ciphertext as SignalMessage);
        }
        
        final decryptedMessage = String.fromCharCodes(decryptedBytes);
        decryptedMessages.add(decryptedMessage);
      }
      
      stopwatch.stop();
      
      // Verify all messages
      expect(decryptedMessages.length, equals(messageCount));
      for (int i = 0; i < messageCount; i++) {
        expect(decryptedMessages[i], equals('Performance test message $i'));
      }
      
      print('✓ Processed $messageCount messages in ${stopwatch.elapsedMilliseconds}ms');
      
      // Performance should be reasonable
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 seconds for 100 messages
    });
  });
  
  group('Signal Protocol Error Scenarios', () {
    test('Decrypt without session fails appropriately', () async {
      // Create stores without establishing sessions
      final bobAddress = SignalProtocolAddress('bob', 1);
      
      final aliceIdentityKeyPair = generateIdentityKeyPair();
      final aliceRegistrationId = generateRegistrationId(false);
      final aliceSessionStore = InMemorySessionStore();
      final alicePreKeyStore = InMemoryPreKeyStore();
      final aliceSignedPreKeyStore = InMemorySignedPreKeyStore();
      final aliceIdentityStore = InMemoryIdentityKeyStore(aliceIdentityKeyPair, aliceRegistrationId);
      
      // Try to encrypt without establishing session
      final aliceSessionCipher = SessionCipher(
        aliceSessionStore,
        alicePreKeyStore,
        aliceSignedPreKeyStore,
        aliceIdentityStore,
        bobAddress,
      );
      
      expect(
        () async {
          await aliceSessionCipher.encrypt(Uint8List.fromList('test'.codeUnits));
        },
        throwsA(isA<AssertionError>()),
      );
      
      print('✓ Encryption without session fails as expected');
    });
  });
}
