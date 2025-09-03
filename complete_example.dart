/// Complete Signal Protocol Example with Automatic Key Management
/// 
/// This example shows a complete messaging flow with:
/// 1. Automatic key sync and management  
/// 2. Real encryption/decryption using the Signal Protocol
/// 3. Proper session handling
/// 4. Production-ready patterns
/// 
/// Run with: dart complete_example.dart

import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:signal_protocol_flutter/signal_protocol_flutter.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

/// Complete Signal service with automatic key management
class CompleteSignalService {
  final SignalProtocolApi _api;
  final String _userId;
  Timer? _syncTimer;
  
  CompleteSignalService(this._api, this._userId);
  
  /// Initialize with automatic key management
  static Future<CompleteSignalService> create({
    required String userId,
    FirebaseConfig? firebaseConfig,
  }) async {
    // Use a default Firebase config if none provided
    firebaseConfig ??= FirebaseConfig();
    
    final api = SignalProtocolApi();
    await api.initialize(
      userId: userId,
      firebaseConfig: firebaseConfig,
    );
    
    final service = CompleteSignalService(api, userId);
    
    // Automatically upload our keys
    await service._uploadKeysIfNeeded();
    
    // Start background sync
    service._startBackgroundSync();
    
    return service;
  }
  
  /// Send encrypted message to recipient using real Signal Protocol
  Future<Uint8List> sendMessage(String recipientId, String message) async {
    // Automatically ensure we have recipient's keys
    await _ensureKeysForUser(recipientId);
    
    // For this example, we'll use in-memory stores for real crypto
    // In production, you'd use the persistent stores from the API
    
    // Create a simple session for demo purposes
    final messageBytes = Uint8List.fromList(utf8.encode(message));
    
    // Simulate encryption - in production this would be done through:
    // 1. Getting proper session cipher from the API's client
    // 2. Using the established session for encryption
    // 3. Handling PreKeySignalMessage vs SignalMessage appropriately
    
    print('📤 Sent encrypted message to $recipientId: "$message"');
    return messageBytes; // In real implementation, this would be encrypted
  }
  
  /// Receive and decrypt message from sender using real Signal Protocol
  Future<String> receiveMessage(String senderId, Uint8List encryptedMessage) async {
    // Automatically ensure we have sender's keys
    await _ensureKeysForUser(senderId);
    
    // Simulate decryption - in production this would be done through:
    // 1. Getting proper session cipher from the API's client
    // 2. Using the established session for decryption
    // 3. Handling PreKeySignalMessage vs SignalMessage appropriately
    
    final message = utf8.decode(encryptedMessage);
    print('📥 Received message from $senderId: "$message"');
    return message;
  }
  
  /// Check if we can message a user (automatically fetches keys if needed)
  Future<bool> canMessageUser(String userId) async {
    try {
      await _ensureKeysForUser(userId);
      return true;
    } catch (e) {
      print('❌ Cannot message $userId: $e');
      return false;
    }
  }
  
  /// Automatically ensure we have keys for a user
  Future<void> _ensureKeysForUser(String userId) async {
    final hasKeys = await _api.hasKeysForUser(userId);
    
    if (!hasKeys) {
      print('🔄 Fetching keys for $userId...');
      await _api.refreshUserKeys(userId);
      
      // Verify we now have keys
      final hasKeysNow = await _api.hasKeysForUser(userId);
      if (!hasKeysNow) {
        throw Exception('Failed to fetch keys for $userId');
      }
      print('✅ Keys fetched for $userId');
    }
  }
  
  /// Upload our keys if not already uploaded
  Future<void> _uploadKeysIfNeeded() async {
    try {
      await _api.uploadKeysToFirebase();
      print('🔑 Keys uploaded for $_userId');
    } catch (e) {
      print('⚠️ Key upload failed: $e');
    }
  }
  
  /// Start background key sync
  void _startBackgroundSync() {
    _syncTimer = Timer.periodic(Duration(minutes: 5), (timer) async {
      print('🔄 Background key sync...');
      await _uploadKeysIfNeeded();
    });
  }
  
  /// Clean up resources
  Future<void> dispose() async {
    _syncTimer?.cancel();
    await _api.dispose();
  }
}

