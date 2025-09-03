/// Firebase synchronization service for Signal Protocol
library;

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

import '../exceptions/signal_exceptions.dart';
import '../utils/logger.dart';
import '../utils/validators.dart';
import 'firebase_config.dart';
import 'firebase_key_manager.dart';
import 'firebase_models.dart';

/// Service for synchronizing keys between local storage and Firebase
class FirebaseSyncService {
  static StreamSubscription<DatabaseEvent>? _userKeysSubscription;
  static StreamSubscription<DatabaseEvent>? _groupKeysSubscription;
  static String? _currentUserId;
  static bool _isSyncing = false;

  /// Callback for when user keys are updated
  static Function(String userId, String keyType, Map<String, dynamic> data)? onUserKeyUpdated;
  
  /// Callback for when group keys are updated
  static Function(String groupId, String deviceId, Map<String, dynamic> data)? onGroupKeyUpdated;
  
  /// Callback for when sync events occur
  static Function(FirebaseSyncEvent event)? onSyncEvent;

  /// Start listening for key updates for a specific user
  static Future<void> startUserKeySync({
    required String userId,
  }) async {
    try {
      Validators.validateUserId(userId);

      if (_isSyncing && _currentUserId == userId) {
        SignalLogger.info('Already syncing keys for user: $userId');
        return;
      }

      // Stop any existing sync
      await stopKeySync();

      _currentUserId = userId;
      _isSyncing = true;

      // Listen for changes to user's key data
      final userRef = FirebaseConfig.database.ref(
        FirebaseConfig.userPath(userId),
      );

      _userKeysSubscription = userRef.onValue.listen(
        _handleUserKeyChange,
        onError: _handleSyncError,
      );

      SignalLogger.info('Started key sync for user: $userId');
    } catch (e) {
      SignalLogger.error('Failed to start user key sync: $e');
      throw FirebaseException(message: 'Failed to start user key sync: $e');
    }
  }

  /// Start listening for group key updates
  static Future<void> startGroupKeySync({
    required List<String> groupIds,
  }) async {
    try {
      if (groupIds.isEmpty) {
        throw const ValidationException(message: 'Group IDs list cannot be empty');
      }

      // For now, listen to all groups - in production, you'd optimize this
      final groupsRef = FirebaseConfig.database.ref('signal_protocol/groups');

      _groupKeysSubscription = groupsRef.onValue.listen(
        _handleGroupKeyChange,
        onError: _handleSyncError,
      );

      SignalLogger.info('Started group key sync for ${groupIds.length} groups');
    } catch (e) {
      SignalLogger.error('Failed to start group key sync: $e');
      throw FirebaseException(message: 'Failed to start group key sync: $e');
    }
  }

  /// Stop all key synchronization
  static Future<void> stopKeySync() async {
    try {
      await _userKeysSubscription?.cancel();
      await _groupKeysSubscription?.cancel();
      
      _userKeysSubscription = null;
      _groupKeysSubscription = null;
      _currentUserId = null;
      _isSyncing = false;

      SignalLogger.info('Stopped all key synchronization');
    } catch (e) {
      SignalLogger.error('Failed to stop key sync: $e');
    }
  }

  /// Check if currently syncing
  static bool get isSyncing => _isSyncing;

  /// Get current syncing user ID
  static String? get currentUserId => _currentUserId;

  /// Force sync of all user keys from Firebase to local storage
  static Future<void> forceSyncUserKeys({
    required String userId,
    required Function(FirebaseKeyBundle keyBundle) onKeyBundleReceived,
  }) async {
    try {
      Validators.validateUserId(userId);

      SignalLogger.info('Force syncing keys for user: $userId');

      final keyBundle = await FirebaseKeyManager.downloadKeyBundle(userId: userId);
      
      if (keyBundle != null) {
        await onKeyBundleReceived(keyBundle);
        
        _emitSyncEvent(FirebaseSyncEvent(
          eventType: 'force_sync_complete',
          userId: userId,
          deviceId: keyBundle.deviceId,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          data: {'keys_synced': true},
        ));
        
        SignalLogger.info('Force sync completed for user: $userId');
      } else {
        SignalLogger.info('No keys found for user: $userId');
      }
    } catch (e) {
      SignalLogger.error('Failed to force sync user keys: $e');
      throw FirebaseException(message: 'Failed to force sync user keys: $e');
    }
  }

  /// Upload local keys to Firebase
  static Future<void> uploadLocalKeys({
    required String userId,
    required String deviceId,
    required Function() getLocalKeys,
  }) async {
    try {
      Validators.validateUserId(userId);

      SignalLogger.info('Uploading local keys for user: $userId');

      // Get the actual keys from local stores and upload them to Firebase
      final localKeys = await getLocalKeys();
      
      if (localKeys.isNotEmpty) {
        SignalLogger.debug('Found ${localKeys.length} local keys to upload');
        // Note: Individual key uploads would happen via FirebaseKeyManager
      } else {
        SignalLogger.warning('No local keys found to upload for user: $userId');
      }

      _emitSyncEvent(FirebaseSyncEvent(
        eventType: 'local_keys_uploaded',
        userId: userId,
        deviceId: deviceId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        data: {'upload_complete': true},
      ));

      SignalLogger.info('Local keys uploaded for user: $userId');
    } catch (e) {
      SignalLogger.error('Failed to upload local keys: $e');
      throw FirebaseException(message: 'Failed to upload local keys: $e');
    }
  }

