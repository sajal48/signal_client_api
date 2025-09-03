/// Signal Protocol Flutter - REAL Encryption Usage Examples
/// 
/// This file demonstrates both the basic API and the REAL encryption capabilities
/// 
/// Key Features Demonstrated:
/// 1. ⚡ AdvancedSignalProtocolApi - REAL encryption/decryption
/// 2. 🔧 SignalProtocolApi - Core features and key management
/// 3. 🔄 Automatic key sync and session management
/// 4. 📊 Statistics and monitoring
/// 
/// Run: dart usage_example_updated.dart

import 'package:signal_protocol_flutter/signal_protocol_flutter.dart';

Future<void> main() async {
  print('🔐 Signal Protocol Flutter - REAL Encryption Usage Examples');
  print('=' * 70);
  
  // 1. Demonstrate REAL encryption with AdvancedSignalProtocolApi
  await demonstrateRealEncryption();
  
  // 2. Show basic API features
  await demonstrateBasicAPI();
  
  // 3. Compare the two approaches
  await compareApproaches();
  
  print('\n🎉 All usage examples completed!');
}

/// 🔐 REAL Encryption Example using AdvancedSignalProtocolApi
Future<void> demonstrateRealEncryption() async {
  print('\n🎯 === REAL Encryption with AdvancedSignalProtocolApi ===\n');
  
  try {
    print('1️⃣ Initializing Alice with REAL encryption capabilities...');
    
    // Initialize Alice with REAL encryption
    final aliceApi = await AdvancedSignalProtocolApi.initialize(
      userId: 'alice@company.com',
      deviceId: 1,
      generateKeys: true,    // Automatically generate cryptographic keys
      autoSync: true,        // Enable automatic Firebase sync
    );
    
    print('✅ Alice initialized with REAL encryption');
    print('   🔑 Cryptographic keys: Generated and uploaded');
    print('   📡 Auto-sync: Enabled');
    
    print('\n2️⃣ Initializing Bob with REAL encryption capabilities...');
    
    // Initialize Bob with REAL encryption
    final bobApi = await AdvancedSignalProtocolApi.initialize(
      userId: 'bob@company.com',
      deviceId: 1,
      generateKeys: true,
      autoSync: true,
    );
    
    print('✅ Bob initialized with REAL encryption');
    
    // Wait for automatic key sync
    print('\n3️⃣ Waiting for automatic key synchronization...');
    await Future.delayed(Duration(seconds: 2));
    
    // Check if they can message each other
    print('\n4️⃣ Verifying encryption readiness...');
    final aliceHasBobKeys = await AdvancedSignalProtocolApi.hasKeysForUser(
      targetUserId: 'bob@company.com',
    );
    final bobHasAliceKeys = await AdvancedSignalProtocolApi.hasKeysForUser(
      targetUserId: 'alice@company.com',
    );
    
    print('   🔍 Alice has Bob\'s keys: $aliceHasBobKeys');
    print('   🔍 Bob has Alice\'s keys: $bobHasAliceKeys');
    
    if (aliceHasBobKeys && bobHasAliceKeys) {
      print('\n5️⃣ Performing REAL encryption/decryption...');
      
      // Alice encrypts message for Bob using REAL Signal Protocol
      final encryptResult = await aliceApi.encryptMessage(
        recipientUserId: 'bob@company.com',
        recipientDeviceId: 1,
        message: 'Hello Bob! This message is REALLY encrypted using Signal Protocol! 🔐✨',
        createSession: true,
      );
      
      print('✅ Alice encrypted message successfully!');
      print('   📊 Message type: ${encryptResult.messageType}');
      print('   🔐 Ciphertext size: ${encryptResult.ciphertext.serialize().length} bytes');
      print('   ⏰ Timestamp: ${encryptResult.timestamp}');
      
      // Bob decrypts message from Alice using REAL Signal Protocol
      final decryptResult = await bobApi.decryptMessage(
        senderUserId: 'alice@company.com',
        senderDeviceId: 1,
        ciphertext: encryptResult.ciphertext,
        validateSender: true,
      );
      
      print('✅ Bob decrypted message successfully!');
      print('   🔓 Decrypted text: "${decryptResult.plaintext}"');
      print('   📋 Message type: ${decryptResult.messageType}');
      print('   ✅ Sender validated: ${decryptResult.validated}');
      
      // Test bidirectional encryption
      print('\n6️⃣ Testing bidirectional REAL encryption...');
      
      // Bob replies to Alice
      final replyResult = await bobApi.encryptMessage(
        recipientUserId: 'alice@company.com',
        recipientDeviceId: 1,
        message: 'Hi Alice! I received your REAL encrypted message perfectly! 🔓💫',
        createSession: false, // Session already exists
      );
      
      // Alice decrypts Bob's reply
      final replyDecrypted = await aliceApi.decryptMessage(
        senderUserId: 'bob@company.com',
        senderDeviceId: 1,
        ciphertext: replyResult.ciphertext,
        validateSender: true,
      );
      
      print('✅ Bidirectional REAL encryption successful!');
      print('   💬 Bob\'s reply: "${replyDecrypted.plaintext}"');
      
      // Show encryption statistics
      print('\n7️⃣ REAL Encryption Statistics:');
      final aliceStats = await aliceApi.getStorageStatistics();
      final bobStats = await bobApi.getStorageStatistics();
      
      print('   📊 Alice: ${aliceStats.sessionCount} sessions, ${aliceStats.preKeyCount} prekeys');
      print('   📊 Bob: ${bobStats.sessionCount} sessions, ${bobStats.preKeyCount} prekeys');
      print('   🔑 Identity keys exist: Alice=${aliceStats.identityKeyExists}, Bob=${bobStats.identityKeyExists}');
      
    } else {
      print('❌ Key exchange incomplete - cannot perform REAL encryption');
      print('💡 In production: Ensure proper Firebase configuration and network connectivity');
    }
    
    // Clean up
    await aliceApi.dispose();
    await bobApi.dispose();
    
  } catch (e) {
    print('❌ REAL encryption demo failed: $e');
    print('🔧 This demonstrates production error handling');
  }
}

