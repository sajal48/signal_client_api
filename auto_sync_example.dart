/// Enhanced Signal Protocol Service with Automatic Key Sync
/// This demonstrates how to make key synchronization more automatic

import 'package:signal_protocol_flutter/signal_protocol_flutter.dart';
import 'dart:async';

/// Enhanced service that handles automatic key synchronization
class AutoSignalService {
  SignalProtocolApi? _api;
  Timer? _syncTimer;
  final Set<String> _userKeyCache = {};
  bool _autoSyncEnabled = true;
  
  /// Initialize with automatic key sync
  Future<bool> initialize({
    required String userId,
    required String firebaseUrl,
    bool enableAutoSync = true,
    Duration syncInterval = const Duration(minutes: 5),
  }) async {
    try {
      // Setup Firebase
      final firebaseConfig = FirebaseConfig();
      await FirebaseConfig.initialize(databaseURL: firebaseUrl);
      
      // Initialize Signal Protocol
      _api = SignalProtocolApi();
      await _api!.initialize(
        userId: userId,
        firebaseConfig: firebaseConfig,
      );
      
      // 🚀 AUTOMATIC: Upload our keys immediately after initialization
      await _automaticKeyUpload();
      
      // 🚀 AUTOMATIC: Start periodic sync if enabled
      if (enableAutoSync) {
        _startAutoSync(syncInterval);
      }
      
      return true;
    } catch (e) {
      print('❌ Initialization failed: $e');
      return false;
    }
  }
  
  /// 🚀 AUTOMATIC: Upload our keys when initialized
  Future<void> _automaticKeyUpload() async {
    try {
      await _api!.uploadKeysToFirebase();
      print('✅ Keys automatically uploaded to Firebase');
    } catch (e) {
      print('⚠️ Failed to upload keys: $e');
    }
  }
  
  /// 🚀 AUTOMATIC: Start periodic key synchronization
  void _startAutoSync(Duration interval) {
    _syncTimer = Timer.periodic(interval, (timer) async {
      await _performBackgroundSync();
    });
    print('🔄 Auto-sync started (every ${interval.inMinutes} minutes)');
  }
  
  /// 🚀 AUTOMATIC: Background sync for all known users
  Future<void> _performBackgroundSync() async {
    if (_api == null || !_api!.isInitialized) return;
    
    try {
      // Refresh keys for all users we've interacted with
      for (final userId in _userKeyCache) {
        await _refreshUserKeysQuietly(userId);
      }
      print('🔄 Background sync completed for ${_userKeyCache.length} users');
    } catch (e) {
      print('⚠️ Background sync failed: $e');
    }
  }
  
  /// 🚀 SMART: Check if user can be messaged (with automatic key fetching)
  Future<bool> canMessageUser(String userId) async {
    if (_api == null || !_api!.isInitialized) return false;
    
    try {
      // First, check if we already have keys
      bool hasKeys = await _api!.hasKeysForUser(userId);
      
      if (!hasKeys) {
        // 🚀 AUTOMATIC: Try to fetch keys if we don't have them
        print('🔍 Keys not found locally, fetching from Firebase...');
        await _api!.refreshUserKeys(userId);
        hasKeys = await _api!.hasKeysForUser(userId);
        
        if (hasKeys) {
          print('✅ Keys fetched automatically for $userId');
        } else {
          print('❌ No keys available for $userId on Firebase');
        }
      }
      
      // Remember this user for future sync
      _userKeyCache.add(userId);
      
      return hasKeys;
    } catch (e) {
      print('❌ Error checking user keys: $e');
      return false;
    }
  }
  
  /// Quietly refresh user keys (used in background sync)
  Future<void> _refreshUserKeysQuietly(String userId) async {
    try {
      await _api!.refreshUserKeys(userId);
    } catch (e) {
      // Silently handle errors in background sync
    }
  }
  
  /// Manual key refresh (for when you need immediate sync)
  Future<bool> forceRefreshUserKeys(String userId) async {
    if (_api == null || !_api!.isInitialized) return false;
    
    try {
      await _api!.refreshUserKeys(userId);
      _userKeyCache.add(userId);
      print('🔄 Force refreshed keys for $userId');
      return true;
    } catch (e) {
      print('❌ Failed to refresh keys for $userId: $e');
      return false;
    }
  }
  
  /// Re-upload our keys (e.g., after key rotation)
  Future<bool> refreshOurKeys() async {
    if (_api == null || !_api!.isInitialized) return false;
    
    try {
      await _api!.uploadKeysToFirebase();
      print('🔄 Re-uploaded our keys to Firebase');
      return true;
    } catch (e) {
      print('❌ Failed to re-upload keys: $e');
      return false;
    }
  }
  
