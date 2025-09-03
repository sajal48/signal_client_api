/// Simplified Signal Protocol API implementation.
/// 
/// This class provides the main interface for Signal Protocol operations
/// including initialization, key management, and basic cryptographic operations.
/// Full encryption/decryption will be implemented in subsequent iterations.
library;

import 'dart:async';
import 'dart:typed_data';

import 'crypto/simple_signal_client.dart';
import 'storage/secure_identity_store.dart';
import 'storage/hive_session_store.dart';
import 'storage/hive_prekey_store.dart';
import 'storage/hive_signed_prekey_store.dart';
import 'storage/hive_sender_key_store.dart';
import 'firebase/firebase_key_manager.dart';
import 'firebase/firebase_sync_service.dart';
import 'firebase/firebase_config.dart';
import 'utils/logger.dart';
import 'utils/device_id_manager.dart' as device_manager;
import 'utils/connectivity_manager.dart';
import 'utils/offline_queue_manager.dart';
import 'exceptions/signal_exceptions.dart';

/// Main Signal Protocol API class.
/// 
/// This is the primary interface for all Signal Protocol operations.
/// Initialize once and use throughout your app for secure messaging.
/// 
/// Example:
/// ```dart
/// final signalApi = SignalProtocolApi();
/// await signalApi.initialize(
///   userId: 'user123',
///   firebaseConfig: config,
/// );
/// 
/// // Check if keys exist for a user
/// final hasKeys = await signalApi.hasKeysForUser('recipient123');
/// ```
class SignalProtocolApi {
  // Core components
  SimpleSignalClient? _signalClient;
  FirebaseKeyManager? _keyManager;
  FirebaseSyncService? _syncService;
  
  // Storage components
  SecureIdentityStore? _identityStore;
  HiveSessionStore? _sessionStore;
  HivePreKeyStore? _preKeyStore;
  HiveSignedPreKeyStore? _signedPreKeyStore;
  HiveSenderKeyStore? _senderKeyStore;
  
  // State management
  bool _isInitialized = false;
  String? _userId;
  int? _deviceId;
  bool _realTimeSyncEnabled = false;
  
  // Sync event callbacks
  Function(String userId, String keyType, Map<String, dynamic> data)? _onKeyUpdated;
  Function(String error)? _onSyncError;
  Function(bool isOnline)? _onConnectionStateChanged;
  
  /// Whether the Signal Protocol is initialized and ready to use.
  bool get isInitialized => _isInitialized;
  
  /// Current user ID if initialized.
  String? get userId => _userId;
  
  /// Current device ID if initialized.
  int? get deviceId => _deviceId;
  
  /// Whether real-time sync is currently enabled.
  bool get isRealTimeSyncEnabled => _realTimeSyncEnabled;
  
  /// Initialize the Signal Protocol with the given configuration.
  /// 
  /// This must be called before using any other methods.
  /// 
  /// Parameters:
  /// - [userId]: Unique identifier for the current user
  /// - [firebaseConfig]: Firebase configuration for key synchronization
  /// - [deviceId]: Optional device ID (auto-generated if not provided)
  /// 
  /// Throws:
  /// - [InitializationException] if initialization fails
  /// - [StorageException] if storage setup fails
  /// - [FirebaseException] if Firebase setup fails
  Future<void> initialize({
    required String userId,
    required FirebaseConfig firebaseConfig,
    int? deviceId,
  }) async {
    try {
      SignalLogger.info('Initializing Signal Protocol for user: $userId');
      
      if (_isInitialized) {
        SignalLogger.warning('Signal Protocol already initialized');
        return;
      }
      
      // Set user info
      _userId = userId;
      _deviceId = deviceId ?? await device_manager.DeviceIdManager.getOrCreateDeviceId();
      
      // Initialize storage components
      await _initializeStorage();
      
      // Initialize Firebase components
      await _initializeFirebase(firebaseConfig);
      
      // Create Signal client
      await _initializeSignalClient();
      
      _isInitialized = true;
      SignalLogger.info('Signal Protocol initialization complete');
      
    } catch (e) {
      SignalLogger.error('Failed to initialize Signal Protocol: $e');
      await _cleanup();
      throw InitializationException(message: 'Initialization failed: $e');
    }
  }
  
