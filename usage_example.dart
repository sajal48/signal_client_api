/// Real-world usage example of Signal Protocol Flutter API
/// This demonstrates how to use the package for secure messaging between users

import 'package:signal_protocol_flutter/signal_protocol_flutter.dart';

void main() async {
  print('🔐 Signal Protocol Flutter - Real Usage Example\n');
  
  // Example 1: Basic Setup and Initialization
  await basicSetupExample();
  
  // Example 2: Two-User Messaging Scenario
  await twoUserMessagingExample();
  
  // Example 3: Key Management
  await keyManagementExample();
  
  // Example 4: Firebase Integration
  await firebaseIntegrationExample();
  
  // Example 5: Error Handling
  await errorHandlingExample();
}

/// Example 1: Basic setup and initialization
Future<void> basicSetupExample() async {
  print('📱 Example 1: Basic Setup and Initialization');
  print('=' * 50);
  
  try {
    // Initialize Firebase configuration
    final firebaseConfig = FirebaseConfig();
    await FirebaseConfig.initialize(
      databaseURL: 'https://your-project-default-rtdb.firebaseio.com/',
    );
    
    // Create and initialize Signal Protocol API
    final signalApi = SignalProtocolApi();
    
    await signalApi.initialize(
      userId: 'alice@example.com',
      firebaseConfig: firebaseConfig,
    );
    
    print('✅ Signal Protocol initialized successfully');
    print('   User ID: ${signalApi.userId}');
    print('   Device ID: ${signalApi.deviceId}');
    print('   Initialized: ${signalApi.isInitialized}');
    
    // Clean up
    await signalApi.dispose();
    
  } catch (e) {
    print('❌ Error in basic setup: $e');
  }
  
  print('\n');
}

/// Example 2: Complete two-user messaging scenario
Future<void> twoUserMessagingExample() async {
  print('💬 Example 2: Two-User Messaging Scenario');
  print('=' * 50);
  
  try {
    // Setup Firebase
    final firebaseConfig = FirebaseConfig();
    await FirebaseConfig.initialize(
      databaseURL: 'https://your-project-default-rtdb.firebaseio.com/',
    );
    
    // Initialize Alice's Signal client
    final aliceApi = SignalProtocolApi();
    await aliceApi.initialize(
      userId: 'alice@example.com',
      firebaseConfig: firebaseConfig,
    );
    print('👩 Alice initialized');
    
    // Initialize Bob's Signal client  
    final bobApi = SignalProtocolApi();
    await bobApi.initialize(
      userId: 'bob@example.com', 
      firebaseConfig: firebaseConfig,
    );
    print('👨 Bob initialized');
    
    // Alice uploads her keys to Firebase
    await aliceApi.uploadKeysToFirebase();
    print('🔑 Alice uploaded keys to Firebase');
    
    // Bob uploads his keys to Firebase
    await bobApi.uploadKeysToFirebase();
    print('🔑 Bob uploaded keys to Firebase');
    
    // Bob checks if Alice has keys available
    final aliceHasKeys = await bobApi.hasKeysForUser('alice@example.com');
    print('🔍 Alice has keys available: $aliceHasKeys');
    
    // Alice checks if Bob has keys available
    final bobHasKeys = await aliceApi.hasKeysForUser('bob@example.com');
    print('🔍 Bob has keys available: $bobHasKeys');
    
    if (aliceHasKeys && bobHasKeys) {
      print('✅ Both users have keys - messaging is possible!');
      
      // In a real app, you would now:
      // 1. Fetch recipient's keys from Firebase
      // 2. Establish sessions using the core crypto API
      // 3. Encrypt/decrypt messages
      
      print('📝 Next steps:');
      print('   - Fetch keys using refreshUserKeys()');
      print('   - Use core crypto API for encryption/decryption');
      print('   - See real_signal_encryption_test.dart for crypto examples');
    }
    
    // Clean up
    await aliceApi.dispose();
    await bobApi.dispose();
    
  } catch (e) {
    print('❌ Error in messaging example: $e');
  }
  
  print('\n');
}