  /// Enable/disable automatic sync
  void setAutoSync(bool enabled, [Duration? interval]) {
    _autoSyncEnabled = enabled;
    
    if (enabled && _syncTimer == null) {
      _startAutoSync(interval ?? const Duration(minutes: 5));
    } else if (!enabled && _syncTimer != null) {
      _syncTimer!.cancel();
      _syncTimer = null;
      print('🛑 Auto-sync disabled');
    }
  }
  
  /// Get sync status
  Map<String, dynamic> getSyncStatus() {
    return {
      'autoSyncEnabled': _autoSyncEnabled,
      'syncTimerActive': _syncTimer?.isActive ?? false,
      'cachedUsers': _userKeyCache.length,
      'isInitialized': _api?.isInitialized ?? false,
    };
  }
  
  /// Dispose and cleanup
  Future<void> dispose() async {
    _syncTimer?.cancel();
    await _api?.dispose();
    _userKeyCache.clear();
    print('🧹 AutoSignalService disposed');
  }
}

/// Example usage of automatic key sync
void main() async {
  await demonstrateAutoSync();
}

Future<void> demonstrateAutoSync() async {
  print('🚀 Automatic Key Sync Demo');
  print('=' * 40);
  
  // Create services for Alice and Bob
  final aliceService = AutoSignalService();
  final bobService = AutoSignalService();
  
  try {
    // Initialize Alice (keys uploaded automatically)
    print('\n👩 Initializing Alice...');
    await aliceService.initialize(
      userId: 'alice@example.com',
      firebaseUrl: 'https://your-project-default-rtdb.firebaseio.com/',
      enableAutoSync: true,
      syncInterval: const Duration(minutes: 2), // Sync every 2 minutes
    );
    
    // Initialize Bob (keys uploaded automatically)
    print('\n👨 Initializing Bob...');
    await bobService.initialize(
      userId: 'bob@example.com',
      firebaseUrl: 'https://your-project-default-rtdb.firebaseio.com/',
      enableAutoSync: true,
    );
    
    // Wait a moment for keys to sync
    await Future.delayed(const Duration(seconds: 2));
    
    // Check if Alice can message Bob (keys fetched automatically if needed)
    print('\n🔍 Alice checking if she can message Bob...');
    final aliceCanMessageBob = await aliceService.canMessageUser('bob@example.com');
    print('   Result: $aliceCanMessageBob');
    
    // Check if Bob can message Alice (keys fetched automatically if needed)
    print('\n🔍 Bob checking if he can message Alice...');
    final bobCanMessageAlice = await bobService.canMessageUser('alice@example.com');
    print('   Result: $bobCanMessageAlice');
    
    // Show sync status
    print('\n📊 Alice sync status:');
    final aliceStatus = aliceService.getSyncStatus();
    aliceStatus.forEach((key, value) => print('   $key: $value'));
    
    print('\n📊 Bob sync status:');
    final bobStatus = bobService.getSyncStatus();
    bobStatus.forEach((key, value) => print('   $key: $value'));
    
    // Demonstrate manual operations
    print('\n🔄 Manual operations:');
    
    // Force refresh (useful when you know keys have changed)
    await aliceService.forceRefreshUserKeys('bob@example.com');
    
    // Re-upload our keys (useful after key rotation)
    await bobService.refreshOurKeys();
    
    // Wait to see background sync in action
    print('\n⏱️ Waiting to demonstrate background sync...');
    await Future.delayed(const Duration(seconds: 5));
    
    print('\n✅ Demo completed!');
    
  } finally {
    // Cleanup
    await aliceService.dispose();
    await bobService.dispose();
  }
}

/// Real-world usage recommendations
void printRecommendations() {
  print('\n💡 Key Sync Recommendations');
  print('=' * 40);
  print('');
  
  print('🚀 AUTOMATIC (Recommended):');
  print('   ✅ Upload keys immediately after initialization');
  print('   ✅ Fetch keys automatically when checking canMessageUser()');
  print('   ✅ Background sync every 5-10 minutes for active users');
  print('   ✅ Re-upload keys after any key rotation');
  print('');
  
  print('📱 USER-TRIGGERED (When Needed):');
  print('   • Force refresh when user reports messaging issues');
  print('   • Manual upload when user changes devices');
  print('   • Sync on app foreground/background events');
  print('');
  
  print('⚡ PERFORMANCE OPTIMIZATIONS:');
  print('   • Cache which users have keys to avoid redundant checks');
  print('   • Batch sync operations when possible');
  print('   • Use background sync with exponential backoff');
  print('   • Only sync keys for users actively being messaged');
  print('');
  
  print('🔧 IMPLEMENTATION TIPS:');
  print('   • Make sync operations idempotent');
  print('   • Handle network failures gracefully');
  print('   • Provide manual refresh option for users');
  print('   • Show sync status in debugging/settings');
}