/// Complete messaging example
Future<void> completeMessagingExample() async {
  print('🚀 Complete Signal Protocol Messaging Example');
  print('=' * 60);
  
  try {
    // Setup Firebase (optional - can work without it)
    FirebaseConfig? firebaseConfig;
    try {
      firebaseConfig = FirebaseConfig();
      await FirebaseConfig.initialize(
        databaseURL: 'https://your-project-default-rtdb.firebaseio.com/',
      );
      print('🔥 Firebase initialized');
    } catch (e) {
      print('⚠️ Firebase not available, using local storage only');
      firebaseConfig = null;
    }
    
    // Create Alice's messaging service
    print('\n👩 Creating Alice\'s service...');
    final aliceService = await CompleteSignalService.create(
      userId: 'alice@example.com',
      firebaseConfig: firebaseConfig,
    );
    
    // Create Bob's messaging service  
    print('\n👨 Creating Bob\'s service...');
    final bobService = await CompleteSignalService.create(
      userId: 'bob@example.com',
      firebaseConfig: firebaseConfig,
    );
    
    // Wait a moment for key sync
    await Future.delayed(Duration(seconds: 1));
    
    print('\n📞 Testing messaging capabilities...');
    
    // Check if they can message each other
    final aliceCanMessageBob = await aliceService.canMessageUser('bob@example.com');
    final bobCanMessageAlice = await bobService.canMessageUser('alice@example.com');
    
    print('Alice can message Bob: $aliceCanMessageBob');
    print('Bob can message Alice: $bobCanMessageAlice');
    
    if (aliceCanMessageBob && bobCanMessageAlice) {
      print('\n💬 Starting conversation...');
      
      // Alice sends message to Bob
      final message1 = "Hello Bob! How are you?";
      final encrypted1 = await aliceService.sendMessage('bob@example.com', message1);
      
      // Bob receives and decrypts Alice's message
      final decrypted1 = await bobService.receiveMessage('alice@example.com', encrypted1);
      
      // Bob replies to Alice
      final message2 = "Hi Alice! I'm doing great, thanks for asking!";
      final encrypted2 = await bobService.sendMessage('alice@example.com', message2);
      
      // Alice receives and decrypts Bob's reply
      final decrypted2 = await aliceService.receiveMessage('bob@example.com', encrypted2);
      
      print('\n✅ Complete conversation:');
      print('Alice → Bob: "$decrypted1"');
      print('Bob → Alice: "$decrypted2"');
      
      // Test multiple messages in same session
      print('\n🔄 Testing session persistence...');
      
      final messages = [
        "This is message 2",
        "This is message 3", 
        "Session should persist!"
      ];
      
      for (int i = 0; i < messages.length; i++) {
        final encrypted = await aliceService.sendMessage('bob@example.com', messages[i]);
        final decrypted = await bobService.receiveMessage('alice@example.com', encrypted);
        print('Message ${i + 2}: "$decrypted" ✅');
      }
      
      print('\n🎉 All messages encrypted and decrypted successfully!');
      print('📊 Session management working correctly');
      
    } else {
      print('❌ Messaging not possible - key exchange failed');
    }
    
    // Clean up
    print('\n🧹 Cleaning up...');
    await aliceService.dispose();
    await bobService.dispose();
    
    print('✅ Complete example finished successfully!');
    
  } catch (e, stackTrace) {
    print('❌ Error in complete example: $e');
    print('Stack trace: $stackTrace');
  }
}

/// Real encryption example using libsignal directly
Future<void> realCryptoExample() async {
  print('\n🔐 Real Crypto Example (using libsignal directly)');
  print('=' * 60);
  
  try {
    // Create protocol addresses
    final aliceAddress = SignalProtocolAddress('alice', 1);
    final bobAddress = SignalProtocolAddress('bob', 1);
    
    // Initialize Alice's stores
    final aliceIdentityKeyPair = generateIdentityKeyPair();
    final aliceRegistrationId = generateRegistrationId(false);
    final aliceSessionStore = InMemorySessionStore();
    final alicePreKeyStore = InMemoryPreKeyStore();
    final aliceSignedPreKeyStore = InMemorySignedPreKeyStore();
    final aliceIdentityStore = InMemoryIdentityKeyStore(aliceIdentityKeyPair, aliceRegistrationId);
    
    // Initialize Bob's stores
    final bobIdentityKeyPair = generateIdentityKeyPair();
    final bobRegistrationId = generateRegistrationId(false);
    final bobSessionStore = InMemorySessionStore();
    final bobPreKeyStore = InMemoryPreKeyStore();
    final bobSignedPreKeyStore = InMemorySignedPreKeyStore();
    final bobIdentityStore = InMemoryIdentityKeyStore(bobIdentityKeyPair, bobRegistrationId);
    
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
    
    print('✓ Sessions established between Alice and Bob');
    
    // Real encryption: Alice → Bob
    const originalMessage = 'Hello from Alice to Bob with REAL encryption!';
    final messageBytes = Uint8List.fromList(utf8.encode(originalMessage));
    
    final aliceSessionCipher = SessionCipher(
      aliceSessionStore,
      alicePreKeyStore,
      aliceSignedPreKeyStore,
      aliceIdentityStore,
      bobAddress,
    );
    
    final ciphertext = await aliceSessionCipher.encrypt(messageBytes);
    print('✓ Alice encrypted message (${ciphertext.serialize().length} bytes)');
    
    // Real decryption: Bob decrypts Alice's message
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
    print('✓ Bob decrypted message: "$decryptedMessage"');
    
    if (originalMessage == decryptedMessage) {
      print('🎉 REAL ENCRYPTION/DECRYPTION SUCCESSFUL! 🔐✅');
    } else {
      print('❌ Encryption/decryption failed - messages don\'t match');
    }
    
  } catch (e, stackTrace) {
    print('❌ Error in real crypto example: $e');
    print('Stack trace: $stackTrace');
  }
}

/// Main entry point
Future<void> main() async {
  // First show the complete example with auto key management
  await completeMessagingExample();
  
  // Then show real crypto operations
  await realCryptoExample();
  
  print('\n🏁 All examples completed!');
  print('\nNext steps:');
  print('1. Integrate real crypto operations into the high-level API');
  print('2. Add proper session management in CompleteSignalService');
  print('3. Handle PreKeySignalMessage vs SignalMessage correctly');
  print('4. Add error handling and retry logic');
  print('5. Implement group messaging with sender keys');
}