/// Example 3: Key management operations
Future<void> keyManagementExample() async {
  print('🗝️ Example 3: Key Management');
  print('=' * 50);
  
  try {
    // Initialize Signal API
    final firebaseConfig = FirebaseConfig();
    await FirebaseConfig.initialize(
      databaseURL: 'https://your-project-default-rtdb.firebaseio.com/',
    );
    
    final signalApi = SignalProtocolApi();
    await signalApi.initialize(
      userId: 'keymanager@example.com',
      firebaseConfig: firebaseConfig,
    );
    
    // Get instance information
    final instanceInfo = await signalApi.getInstanceInfo();
    print('📊 Instance Information:');
    instanceInfo.forEach((key, value) {
      print('   $key: $value');
    });
    
    // Upload keys to Firebase
    await signalApi.uploadKeysToFirebase();
    print('🔑 Keys uploaded to Firebase');
    
    // Check if a user has keys
    final hasKeys = await signalApi.hasKeysForUser('nonexistent@example.com');
    print('🔍 Non-existent user has keys: $hasKeys');
    
    // Refresh user keys (fetch from Firebase)
    try {
      await signalApi.refreshUserKeys('someuser@example.com');
      print('🔄 Keys refreshed for user');
    } catch (e) {
      print('⚠️ Could not refresh keys (user may not exist): $e');
    }
    
    // Clean up
    await signalApi.dispose();
    
  } catch (e) {
    print('❌ Error in key management: $e');
  }
  
  print('\n');
}

/// Example 4: Firebase integration features
Future<void> firebaseIntegrationExample() async {
  print('🔥 Example 4: Firebase Integration');
  print('=' * 50);
  
  try {
    // Initialize Firebase with custom settings
    final firebaseConfig = FirebaseConfig();
    await FirebaseConfig.initialize(
      databaseURL: 'https://your-project-default-rtdb.firebaseio.com/',
    );
    
    // Initialize Signal API
    final signalApi = SignalProtocolApi();
    await signalApi.initialize(
      userId: 'firebase-user@example.com',
      firebaseConfig: firebaseConfig,
    );
    
    // Check real-time sync status
    print('🔄 Real-time sync enabled: ${signalApi.isRealTimeSyncEnabled}');
    
    // Upload keys to Firebase
    await signalApi.uploadKeysToFirebase();
    print('🔑 Keys uploaded to Firebase');
    
    // Demonstrate key checking across users
    final users = ['user1@example.com', 'user2@example.com', 'user3@example.com'];
    
    for (final user in users) {
      final hasKeys = await signalApi.hasKeysForUser(user);
      print('👤 $user has keys: $hasKeys');
    }
    
    // Get storage statistics
    final instanceInfo = await signalApi.getInstanceInfo();
    if (instanceInfo.containsKey('storageStats')) {
      print('💾 Storage Statistics:');
      final stats = instanceInfo['storageStats'] as Map<String, dynamic>;
      stats.forEach((key, value) {
        print('   $key: $value');
      });
    }
    
    // Clean up
    await signalApi.dispose();
    
  } catch (e) {
    print('❌ Error in Firebase integration: $e');
  }
  
  print('\n');
}