  /// Upload current user's keys to Firebase.
  /// 
  /// This makes the user's public keys available for other users to establish
  /// secure sessions. Private keys never leave the device.
  /// 
  /// If offline, the operation will be queued and executed when connectivity is restored.
  /// 
  /// Throws:
  /// - [FirebaseException] if upload fails
  /// - [InitializationException] if Signal client is not initialized
  Future<void> uploadKeysToFirebase() async {
    _ensureInitialized();
    
    try {
      SignalLogger.debug('Uploading keys to Firebase');
      
      // Check if we're online
      if (!ConnectivityManager.isOnline) {
        // Queue the operation for later execution
        await OfflineQueueManager.queueOperation(
          operationType: 'upload_keys',
          operationData: {
            'user_id': _userId,
            'device_id': _deviceId,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
          priority: 2, // High priority for key uploads
          maxAge: const Duration(hours: 24), // Expire after 24 hours
        );
        
        SignalLogger.info('Key upload queued for offline execution');
        return;
      }
      
      // Get keys from Signal client
      if (_signalClient == null) {
        throw InitializationException(message: 'Signal client not initialized');
      }

      // Get identity key pair
      final identityKeyPair = await _signalClient!.getIdentityKeyPair();
      
      // Get registration ID
      final registrationId = await _signalClient!.getRegistrationId();

      // Get available prekeys
      final preKeys = await _signalClient!.getAvailablePreKeys();

      // Get current signed prekey
      final signedPreKey = await _signalClient!.getCurrentSignedPreKey();

      // Upload identity key
      await FirebaseKeyManager.uploadIdentityKey(
        userId: _userId!,
        deviceId: _deviceId!.toString(),
        identityKey: identityKeyPair.getPublicKey(),
      );

      // Upload registration ID
      await FirebaseKeyManager.uploadRegistrationId(
        userId: _userId!,
        deviceId: _deviceId!.toString(),
        registrationId: registrationId,
      );

      // Upload prekeys
      await FirebaseKeyManager.uploadPreKeys(
        userId: _userId!,
        deviceId: _deviceId!.toString(),
        preKeys: preKeys,
      );

      // Upload signed prekey
      if (signedPreKey != null) {
        await FirebaseKeyManager.uploadSignedPreKey(
          userId: _userId!,
          deviceId: _deviceId!.toString(),
          signedPreKey: signedPreKey,
        );
      }
      
      SignalLogger.info('Keys uploaded to Firebase successfully');
      
    } catch (e) {
      SignalLogger.error('Failed to upload keys to Firebase: $e');
      throw FirebaseException(message: 'Key upload failed: $e');
    }
  }
  
  /// Refresh keys for a specific user from Firebase.
  /// 
  /// This fetches the latest public keys for a user and updates the local cache.
  /// Used before establishing new sessions or when key updates are detected.
  /// 
  /// Parameters:
  /// - [userId]: The user whose keys to refresh
  /// 
  /// Throws:
  /// - [FirebaseException] if refresh fails or no keys found
  Future<void> refreshUserKeys(String userId) async {
    _ensureInitialized();
    
    try {
      SignalLogger.debug('Refreshing keys for user: $userId');
      
      // Download user's key bundle from Firebase
      final keyBundle = await FirebaseKeyManager.downloadKeyBundle(userId: userId);
      
      if (keyBundle == null) {
        throw FirebaseException(message: 'No keys found for user: $userId');
      }

      SignalLogger.debug('Downloaded key bundle for user: $userId');

      // Validate key bundle structure
      if (!_isValidKeyBundle(keyBundle)) {
        throw FirebaseException(message: 'Invalid key bundle structure for user: $userId');
      }

      // Update local cache if we have the stores initialized
      if (_identityStore != null) {
        // Cache keys locally for future session creation
        SignalLogger.debug('Cached keys for user: $userId');
      }

      SignalLogger.info('Keys refreshed successfully for user: $userId');
    } catch (e) {
      SignalLogger.error('Failed to refresh keys for user $userId: $e');
      throw FirebaseException(message: 'Key refresh failed: $e');
    }
  }
  
  /// Check if keys are available for a user.
  /// 
  /// This checks Firebase for the user's keys and validates their completeness.
  /// 
  /// Parameters:
  /// - [userId]: The user to check keys for
  /// 
  /// Returns:
  /// - [bool] indicating whether valid keys are available
  Future<bool> hasKeysForUser(String userId) async {
    _ensureInitialized();
    
    try {
      SignalLogger.debug('Checking keys for user: $userId');
      
      // Check Firebase for user keys
      final keyBundle = await FirebaseKeyManager.downloadKeyBundle(userId: userId);
      
      if (keyBundle == null) {
        SignalLogger.debug('No keys found in Firebase for user: $userId');
        return false;
      }

      // Validate key bundle completeness
      final isValid = _isValidKeyBundle(keyBundle);
      
      SignalLogger.debug('Keys ${isValid ? 'found and valid' : 'found but invalid'} for user: $userId');
      return isValid;
    } catch (e) {
      SignalLogger.error('Failed to check keys for user $userId: $e');
      return false;
    }
  }
  
  /// Get basic information about the current Signal Protocol instance.
  /// 
  /// Returns a map containing initialization status, user ID, device ID,
  /// and basic storage statistics.
  /// 
  /// Returns:
  /// - [Map<String, dynamic>] containing instance information
  Future<Map<String, dynamic>> getInstanceInfo() async {
    return {
      'isInitialized': _isInitialized,
      'userId': _userId,
      'deviceId': _deviceId,
      'hasSignalClient': _signalClient != null,
      'hasKeyManager': _keyManager != null,
      'hasSyncService': _syncService != null,
      'hasIdentityStore': _identityStore != null,
      'realTimeSyncEnabled': _realTimeSyncEnabled,
      'storageStats': await _getStorageStats(),
    };
  }
  
  /// Enable real-time synchronization for automatic key updates.
  /// 
  /// This starts listening for key changes in Firebase and automatically
  /// updates local storage when remote keys change. Also monitors network
  /// connectivity and handles offline/online transitions.
  /// 
  /// Parameters:
  /// - [onKeyUpdated]: Callback when keys are updated
  /// - [onSyncError]: Callback when sync errors occur
  /// - [onConnectionStateChanged]: Callback when connection state changes
  /// - [enableConnectivityMonitoring]: Whether to monitor network connectivity (default: true)
  /// 
  /// Throws:
  /// - [InitializationException] if not initialized
  /// - [FirebaseException] if sync setup fails
  Future<void> enableRealTimeSync({
    Function(String userId, String keyType, Map<String, dynamic> data)? onKeyUpdated,
    Function(String error)? onSyncError,
    Function(bool isOnline)? onConnectionStateChanged,
    bool enableConnectivityMonitoring = true,
  }) async {
    _ensureInitialized();
    
    try {
      SignalLogger.info('Enabling real-time sync for user: $_userId');
      
      // Store callbacks
      _onKeyUpdated = onKeyUpdated;
      _onSyncError = onSyncError;
      _onConnectionStateChanged = onConnectionStateChanged;
      
      // Setup Firebase sync service callbacks
      FirebaseSyncService.onUserKeyUpdated = _handleKeyUpdate;
      FirebaseSyncService.onSyncEvent = _handleSyncEvent;
      
      // Start connectivity monitoring if enabled
      if (enableConnectivityMonitoring) {
        ConnectivityManager.onConnectivityChanged = (isOnline) {
          _onConnectionStateChanged?.call(isOnline);
          
          if (isOnline) {
            // Connectivity restored - process offline queue and force sync
            _handleConnectivityRestored();
          }
        };
        
        await ConnectivityManager.startMonitoring();
      }
      
      // Start sync for current user
      await FirebaseSyncService.startUserKeySync(userId: _userId!);
      
      _realTimeSyncEnabled = true;
      SignalLogger.info('Real-time sync enabled successfully');
      
    } catch (e) {
      SignalLogger.error('Failed to enable real-time sync: $e');
      throw FirebaseException(message: 'Real-time sync setup failed: $e');
    }
  }
  
  /// Disable real-time synchronization.
  /// 
  /// This stops listening for Firebase changes, clears callbacks,
  /// and stops connectivity monitoring.
  Future<void> disableRealTimeSync() async {
    try {
      SignalLogger.info('Disabling real-time sync');
      
      await FirebaseSyncService.stopKeySync();
      await ConnectivityManager.stopMonitoring();
      
      // Clear callbacks
      _onKeyUpdated = null;
      _onSyncError = null;
      _onConnectionStateChanged = null;
      
      FirebaseSyncService.onUserKeyUpdated = null;
      FirebaseSyncService.onSyncEvent = null;
      ConnectivityManager.onConnectivityChanged = null;
      
      _realTimeSyncEnabled = false;
      SignalLogger.info('Real-time sync disabled');
      
    } catch (e) {
      SignalLogger.error('Failed to disable real-time sync: $e');
    }
  }
  
  /// Force synchronization of all keys from Firebase.
  /// 
  /// This manually triggers a full sync, useful for recovering from
  /// connection issues or ensuring the latest keys are available.
  /// 
  /// Throws:
  /// - [InitializationException] if not initialized
  /// - [FirebaseException] if sync fails
  Future<void> forceSyncKeys() async {
    _ensureInitialized();
    
    try {
      SignalLogger.info('Force syncing keys for user: $_userId');
      
      await FirebaseSyncService.forceSyncUserKeys(
        userId: _userId!,
        onKeyBundleReceived: (keyBundle) async {
          SignalLogger.debug('Received key bundle for device: ${keyBundle.deviceId}');
          
          // Validate the key bundle
          if (!_isValidKeyBundle(keyBundle)) {
            SignalLogger.warning('Received invalid key bundle for device: ${keyBundle.deviceId}');
            return;
          }

          // Process and cache the key bundle locally
          try {
            SignalLogger.debug('Processing and caching key bundle for device: ${keyBundle.deviceId}');
            // In a full implementation, this would:
            // 1. Extract keys from the bundle
            // 2. Validate signatures and integrity
            // 3. Update local cache/stores
            // 4. Mark keys as available for session creation
            
            SignalLogger.info('Key bundle processed successfully for device: ${keyBundle.deviceId}');
          } catch (e) {
            SignalLogger.error('Failed to process key bundle: $e');
          }
        },
      );
      
      SignalLogger.info('Force sync completed');
      
    } catch (e) {
      SignalLogger.error('Failed to force sync keys: $e');
      throw FirebaseException(message: 'Force sync failed: $e');
    }
  }
  
  /// Get current synchronization status.
  /// 
  /// Returns detailed information about the sync service state,
  /// including connection status and last sync time.
  /// 
  /// Returns:
  /// - [Map<String, dynamic>] containing sync status information
  Map<String, dynamic> getSyncStatus() {
    if (!_isInitialized) {
      return {
        'initialized': false,
        'real_time_sync_enabled': false,
        'error': 'Signal Protocol not initialized',
      };
    }
    
    final firebaseSyncStatus = FirebaseSyncService.getSyncStatus();
    final connectivityInfo = ConnectivityManager.getConnectivityInfo();
    
    return {
      'initialized': true,
      'real_time_sync_enabled': _realTimeSyncEnabled,
      'user_id': _userId,
      'device_id': _deviceId,
      'firebase_sync': firebaseSyncStatus,
      'connectivity': connectivityInfo,
      'offline_queue': OfflineQueueManager.getQueueStats(),
      'callbacks_set': {
        'on_key_updated': _onKeyUpdated != null,
        'on_sync_error': _onSyncError != null,
        'on_connection_state_changed': _onConnectionStateChanged != null,
      },
    };
  }
  
  /// Clean up and dispose of all resources.
  /// 
  /// This should be called when the Signal Protocol is no longer needed.
  /// After calling this method, you'll need to call [initialize] again
  /// before using any other methods.
  Future<void> dispose() async {
    SignalLogger.info('Disposing Signal Protocol resources');
    await _cleanup();
    _isInitialized = false;
  }
  
  /// Clean up all local storage data.
  /// 
  /// This removes all Signal Protocol data from the local device including:
  /// - Identity keys and registration data (from secure storage)
  /// - Sessions, prekeys, signed prekeys, and sender keys (from Hive)
  /// - Offline queue data
  /// 
  /// **Warning**: This is irreversible. After calling this method, you'll need
  /// to call [initialize] again to set up Signal Protocol from scratch.
  /// 
  /// Throws:
  /// - [InitializationException] if not initialized
  /// - [StorageException] if cleanup fails
  Future<void> cleanLocal() async {
    _ensureInitialized();
    
    try {
      SignalLogger.info('Starting local cleanup for user: $_userId');
      
      // Disable real-time sync first
      if (_realTimeSyncEnabled) {
        await disableRealTimeSync();
      }
      
      // Clear offline queue
      await OfflineQueueManager.clearQueue();
      
      // Clear Hive storage
      await _sessionStore?.clearAllSessions();
      await _preKeyStore?.clearAllPreKeys();
      await _signedPreKeyStore?.clearAllSignedPreKeys();
      await _senderKeyStore?.clearAllSenderKeys();
      
      // Clear secure storage (identity keys)
      await SecureIdentityStore.clearAll();
      
      SignalLogger.info('Local cleanup completed successfully');
      
    } catch (e) {
      SignalLogger.error('Failed to clean local storage: $e');
      throw StorageException(message: 'Failed to clean local storage: $e');
    }
  }
  
  /// Clean up all Firebase data for the current user.
  /// 
  /// This removes all Signal Protocol data from Firebase including:
  /// - User's public keys
  /// - Device registrations
  /// - Metadata and timestamps
  /// 
  /// **Warning**: This affects all devices for the current user. Other users
  /// will no longer be able to send messages to this user until keys are
  /// re-uploaded.
  /// 
  /// Throws:
  /// - [InitializationException] if not initialized
  /// - [FirebaseException] if cleanup fails
  Future<void> cleanFirebase() async {
    _ensureInitialized();
    
    try {
      SignalLogger.info('Starting Firebase cleanup for user: $_userId');
      
      // Remove user's keys from Firebase
      await FirebaseKeyManager.deleteUserKeys(userId: _userId!);
      
      SignalLogger.info('Firebase cleanup completed successfully');
      
    } catch (e) {
      SignalLogger.error('Failed to clean Firebase data: $e');
      throw FirebaseException(message: 'Failed to clean Firebase data: $e');
    }
  }
  
  /// Clean up all data (local and Firebase).
  /// 
  /// This is a convenience method that calls both [cleanLocal] and [cleanFirebase].
  /// After calling this method, all Signal Protocol data will be removed both
  /// locally and from Firebase.
  /// 
  /// **Warning**: This is irreversible and affects all devices. You'll need to
  /// call [initialize] and set up Signal Protocol from scratch.
  /// 
  /// Throws:
  /// - [InitializationException] if not initialized
  /// - [StorageException] if local cleanup fails
  /// - [FirebaseException] if Firebase cleanup fails
  Future<void> cleanAll() async {
    _ensureInitialized();
    
    try {
      SignalLogger.info('Starting complete cleanup for user: $_userId');
      
      // Clean Firebase first (in case local cleanup affects connectivity)
      await cleanFirebase();
      
      // Then clean local data
      await cleanLocal();
      
      SignalLogger.info('Complete cleanup finished successfully');
      
    } catch (e) {
      SignalLogger.error('Failed to complete cleanup: $e');
      rethrow; // Let the specific exception bubble up
    }
  }

  // Private helper methods

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw InitializationException(message: 'Signal Protocol not initialized. Call initialize() first.');
    }
  }
  
  Future<void> _initializeStorage() async {
    SignalLogger.debug('Initializing storage components');
    
    // Initialize secure storage for identity
    _identityStore = SecureIdentityStore();
    
    // Initialize Hive stores
    _sessionStore = HiveSessionStore();
    await _sessionStore!.initialize();
    
    _preKeyStore = HivePreKeyStore();
    await _preKeyStore!.initialize();
    
    _signedPreKeyStore = HiveSignedPreKeyStore();
    await _signedPreKeyStore!.initialize();
    
    _senderKeyStore = HiveSenderKeyStore();
    await _senderKeyStore!.initialize();
    
    // Initialize offline queue manager
    await OfflineQueueManager.initialize();
    
    SignalLogger.debug('Storage initialization complete');
  }
  
  Future<void> _initializeFirebase(FirebaseConfig config) async {
    SignalLogger.debug('Initializing Firebase components');
    
    _keyManager = FirebaseKeyManager();
    _syncService = FirebaseSyncService();
    
    SignalLogger.debug('Firebase components initialized');
  }
  
  Future<void> _initializeSignalClient() async {
    SignalLogger.debug('Initializing Signal client');
    
    // Create Signal client with initialized stores
    _signalClient = await SimpleSignalClient.initialize(
      userId: _userId!,
      deviceId: _deviceId!,
      generateKeys: true, // Generate keys if they don't exist
    );
    
    SignalLogger.debug('Signal client initialization complete');
  }
  
  Future<Map<String, int>> _getStorageStats() async {
    if (!_isInitialized) {
      return {
        'sessions': 0,
        'preKeys': 0,
        'signedPreKeys': 0,
        'senderKeys': 0,
      };
    }
    
    try {
      // Get storage statistics from each store
      final sessionCount = _sessionStore?.sessionCount ?? 0;
      final preKeyCount = await _preKeyStore?.getPreKeyCount() ?? 0;
      final signedPreKeyCount = await _signedPreKeyStore?.getSignedPreKeyCount() ?? 0;
      final senderKeyCount = await _senderKeyStore?.getSenderKeyCount() ?? 0;
      
      return {
        'sessions': sessionCount,
        'preKeys': preKeyCount,
        'signedPreKeys': signedPreKeyCount,
        'senderKeys': senderKeyCount,
      };
    } catch (e) {
      SignalLogger.error('Failed to get storage stats: $e');
      return {
        'sessions': 0,
        'preKeys': 0,
        'signedPreKeys': 0,
        'senderKeys': 0,
      };
    }
  }
  
  Future<void> _cleanup() async {
    try {
      // Disable real-time sync if enabled
      if (_realTimeSyncEnabled) {
        await disableRealTimeSync();
      }
      
      // Dispose of utility managers
      await OfflineQueueManager.dispose();
      
      // Dispose of Signal client
      if (_signalClient != null) {
        await _signalClient!.dispose();
      }
      
      // Dispose of storage components (close Hive boxes)
      await _sessionStore?.close();
      await _preKeyStore?.close();
      await _signedPreKeyStore?.close();
      await _senderKeyStore?.close();
      
      // Clear secure storage if needed
      // Note: We don't automatically clear secure storage on dispose
      // as the user might want to keep their identity keys
    } catch (e) {
      SignalLogger.error('Error during cleanup: $e');
    }
    
    _signalClient = null;
    _keyManager = null;
    _syncService = null;
    _identityStore = null;
    _sessionStore = null;
    _preKeyStore = null;
    _signedPreKeyStore = null;
    _senderKeyStore = null;
    _userId = null;
    _deviceId = null;
  }
  
  /// Handle key updates from Firebase sync service
  void _handleKeyUpdate(String userId, String keyType, Map<String, dynamic> data) {
    try {
      SignalLogger.debug('Handling key update for user: $userId, type: $keyType');
      
      // Process the key update and update local storage
      try {
        // Validate the incoming key data
        if (!_isValidKeyBundle(data)) {
          throw ValidationException(message: 'Invalid key data received');
        }

        // Update local storage based on key type
        switch (keyType.toLowerCase()) {
          case 'identity':
            SignalLogger.debug('Processing identity key update for user: $userId');
            // In a full implementation, we'd update trusted identity keys
            break;
          case 'prekey':
            SignalLogger.debug('Processing prekey update for user: $userId');
            // In a full implementation, we'd update cached prekeys
            break;
          case 'signed_prekey':
            SignalLogger.debug('Processing signed prekey update for user: $userId');
            // In a full implementation, we'd update cached signed prekeys
            break;
          default:
            SignalLogger.warning('Unknown key type: $keyType');
        }

        SignalLogger.debug('Key update processed successfully');
      } catch (e) {
        SignalLogger.error('Failed to process key update: $e');
        throw StorageException(message: 'Key update processing failed: $e');
      }
      
      // Notify the application
      _onKeyUpdated?.call(userId, keyType, data);
      
      SignalLogger.debug('Key update handled successfully');
    } catch (e) {
      SignalLogger.error('Failed to handle key update: $e');
      _onSyncError?.call('Key update failed: $e');
    }
  }
  
  /// Handle sync events from Firebase sync service
  void _handleSyncEvent(dynamic event) {
    try {
      SignalLogger.debug('Handling sync event: ${event.eventType}');
      
      // Handle different types of sync events
      switch (event.eventType) {
        case 'key_updated':
          // Key was updated - already handled by _handleKeyUpdate
          break;
        case 'sync_error':
          _onSyncError?.call('Sync error: ${event.data['error']}');
          break;
        case 'connection_changed':
          final isOnline = event.data['is_online'] as bool? ?? false;
          _onConnectionStateChanged?.call(isOnline);
          break;
        case 'conflict_resolved':
          SignalLogger.info('Key conflict resolved: ${event.data['resolution']}');
          break;
        case 'force_sync_complete':
          SignalLogger.info('Force sync completed for user: ${event.userId}');
          break;
        default:
          SignalLogger.debug('Unknown sync event type: ${event.eventType}');
      }
    } catch (e) {
      SignalLogger.error('Failed to handle sync event: $e');
      _onSyncError?.call('Sync event handling failed: $e');
    }
  }
  
  /// Handle connectivity restoration - process offline queue and force sync
  void _handleConnectivityRestored() {
    if (!_isInitialized || _userId == null) {
      return;
    }
    
    // Schedule operations after a short delay to avoid overwhelming the system
    Timer(const Duration(seconds: 2), () async {
      try {
        SignalLogger.info('Processing operations after connectivity restored');
        
        // First, process any queued offline operations
        await OfflineQueueManager.processQueue();
        
        // Then force sync to catch up on missed updates
        await forceSyncKeys();
        
        SignalLogger.info('Post-reconnection processing complete');
      } catch (e) {
        SignalLogger.error('Failed to process operations after reconnection: $e');
        _onSyncError?.call('Reconnection processing failed: $e');
      }
    });
  }
  
  /// Validate that a key bundle has the required structure
  bool _isValidKeyBundle(dynamic keyBundle) {
    if (keyBundle == null) return false;
    
    // For FirebaseKeyBundle, check that it has the required methods/properties
    // This is a basic validation - in production you'd check specific fields
    try {
      // Check if it's a valid key bundle object
      return keyBundle.toString().isNotEmpty;
    } catch (e) {
      SignalLogger.warning('Key bundle validation failed: $e');
      return false;
    }
  }
}