/// 🔧 Basic API Example using SignalProtocolApi
Future<void> demonstrateBasicAPI() async {
  print('\n🎯 === Basic API with SignalProtocolApi ===\n');
  
  try {
    print('1️⃣ Initializing basic Signal Protocol API...');
    
    // Initialize the basic Signal Protocol API
    final signalApi = SignalProtocolApi();
    
    // Check if already initialized
    final info = await signalApi.getInstanceInfo();
    if (info['isInitialized'] == true) {
      print('   ⚠️  Already initialized, cleaning up first...');
      // In a real app, you might want to dispose and reinitialize
    }
    
    // Initialize for a user (requires proper Firebase configuration)
    try {
      // Create a basic Firebase config for demo
      final firebaseConfig = FirebaseConfig();
      
      await signalApi.initialize(
        userId: 'charlie@company.com',
        firebaseConfig: firebaseConfig,
      );
      print('✅ Basic API initialized for charlie@company.com');
    } catch (e) {
      print('⚠️ Basic API initialization skipped (requires Firebase setup): $e');
      print('💡 For production use: Configure Firebase properly');
      return;
    }
    
    // Get updated instance information
    final updatedInfo = await signalApi.getInstanceInfo();
    print('   📊 Instance info: $updatedInfo');
    
    print('\n2️⃣ Managing keys with basic API...');
    
    // Generate and upload keys
    await signalApi.uploadKeysToFirebase();
    print('✅ Keys uploaded to Firebase');
    
    // Check if keys exist for another user
    final hasKeys = await signalApi.hasKeysForUser('david@company.com');
    print('   🔍 Has keys for david@company.com: $hasKeys');
    
    print('\n3️⃣ Getting storage information...');
    
    // Note: Basic API doesn't have getStorageStatistics method
    // This would be available in AdvancedSignalProtocolApi
    print('   📊 Storage statistics not available in basic API');
    print('   💡 Use AdvancedSignalProtocolApi for detailed statistics');
    print('   ✅ Basic API provides core functionality only');
    
    print('\n✅ Basic API example completed successfully!');
    
  } catch (e) {
    print('❌ Basic API demo failed: $e');
  }
}

/// 📊 Compare Both Approaches
Future<void> compareApproaches() async {
  print('\n🎯 === Comparing Basic vs Advanced APIs ===\n');
  
  print('📋 Feature Comparison:');
  print('');
  print('🔧 SignalProtocolApi (Basic):');
  print('   ✅ Core Signal Protocol features');
  print('   ✅ Key management and Firebase sync');
  print('   ✅ Session handling');
  print('   ✅ Storage statistics');
  print('   ❌ No direct encryption/decryption methods');
  print('   ❌ Manual session and key management required');
  print('');
  print('⚡ AdvancedSignalProtocolApi (Production-Ready):');
  print('   ✅ All basic API features');
  print('   ✅ REAL encryption/decryption methods');
  print('   ✅ Automatic key generation and upload');
  print('   ✅ Automatic session creation and management');
  print('   ✅ Background key synchronization');
  print('   ✅ Production-ready error handling');
  print('   ✅ Detailed encryption results and validation');
  print('');
  print('🎯 Recommendation:');
  print('   📱 For production apps: Use AdvancedSignalProtocolApi');
  print('   🔧 For custom implementations: Use SignalProtocolApi as foundation');
  print('   🚀 For quick prototypes: Use the example RealSignalService wrapper');
  print('');
  print('💡 Key Benefits of AdvancedSignalProtocolApi:');
  print('   🔐 Ready-to-use encryption/decryption');
  print('   🔄 Automatic key lifecycle management');
  print('   📡 Background sync and session handling');
  print('   🛡️ Built-in security validations');
  print('   📊 Comprehensive monitoring and statistics');
}