/// Example 5: Error handling and validation
Future<void> errorHandlingExample() async {
  print('⚠️ Example 5: Error Handling and Validation');
  print('=' * 50);
  
  try {
    // Demonstrate validation errors
    print('🔍 Testing input validation...');
    
    // Test invalid user ID
    try {
      Validators.validateUserId('');
      print('✅ Empty user ID validation passed (unexpected)');
    } catch (e) {
      print('❌ Empty user ID properly rejected: ${e.runtimeType}');
    }
    
    // Test invalid device ID
    try {
      Validators.validateDeviceId(-1);
      print('✅ Negative device ID validation passed (unexpected)');
    } catch (e) {
      print('❌ Negative device ID properly rejected: ${e.runtimeType}');
    }
    
    // Test invalid message
    try {
      Validators.validateMessage('');
      print('✅ Empty message validation passed (unexpected)');
    } catch (e) {
      print('❌ Empty message properly rejected: ${e.runtimeType}');
    }
    
    // Test invalid Firebase URL
    try {
      Validators.validateFirebaseUrl('not-a-url');
      print('✅ Invalid URL validation passed (unexpected)');
    } catch (e) {
      print('❌ Invalid URL properly rejected: ${e.runtimeType}');
    }
    
    // Demonstrate API error handling
    print('\n🔍 Testing API error handling...');
    
    final signalApi = SignalProtocolApi();
    
    // Try to use API before initialization
    try {
      await signalApi.uploadKeysToFirebase();
      print('✅ Uninitialized API call passed (unexpected)');
    } catch (e) {
      print('❌ Uninitialized API call properly rejected: ${e.runtimeType}');
    }
    
    // Try to check keys for invalid user
    try {
      // First initialize the API
      final firebaseConfig = FirebaseConfig();
      await FirebaseConfig.initialize(
        databaseURL: 'https://your-project-default-rtdb.firebaseio.com/',
      );
      
      await signalApi.initialize(
        userId: 'error-test@example.com',
        firebaseConfig: firebaseConfig,
      );
      
      // Now test with invalid user ID format
      final hasKeys = await signalApi.hasKeysForUser('invalid user id with spaces');
      print('🔍 Invalid user ID check result: $hasKeys');
      
    } catch (e) {
      print('❌ Invalid user ID check properly handled: ${e.runtimeType}');
    } finally {
      await signalApi.dispose();
    }
    
  } catch (e) {
    print('❌ Error in error handling example: $e');
  }
  
  print('\n');
}

/// Helper class to demonstrate proper error handling patterns
class MessagingService {
  final SignalProtocolApi _signalApi = SignalProtocolApi();
  
  Future<bool> initializeForUser(String userId, String firebaseUrl) async {
    try {
      // Validate inputs
      Validators.validateUserId(userId);
      Validators.validateFirebaseUrl(firebaseUrl);
      
      // Initialize Firebase
      final firebaseConfig = FirebaseConfig();
      await FirebaseConfig.initialize(databaseURL: firebaseUrl);
      
      // Initialize Signal Protocol
      await _signalApi.initialize(
        userId: userId,
        firebaseConfig: firebaseConfig,
      );
      
      return true;
    } on ValidationException catch (e) {
      print('❌ Validation error: ${e.message}');
      return false;
    } on InitializationException catch (e) {
      print('❌ Initialization error: ${e.message}');
      return false;
    } catch (e) {
      print('❌ Unexpected error: $e');
      return false;
    }
  }
  
  Future<bool> canMessageUser(String recipientUserId) async {
    try {
      if (!_signalApi.isInitialized) {
        throw StateError('Service not initialized');
      }
      
      Validators.validateUserId(recipientUserId);
      return await _signalApi.hasKeysForUser(recipientUserId);
    } catch (e) {
      print('❌ Error checking if can message user: $e');
      return false;
    }
  }
  
  Future<void> dispose() async {
    await _signalApi.dispose();
  }
}

/// Real-world usage tips and best practices
void printUsageTips() {
  print('💡 Usage Tips and Best Practices');
  print('=' * 50);
  print('');
  
  print('🔧 Setup:');
  print('   1. Always validate user inputs before API calls');
  print('   2. Initialize Firebase before Signal Protocol');
  print('   3. Handle initialization errors gracefully');
  print('');
  
  print('🔑 Key Management:');
  print('   1. Upload keys after successful initialization');
  print('   2. Check for recipient keys before messaging');
  print('   3. Refresh keys periodically for active users');
  print('');
  
  print('💬 Messaging:');
  print('   1. Use the core crypto API for actual encryption');
  print('   2. See test files for complete crypto examples');
  print('   3. Handle network errors for Firebase operations');
  print('');
  
  print('🧹 Cleanup:');
  print('   1. Always call dispose() when done');
  print('   2. Use try-finally blocks for proper cleanup');
  print('   3. Handle cleanup errors gracefully');
  print('');
  
  print('🔍 Testing:');
  print('   1. Run "flutter test" to see all examples working');
  print('   2. Check real_signal_encryption_test.dart for crypto');
  print('   3. Use the example app for UI integration');
}