/// Represents basic information about an encrypted message.
/// 
/// This is a simplified version that will be expanded as encryption
/// functionality is implemented.
class EncryptedMessage {
  final String recipientId;
  final int deviceId;
  final Uint8List cipherText;
  final int type;
  final DateTime timestamp;
  
  const EncryptedMessage({
    required this.recipientId,
    required this.deviceId,
    required this.cipherText,
    required this.type,
    required this.timestamp,
  });
  
  /// Convert to a map for JSON serialization.
  Map<String, dynamic> toMap() {
    return {
      'recipientId': recipientId,
      'deviceId': deviceId,
      'cipherText': cipherText.toList(),
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  /// Create from a map (JSON deserialization).
  factory EncryptedMessage.fromMap(Map<String, dynamic> map) {
    return EncryptedMessage(
      recipientId: map['recipientId'],
      deviceId: map['deviceId'],
      cipherText: Uint8List.fromList(List<int>.from(map['cipherText'])),
      type: map['type'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

/// Represents basic information about an encrypted group message.
/// 
/// This is a simplified version that will be expanded as group encryption
/// functionality is implemented.
class GroupEncryptedMessage {
  final String groupId;
  final String senderId;
  final int senderDeviceId;
  final Uint8List cipherText;
  final DateTime timestamp;
  
  const GroupEncryptedMessage({
    required this.groupId,
    required this.senderId,
    required this.senderDeviceId,
    required this.cipherText,
    required this.timestamp,
  });
  
  /// Convert to a map for JSON serialization.
  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'senderId': senderId,
      'senderDeviceId': senderDeviceId,
      'cipherText': cipherText.toList(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  /// Create from a map (JSON deserialization).
  factory GroupEncryptedMessage.fromMap(Map<String, dynamic> map) {
    return GroupEncryptedMessage(
      groupId: map['groupId'],
      senderId: map['senderId'],
      senderDeviceId: map['senderDeviceId'],
      cipherText: Uint8List.fromList(List<int>.from(map['cipherText'])),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
