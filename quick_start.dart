/// Quick Start Guide - Signal Protocol Flutter
/// Copy and paste this code to get started quickly

import 'package:signal_protocol_flutter/signal_protocol_flutter.dart';

void main() async {
  await quickStartExample();
}

/// 5-minute quick start example
Future<void> quickStartExample() async {
  print('🚀 Signal Protocol Flutter - Quick Start');
  print('=' * 40);
  
  try {
    // Step 1: Setup Firebase
    print('1️⃣ Setting up Firebase...');
    final firebaseConfig = FirebaseConfig();
    await FirebaseConfig.initialize(
      databaseURL: 'https://your-project-default-rtdb.firebaseio.com/',
    );
    
    // Step 2: Initialize for Alice
    print('2️⃣ Initializing Alice...');
    final alice = SignalProtocolApi();
    await alice.initialize(
      userId: 'alice@example.com',
      firebaseConfig: firebaseConfig,
    );
    
    // Step 3: Initialize for Bob  
    print('3️⃣ Initializing Bob...');
    final bob = SignalProtocolApi();
    await bob.initialize(
      userId: 'bob@example.com',
      firebaseConfig: firebaseConfig,
    );
    
    // Step 4: Upload keys
    print('4️⃣ Uploading keys...');
    await alice.uploadKeysToFirebase();
    await bob.uploadKeysToFirebase();
    
    // Step 5: Check if messaging is possible
    print('5️⃣ Checking if messaging is possible...');
    final aliceCanMessageBob = await alice.hasKeysForUser('bob@example.com');
    final bobCanMessageAlice = await bob.hasKeysForUser('alice@example.com');
    
    print('✅ Alice can message Bob: $aliceCanMessageBob');
    print('✅ Bob can message Alice: $bobCanMessageAlice');
    
    if (aliceCanMessageBob && bobCanMessageAlice) {
      print('🎉 Success! Both users can now message each other');
      print('📝 Next: Use the core crypto API for actual encryption');
      print('   See real_signal_encryption_test.dart for examples');
    }
    
    // Step 6: Cleanup
    await alice.dispose();
    await bob.dispose();
    
  } catch (e) {
    print('❌ Error: $e');
  }
}

/// Production-ready initialization pattern
class SignalService {
  SignalProtocolApi? _api;
  
  Future<bool> initialize(String userId, String firebaseUrl) async {
    try {
      // Validate inputs
      if (userId.isEmpty || firebaseUrl.isEmpty) {
        throw ArgumentError('User ID and Firebase URL cannot be empty');
      }
      
      // Setup Firebase
      final firebaseConfig = FirebaseConfig();
      await FirebaseConfig.initialize(databaseURL: firebaseUrl);
      
      // Initialize Signal Protocol
      _api = SignalProtocolApi();
      await _api!.initialize(
        userId: userId,
        firebaseConfig: firebaseConfig,
      );
      
      // Upload keys immediately
      await _api!.uploadKeysToFirebase();
      
      return true;
    } catch (e) {
      print('Initialization failed: $e');
      return false;
    }
  }
  
  Future<bool> canMessageUser(String userId) async {
    if (_api == null || !_api!.isInitialized) return false;
    
    try {
      return await _api!.hasKeysForUser(userId);
    } catch (e) {
      print('Error checking user keys: $e');
      return false;
    }
  }
  
  Future<void> dispose() async {
    await _api?.dispose();
    _api = null;
  }
  
  bool get isReady => _api?.isInitialized ?? false;
}