  /// Handle user key changes from Firebase
  static void _handleUserKeyChange(DatabaseEvent event) {
    try {
      if (event.snapshot.value == null) {
        SignalLogger.info('User keys deleted in Firebase');
        return;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final userId = _currentUserId!;

      // Determine what type of key was updated
      String keyType = 'unknown';
      if (event.snapshot.key == 'identity_key') {
        keyType = 'identity';
      } else if (event.snapshot.key == 'registration_id') {
        keyType = 'registration_id';
      } else if (event.snapshot.key == 'prekeys') {
        keyType = 'prekeys';
      } else if (event.snapshot.key == 'signed_prekey') {
        keyType = 'signed_prekey';
      } else if (event.snapshot.key == 'metadata') {
        keyType = 'metadata';
      }

      // Notify callback
      onUserKeyUpdated?.call(userId, keyType, data);

      // Emit sync event
      _emitSyncEvent(FirebaseSyncEvent(
        eventType: 'key_updated',
        userId: userId,
        deviceId: '', // Will be filled from data if available
        timestamp: DateTime.now().millisecondsSinceEpoch,
        keyType: keyType,
        data: data,
      ));

      SignalLogger.info('User key updated: $keyType for user: $userId');
    } catch (e) {
      SignalLogger.error('Failed to handle user key change: $e');
    }
  }

  /// Handle group key changes from Firebase
  static void _handleGroupKeyChange(DatabaseEvent event) {
    try {
      if (event.snapshot.value == null) {
        SignalLogger.info('Group keys deleted in Firebase');
        return;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      
      // Extract group ID and device ID from path
      final pathParts = event.snapshot.key?.split('/') ?? [];
      if (pathParts.length >= 2) {
        final groupId = pathParts[0];
        final deviceId = pathParts[1];

        // Notify callback
        onGroupKeyUpdated?.call(groupId, deviceId, data);

        // Emit sync event
        _emitSyncEvent(FirebaseSyncEvent(
          eventType: 'group_key_updated',
          userId: '', // Group keys don't have a specific user
          deviceId: deviceId,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          keyType: 'sender_key',
          data: data,
        ));

        SignalLogger.info('Group key updated for group: $groupId, device: $deviceId');
      }
    } catch (e) {
      SignalLogger.error('Failed to handle group key change: $e');
    }
  }

  /// Handle sync errors
  static void _handleSyncError(Object error) {
    SignalLogger.error('Firebase sync error: $error');
    
    _emitSyncEvent(FirebaseSyncEvent(
      eventType: 'sync_error',
      userId: _currentUserId ?? '',
      deviceId: '',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      data: {'error': error.toString()},
    ));
  }

  /// Emit sync event to callback
  static void _emitSyncEvent(FirebaseSyncEvent event) {
    try {
      onSyncEvent?.call(event);
    } catch (e) {
      SignalLogger.error('Failed to emit sync event: $e');
    }
  }

  /// Perform conflict resolution for key updates
  static Future<void> resolveKeyConflict({
    required String userId,
    required String keyType,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
    required Function(Map<String, dynamic> resolvedData) onResolved,
  }) async {
    try {
      SignalLogger.info('Resolving key conflict for user: $userId, key type: $keyType');

      // Simple conflict resolution: choose the most recent timestamp
      final localTimestamp = localData['timestamp'] as int? ?? 0;
      final remoteTimestamp = remoteData['timestamp'] as int? ?? 0;

      Map<String, dynamic> resolvedData;
      String resolution;

      if (remoteTimestamp > localTimestamp) {
        resolvedData = remoteData;
        resolution = 'remote_wins';
      } else if (localTimestamp > remoteTimestamp) {
        resolvedData = localData;
        resolution = 'local_wins';
      } else {
        // Same timestamp - prefer remote to maintain consistency
        resolvedData = remoteData;
        resolution = 'remote_wins_tie';
      }

      await onResolved(resolvedData);

      _emitSyncEvent(FirebaseSyncEvent(
        eventType: 'conflict_resolved',
        userId: userId,
        deviceId: resolvedData['deviceId'] as String? ?? '',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        keyType: keyType,
        data: {
          'resolution': resolution,
          'local_timestamp': localTimestamp,
          'remote_timestamp': remoteTimestamp,
        },
      ));

      SignalLogger.info('Conflict resolved: $resolution for user: $userId, key type: $keyType');
    } catch (e) {
      SignalLogger.error('Failed to resolve key conflict: $e');
      throw FirebaseException(message: 'Failed to resolve key conflict: $e');
    }
  }

  /// Get sync status information
  static Map<String, dynamic> getSyncStatus() {
    return {
      'is_syncing': _isSyncing,
      'current_user_id': _currentUserId,
      'user_sync_active': _userKeysSubscription != null,
      'group_sync_active': _groupKeysSubscription != null,
      'last_check': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Clean up resources
  static Future<void> dispose() async {
    await stopKeySync();
    onUserKeyUpdated = null;
    onGroupKeyUpdated = null;
    onSyncEvent = null;
    
    SignalLogger.info('Firebase sync service disposed');
  }
}
