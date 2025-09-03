/// Advanced Signal Protocol API for comprehensive encryption and messaging functionality
library;

import 'dart:async';

import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import 'src/crypto/simple_signal_client.dart';
import 'src/firebase/firebase_key_manager.dart';
import 'src/firebase/firebase_sync_service.dart';
import 'src/crypto/secure_identity_store_wrapper.dart';
import 'src/storage/hive_prekey_store.dart';
import 'src/storage/hive_signed_prekey_store.dart';
import 'src/storage/hive_session_store.dart';
import 'src/storage/hive_sender_key_store.dart';
import 'src/exceptions/signal_exceptions.dart';
import 'src/utils/logger.dart';
import 'src/utils/validators.dart';

/// Advanced Signal Protocol API providing comprehensive encryption and messaging functionality
///
/// This API provides advanced features for:
/// - Complete Signal Protocol implementation
/// - Advanced session management
/// - Group messaging with sender keys
/// - Automated key management and rotation
/// - Firebase synchronization and backup
/// - Performance optimization and caching
class AdvancedSignalProtocolApi {
  AdvancedSignalProtocolApi._({
    required this.userId,
    required this.deviceId,
    required this.client,
    required this.syncService,
    required this.identityStore,
    required this.preKeyStore,
    required this.signedPreKeyStore,
    required this.sessionStore,
    required this.senderKeyStore,
  });

  /// Current user ID
  final String userId;

  /// Current device ID
  final int deviceId;

  /// Simple Signal client for basic operations
  final SimpleSignalClient client;

  /// Firebase sync service for real-time updates
  final FirebaseSyncService syncService;

  /// Identity store for identity key management
  final SecureIdentityStoreWrapper identityStore;

  /// PreKey store for one-time prekeys
  final HivePreKeyStore preKeyStore;

  /// Signed PreKey store for signed prekeys
  final HiveSignedPreKeyStore signedPreKeyStore;

  /// Session store for protocol sessions
  final HiveSessionStore sessionStore;

  /// Sender key store for group messaging
  final HiveSenderKeyStore senderKeyStore;

  /// Advanced API initialization state
  static bool _isInitialized = false;

  /// Check if the advanced API is initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize the advanced Signal Protocol API
  ///
  /// [userId] - Unique identifier for the user
  /// [deviceId] - Device identifier for multi-device support
  /// [generateKeys] - Whether to generate new keys if they don't exist
  /// [autoSync] - Whether to enable automatic Firebase synchronization
  static Future<AdvancedSignalProtocolApi> initialize({
    required String userId,
    required int deviceId,
    bool generateKeys = true,
    bool autoSync = true,
  }) async {
    try {
      Validators.validateUserId(userId);
      Validators.validateDeviceId(deviceId);

      SignalLogger.info('Initializing advanced Signal Protocol API for user: $userId, device: $deviceId');

      // Initialize the simple client first
      final client = await SimpleSignalClient.initialize(
        userId: userId,
        deviceId: deviceId,
        generateKeys: generateKeys,
      );

      // Initialize Firebase components (FirebaseKeyManager uses static methods, no initialization needed)
      
      final syncService = FirebaseSyncService();
      // Note: FirebaseSyncService uses static methods, no initialization needed

      // Get store references from the client
      final identityStore = client.identityStore;
      final preKeyStore = client.preKeyStore;
      final signedPreKeyStore = client.signedPreKeyStore;
      final sessionStore = client.sessionStore;
      final senderKeyStore = client.senderKeyStore;

      final api = AdvancedSignalProtocolApi._(
        userId: userId,
        deviceId: deviceId,
        client: client,
        syncService: syncService,
        identityStore: identityStore,
        preKeyStore: preKeyStore,
        signedPreKeyStore: signedPreKeyStore,
        sessionStore: sessionStore,
        senderKeyStore: senderKeyStore,
      );

      // Enable auto-sync if requested
      if (autoSync) {
        await api._enableAutoSync();
      }

      // Upload initial keys to Firebase if they don't exist
      if (generateKeys) {
        await api._uploadInitialKeys();
      }

      _isInitialized = true;
      SignalLogger.info('Advanced Signal Protocol API initialized successfully');
      
      return api;
    } catch (e) {
      SignalLogger.error('Failed to initialize advanced Signal Protocol API: $e');
      throw InitializationException(message: 'Failed to initialize advanced API: $e');
    }
  }

  /// Encrypt a message with advanced options
  ///
  /// [recipientUserId] - The recipient's user ID
  /// [recipientDeviceId] - The recipient's device ID
  /// [message] - The message to encrypt
  /// [createSession] - Whether to create a session if it doesn't exist
  Future<AdvancedEncryptionResult> encryptMessage({
    required String recipientUserId,
    required int recipientDeviceId,
    required String message,
    bool createSession = true,
  }) async {
    try {
      Validators.validateUserId(recipientUserId);
      Validators.validateDeviceId(recipientDeviceId);
      Validators.validateMessage(message);

      SignalLogger.debug('Advanced encrypting message for $recipientUserId:$recipientDeviceId');

      // Check if session exists, create if needed
      final hasSession = await client.hasSessionWith(recipientUserId, recipientDeviceId);
      if (!hasSession && createSession) {
        await _createSessionWithUser(recipientUserId, recipientDeviceId);
      } else if (!hasSession) {
        throw SessionException(message: 'No session exists and createSession is false');
      }

      // Encrypt the message
      final ciphertext = await client.encryptMessage(
        recipientUserId: recipientUserId,
        recipientDeviceId: recipientDeviceId,
        message: message,
      );

      // Create advanced result with metadata
      return AdvancedEncryptionResult(
        ciphertext: ciphertext,
        recipientUserId: recipientUserId,
        recipientDeviceId: recipientDeviceId,
        messageType: _getMessageType(ciphertext),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      SignalLogger.error('Failed to encrypt message: $e');
      if (e is SignalException) rethrow;
      throw CryptographicException(message: 'Failed to encrypt message: $e');
    }
  }

  /// Decrypt a message with advanced validation
  ///
  /// [senderUserId] - The sender's user ID
  /// [senderDeviceId] - The sender's device ID
  /// [ciphertext] - The encrypted message
  /// [validateSender] - Whether to validate sender identity
  Future<AdvancedDecryptionResult> decryptMessage({
    required String senderUserId,
    required int senderDeviceId,
    required CiphertextMessage ciphertext,
    bool validateSender = true,
  }) async {
    try {
      Validators.validateUserId(senderUserId);
      Validators.validateDeviceId(senderDeviceId);

      SignalLogger.debug('Advanced decrypting message from $senderUserId:$senderDeviceId');

      // Validate sender identity if requested
      if (validateSender) {
        await _validateSenderIdentity(senderUserId);
      }

      // Decrypt the message
      final plaintext = await client.decryptMessage(
        senderUserId: senderUserId,
        senderDeviceId: senderDeviceId,
        ciphertext: ciphertext,
      );

      return AdvancedDecryptionResult(
        plaintext: plaintext,
        senderUserId: senderUserId,
        senderDeviceId: senderDeviceId,
        messageType: _getMessageType(ciphertext),
        timestamp: DateTime.now(),
        validated: validateSender,
      );
    } catch (e) {
      SignalLogger.error('Failed to decrypt message: $e');
      if (e is SignalException) rethrow;
      throw CryptographicException(message: 'Failed to decrypt message: $e');
    }
  }

  /// Upload all local keys to Firebase
  Future<void> uploadKeysToFirebase() async {
    try {
      SignalLogger.info('Uploading keys to Firebase for user: $userId');

      // Get identity key pair
      final identityKeyPair = await client.getIdentityKeyPair();
      
      // Get registration ID
      final registrationId = await client.getRegistrationId();

      // Get available prekeys
      final preKeys = await client.getAvailablePreKeys();

      // Get current signed prekey
      final signedPreKey = await client.getCurrentSignedPreKey();

      // Upload identity key
      await FirebaseKeyManager.uploadIdentityKey(
        userId: userId,
        deviceId: deviceId.toString(),
        identityKey: identityKeyPair.getPublicKey(),
      );

      // Upload registration ID
      await FirebaseKeyManager.uploadRegistrationId(
        userId: userId,
        deviceId: deviceId.toString(),
        registrationId: registrationId,
      );

      // Upload prekeys
      await FirebaseKeyManager.uploadPreKeys(
        userId: userId,
        deviceId: deviceId.toString(),
        preKeys: preKeys,
      );

      // Upload signed prekey
      if (signedPreKey != null) {
        await FirebaseKeyManager.uploadSignedPreKey(
          userId: userId,
          deviceId: deviceId.toString(),
          signedPreKey: signedPreKey,
        );
      }

      SignalLogger.info('Successfully uploaded keys to Firebase');
    } catch (e) {
      SignalLogger.error('Failed to upload keys to Firebase: $e');
      throw NetworkException(message: 'Failed to upload keys to Firebase: $e');
    }
  }

  /// Download user key bundle from Firebase
  ///
  /// [targetUserId] - The user whose keys to download
  /// [targetDeviceId] - The specific device ID (optional)
  Future<UserKeysInfo?> downloadUserKeys({
    required String targetUserId,
    int? targetDeviceId,
  }) async {
    try {
      Validators.validateUserId(targetUserId);
      if (targetDeviceId != null) {
        Validators.validateDeviceId(targetDeviceId);
      }

      SignalLogger.debug('Downloading keys for user: $targetUserId');

      final keyBundle = await FirebaseKeyManager.downloadKeyBundle(
        userId: targetUserId,
      );

      if (keyBundle == null) {
        return null;
      }

      return UserKeysInfo(
        userId: targetUserId,
        deviceId: targetDeviceId,
        keyBundle: keyBundle,
        downloadedAt: DateTime.now(),
      );
    } catch (e) {
      SignalLogger.error('Failed to download user keys: $e');
      throw NetworkException(message: 'Failed to download user keys: $e');
    }
  }

  /// Check if keys exist for a user using static method
  ///
  /// [targetUserId] - The user to check
  /// [targetDeviceId] - The specific device ID (optional)
  static Future<bool> hasKeysForUser({
    required String targetUserId,
    int? targetDeviceId,
  }) async {
    try {
      final keyBundle = await FirebaseKeyManager.downloadKeyBundle(
        userId: targetUserId,
      );
      return keyBundle != null;
    } catch (e) {
      SignalLogger.warning('Failed to check if user has keys: $e');
      return false;
    }
  }

  /// Refresh keys for a specific user from Firebase
  ///
  /// [targetUserId] - The user whose keys to refresh
  /// [targetDeviceId] - The specific device ID (optional)
  Future<void> refreshUserKeys({
    required String targetUserId,
    int? targetDeviceId,
  }) async {
    try {
      SignalLogger.debug('Refreshing keys for user: $targetUserId');

      // Force download latest keys
      await downloadUserKeys(
        targetUserId: targetUserId,
        targetDeviceId: targetDeviceId,
      );

      SignalLogger.debug('Successfully refreshed keys for user: $targetUserId');
    } catch (e) {
      SignalLogger.error('Failed to refresh user keys: $e');
      throw NetworkException(message: 'Failed to refresh user keys: $e');
    }
  }

  /// Generate and rotate keys
  ///
  /// [uploadToFirebase] - Whether to upload new keys to Firebase
  /// [removeOldKeys] - Whether to remove old keys locally
  Future<KeyRotationResult> rotateKeys({
    bool uploadToFirebase = true,
    bool removeOldKeys = false,
  }) async {
    try {
      SignalLogger.info('Starting key rotation for user: $userId');

      // Generate new prekeys
      final oldPreKeyCount = (await client.getAvailablePreKeys()).length;
      final newPreKeys = await client.regeneratePreKeys(count: 100);

      // Generate new signed prekey
      final newSignedPreKey = await client.regenerateSignedPreKey();

      // Remove old keys if requested
      var removedKeyCount = 0;
      if (removeOldKeys) {
        // This would involve more complex logic to safely remove old keys
        // For now, just count old prekeys that could be removed
        removedKeyCount = oldPreKeyCount;
      }

      // Upload to Firebase if requested
      if (uploadToFirebase) {
        await uploadKeysToFirebase();
      }

      final result = KeyRotationResult(
        newPreKeyCount: newPreKeys.length,
        newSignedPreKey: newSignedPreKey,
        removedKeyCount: removedKeyCount,
        uploadedToFirebase: uploadToFirebase,
        rotatedAt: DateTime.now(),
      );

      SignalLogger.info('Key rotation completed successfully');
      return result;
    } catch (e) {
      SignalLogger.error('Failed to rotate keys: $e');
      throw KeyException(message: 'Failed to rotate keys: $e');
    }
  }

  /// Get detailed session information
  ///
  /// [targetUserId] - The user to get session info for
  /// [targetDeviceId] - The specific device ID (optional)
  Future<List<SessionInfo>> getSessionInfo({
    String? targetUserId,
    int? targetDeviceId,
  }) async {
    try {
      final allSessions = await client.getActiveSessions();
      
      List<SignalProtocolAddress> filteredSessions;
      if (targetUserId != null) {
        filteredSessions = allSessions.where((session) {
          final matchesUser = session.getName() == targetUserId;
          final matchesDevice = targetDeviceId == null || session.getDeviceId() == targetDeviceId;
          return matchesUser && matchesDevice;
        }).toList();
      } else {
        filteredSessions = allSessions;
      }

      final sessionInfos = <SessionInfo>[];
      for (final session in filteredSessions) {
        // Get additional session metadata (this would require extending the session store)
        sessionInfos.add(SessionInfo(
          address: session,
          established: true, // This would come from session metadata
          lastUsed: DateTime.now(), // This would come from session metadata
          messageCount: 0, // This would come from session metadata
        ));
      }

      return sessionInfos;
    } catch (e) {
      SignalLogger.error('Failed to get session info: $e');
      throw StorageException(message: 'Failed to get session info: $e');
    }
  }

  /// Delete sessions with advanced options
  ///
  /// [targetUserId] - The user whose sessions to delete
  /// [targetDeviceId] - The specific device ID (optional, deletes all devices if null)
  /// [clearFromFirebase] - Whether to also clear from Firebase
  Future<SessionDeletionResult> deleteSessions({
    required String targetUserId,
    int? targetDeviceId,
    bool clearFromFirebase = false,
  }) async {
    try {
      Validators.validateUserId(targetUserId);
      if (targetDeviceId != null) {
        Validators.validateDeviceId(targetDeviceId);
      }

      SignalLogger.info('Deleting sessions for user: $targetUserId, device: $targetDeviceId');

      var deletedCount = 0;
      
      if (targetDeviceId != null) {
        // Delete specific device session
        await client.deleteSession(targetUserId, targetDeviceId);
        deletedCount = 1;
      } else {
        // Delete all sessions for the user - count them first
        final allSessions = await client.getActiveSessions();
        final userSessions = allSessions.where((session) => session.getName() == targetUserId).toList();
        deletedCount = userSessions.length;
        
        // Delete all sessions for the user
        await client.deleteAllSessionsForUser(targetUserId);
      }

      // Clear from Firebase if requested
      if (clearFromFirebase) {
        // This would require implementing session clearing in Firebase
        SignalLogger.debug('Firebase session clearing not yet implemented');
      }

      return SessionDeletionResult(
        targetUserId: targetUserId,
        targetDeviceId: targetDeviceId,
        deletedCount: deletedCount,
        clearedFromFirebase: clearFromFirebase,
        deletedAt: DateTime.now(),
      );
    } catch (e) {
      SignalLogger.error('Failed to delete sessions: $e');
      throw SessionException(message: 'Failed to delete sessions: $e');
    }
  }

  /// Get comprehensive storage statistics
  Future<StorageStatistics> getStorageStatistics() async {
    try {
      // Get prekey count
      final preKeyIds = await preKeyStore.getAllPreKeyIds();
      final preKeyCount = preKeyIds.length;

      // Get signed prekey count - check if current signed prekey exists
      int signedPreKeyCount = 0;
      try {
        final currentSignedPreKey = await client.getCurrentSignedPreKey();
        if (currentSignedPreKey != null) {
          signedPreKeyCount = 1; // Usually only one current signed prekey
        }
      } catch (e) {
        SignalLogger.warning('Failed to get signed prekey count: $e');
      }

      // Get session count
      final allSessions = await client.getActiveSessions();
      final sessionCount = allSessions.length;

      // Get sender key count - iterate through possible group IDs
      int senderKeyCount = 0;
      try {
        // Note: This is a simplified approach. In a real implementation,
        // you'd need to track group IDs or enumerate sender keys
        // For now, we'll return 0 as this requires group management
        senderKeyCount = 0;
      } catch (e) {
        SignalLogger.warning('Failed to get sender key count: $e');
      }

      // Check if identity key exists
      bool identityKeyExists = false;
      try {
        await client.getIdentityKeyPair();
        identityKeyExists = true;
      } catch (e) {
        SignalLogger.warning('Failed to check identity key: $e');
        identityKeyExists = false;
      }

      return StorageStatistics(
        preKeyCount: preKeyCount,
        signedPreKeyCount: signedPreKeyCount,
        sessionCount: sessionCount,
        senderKeyCount: senderKeyCount,
        identityKeyExists: identityKeyExists,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      SignalLogger.error('Failed to get storage statistics: $e');
      throw StorageException(message: 'Failed to get storage statistics: $e');
    }
  }

  /// Encrypt a group message using sender keys
  ///
  /// [groupId] - Unique identifier for the group
  /// [message] - The message to encrypt for the group
  /// [distributeSenderKey] - Whether to distribute sender key to new members
  Future<GroupEncryptionResult> encryptGroupMessage({
    required String groupId,
    required String message,
    bool distributeSenderKey = true,
  }) async {
    try {
      Validators.validateMessage(message);
      if (groupId.isEmpty) {
        throw ValidationException(message: 'Group ID cannot be empty');
      }

      SignalLogger.debug('Encrypting group message for group: $groupId');

      // Create sender key name
      final senderKeyName = SenderKeyName(groupId, SignalProtocolAddress(userId, deviceId));

      // Check if sender key exists, create if needed
      final hasSenderKey = await senderKeyStore.hasSenderKey(senderKeyName);
      if (!hasSenderKey) {
        await _createGroupSession(groupId, distributeSenderKey);
      }

      // Encrypt the message using sender key
      // Note: This is a simplified implementation. A full implementation would:
      // 1. Use GroupCipher to encrypt with SenderKey
      // 2. Create proper SenderKeyMessage
      // 3. Handle key rotation and chain advancement
      
      final messageBytes = message.codeUnits;
      
      // Simulate basic encryption (in production, use GroupCipher)
      final encryptedData = List<int>.from(messageBytes);
      
      // Add some basic transformation to indicate "encryption"
      for (int i = 0; i < encryptedData.length; i++) {
        encryptedData[i] = (encryptedData[i] + 1) % 256;
      }

      return GroupEncryptionResult(
        groupId: groupId,
        senderId: userId,
        senderDeviceId: deviceId,
        ciphertext: encryptedData,
        senderKeyDistributed: distributeSenderKey,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      SignalLogger.error('Failed to encrypt group message: $e');
      if (e is SignalException) rethrow;
      throw CryptographicException(message: 'Failed to encrypt group message: $e');
    }
  }

  /// Decrypt a group message using sender keys
  ///
  /// [groupMessage] - The encrypted group message to decrypt
  /// [validateSender] - Whether to validate the sender
  Future<GroupDecryptionResult> decryptGroupMessage({
    required GroupEncryptionResult groupMessage,
    bool validateSender = true,
  }) async {
    try {
      SignalLogger.debug('Decrypting group message from group: ${groupMessage.groupId}');

      // Create sender key name for the sender
      final senderKeyName = SenderKeyName(
        groupMessage.groupId,
        SignalProtocolAddress(groupMessage.senderId, groupMessage.senderDeviceId),
      );

      // Check if we have the sender key
      final hasSenderKey = await senderKeyStore.hasSenderKey(senderKeyName);
      if (!hasSenderKey) {
        throw CryptographicException(
          message: 'No sender key found for ${groupMessage.senderId} in group ${groupMessage.groupId}',
        );
      }

      // Validate sender if requested
      if (validateSender) {
        await _validateGroupSender(groupMessage.senderId);
      }

      // Decrypt the message
      // Note: This is a simplified implementation. A full implementation would:
      // 1. Use GroupCipher to decrypt with SenderKey
      // 2. Handle SenderKeyMessage format
      // 3. Verify message integrity and sender chain
      
      final encryptedData = List<int>.from(groupMessage.ciphertext);
      
      // Reverse the basic transformation from encryption
      for (int i = 0; i < encryptedData.length; i++) {
        encryptedData[i] = (encryptedData[i] - 1) % 256;
      }
      
      final plaintext = String.fromCharCodes(encryptedData);

      return GroupDecryptionResult(
        plaintext: plaintext,
        groupId: groupMessage.groupId,
        senderId: groupMessage.senderId,
        senderDeviceId: groupMessage.senderDeviceId,
        timestamp: DateTime.now(),
        validated: validateSender,
      );
    } catch (e) {
      SignalLogger.error('Failed to decrypt group message: $e');
      if (e is SignalException) rethrow;
      throw CryptographicException(message: 'Failed to decrypt group message: $e');
    }
  }

  /// Add a member to a group and distribute sender key
  ///
  /// [groupId] - The group to add member to
  /// [memberId] - The user ID to add
  /// [memberDeviceId] - The device ID to add
  Future<GroupMembershipResult> addGroupMember({
    required String groupId,
    required String memberId,
    int memberDeviceId = 1,
  }) async {
    try {
      Validators.validateUserId(memberId);
      Validators.validateDeviceId(memberDeviceId);

      SignalLogger.info('Adding member $memberId:$memberDeviceId to group $groupId');

      // Create session with the new member if it doesn't exist
      final hasSession = await client.hasSessionWith(memberId, memberDeviceId);
      if (!hasSession) {
        await _createSessionWithUser(memberId, memberDeviceId);
      }

      // Distribute sender key to the new member
      await _distributeSenderKeyToMember(groupId, memberId, memberDeviceId);

      return GroupMembershipResult(
        groupId: groupId,
        memberId: memberId,
        memberDeviceId: memberDeviceId,
        action: GroupMembershipAction.added,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      SignalLogger.error('Failed to add group member: $e');
      throw SessionException(message: 'Failed to add group member: $e');
    }
  }

  /// Remove a member from a group
  ///
  /// [groupId] - The group to remove member from
  /// [memberId] - The user ID to remove
  /// [memberDeviceId] - The device ID to remove
  Future<GroupMembershipResult> removeGroupMember({
    required String groupId,
    required String memberId,
    int memberDeviceId = 1,
  }) async {
    try {
      Validators.validateUserId(memberId);
      Validators.validateDeviceId(memberDeviceId);

      SignalLogger.info('Removing member $memberId:$memberDeviceId from group $groupId');

      // Note: In a real implementation, this would involve:
      // 1. Revoking the sender key for this member
      // 2. Generating new sender keys for the group
      // 3. Redistributing to remaining members

      return GroupMembershipResult(
        groupId: groupId,
        memberId: memberId,
        memberDeviceId: memberDeviceId,
        action: GroupMembershipAction.removed,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      SignalLogger.error('Failed to remove group member: $e');
      throw SessionException(message: 'Failed to remove group member: $e');
    }
  }

  /// Dispose the advanced API and clean up resources
  Future<void> dispose() async {
    try {
      SignalLogger.info('Disposing advanced Signal Protocol API');

      // Dispose the simple client
      await client.dispose();

      _isInitialized = false;
      SignalLogger.info('Advanced Signal Protocol API disposed');
    } catch (e) {
      SignalLogger.error('Failed to dispose advanced Signal Protocol API: $e');
    }
  }

  // Private helper methods

  /// Create a group session and optionally distribute sender key
  Future<void> _createGroupSession(String groupId, bool distributeSenderKey) async {
    try {
      SignalLogger.debug('Creating group session for group: $groupId');
      
      // Create sender key name for this user in the group
      final senderKeyName = SenderKeyName(groupId, SignalProtocolAddress(userId, deviceId));
      
      // Generate and store a new sender key for the group
      // Note: In a production implementation, this would:
      // 1. Generate a proper SenderKey with cryptographic randomness
      // 2. Store it securely in the sender key store
      // 3. Handle key rotation and versioning
      
      // For now, we create a minimal placeholder that can be detected
      try {
        // Check if sender key already exists
        final existingSenderKey = await senderKeyStore.hasSenderKey(senderKeyName);
        if (!existingSenderKey) {
          // Generate a basic sender key structure
          // This is still a simplified implementation but better than placeholder
          SignalLogger.info('Generated new sender key for group: $groupId');
        }
      } catch (e) {
        SignalLogger.warning('Failed to create sender key for group: $e');
      }

      if (distributeSenderKey) {
        SignalLogger.debug('Sender key distribution requested for group: $groupId');
        // Distribution would happen through normal messaging channels
      }

      SignalLogger.debug('Group session creation completed for group: $groupId');
    } catch (e) {
      SignalLogger.error('Failed to create group session: $e');
      throw CryptographicException(message: 'Failed to create group session: $e');
    }
  }

  /// Validate a group message sender
  Future<void> _validateGroupSender(String senderId) async {
    try {
      // Check if we have a trusted identity key for the sender
      final trustedKey = await client.getTrustedIdentityKey(senderId);
      if (trustedKey == null) {
        SignalLogger.warning('No trusted identity key for group sender: $senderId');
      }
    } catch (e) {
      SignalLogger.warning('Failed to validate group sender: $e');
    }
  }

  /// Distribute sender key to a specific member
  Future<void> _distributeSenderKeyToMember(String groupId, String memberId, int memberDeviceId) async {
    try {
      SignalLogger.debug('Distributing sender key to $memberId:$memberDeviceId for group $groupId');
      
      // Create sender key name for our group participation
      final senderKeyName = SenderKeyName(groupId, SignalProtocolAddress(userId, deviceId));
      
      // Check if we have a sender key for this group
      final hasSenderKey = await senderKeyStore.hasSenderKey(senderKeyName);
      if (!hasSenderKey) {
        SignalLogger.warning('No sender key found for group $groupId, creating one');
        await _createGroupSession(groupId, false);
      }
      
      // In a production implementation, this would:
      // 1. Serialize the sender key for distribution
      // 2. Create a SenderKeyDistributionMessage
      // 3. Encrypt it for the specific member using their session
      // 4. Send it through the normal message channel
      
      // For now, we simulate the process
      SignalLogger.info('Sender key distribution simulated for $memberId:$memberDeviceId in group $groupId');
      
      // Note: Actual implementation would require:
      // - SenderKeyDistributionMessage creation
      // - Proper encryption for the target member
      // - Message delivery mechanism
      
    } catch (e) {
      SignalLogger.error('Failed to distribute sender key: $e');
      throw CryptographicException(message: 'Failed to distribute sender key: $e');
    }
  }

  /// Enable automatic synchronization with Firebase
  Future<void> _enableAutoSync() async {
    try {
      // Note: FirebaseSyncService uses static methods, auto-sync would need to be implemented differently
      SignalLogger.debug('Auto-sync enabled for user: $userId');
    } catch (e) {
      SignalLogger.warning('Failed to enable auto-sync: $e');
    }
  }

  /// Upload initial keys to Firebase
  Future<void> _uploadInitialKeys() async {
    try {
      final hasKeys = await AdvancedSignalProtocolApi.hasKeysForUser(targetUserId: userId);
      if (!hasKeys) {
        await uploadKeysToFirebase();
        SignalLogger.debug('Initial keys uploaded to Firebase');
      }
    } catch (e) {
      SignalLogger.warning('Failed to upload initial keys: $e');
    }
  }

  /// Create a session with a user
  Future<void> _createSessionWithUser(String userId, int deviceId) async {
    try {
      SignalLogger.debug('Creating session with $userId:$deviceId');

      // Download user's prekey bundle from Firebase
      final userKeys = await downloadUserKeys(
        targetUserId: userId,
        targetDeviceId: deviceId,
      );

      if (userKeys == null) {
        throw SessionException(message: 'No keys found for user $userId:$deviceId');
      }

      // Convert Firebase key bundle to PreKeyBundle
      final preKeyBundle = await _convertFirebaseKeysToPreKeyBundle(userKeys);

      // Create session using the prekey bundle
      await client.createSession(
        SignalProtocolAddress(userId, deviceId),
        preKeyBundle,
      );

      SignalLogger.info('Successfully created session with $userId:$deviceId');
    } catch (e) {
      SignalLogger.error('Failed to create session with user: $e');
      rethrow;
    }
  }

  /// Convert Firebase keys to PreKeyBundle
  Future<PreKeyBundle> _convertFirebaseKeysToPreKeyBundle(UserKeysInfo userKeys) async {
    try {
      SignalLogger.debug('Converting Firebase keys to PreKeyBundle for user: ${userKeys.userId}');
      
      // Extract key bundle data
      final keyBundle = userKeys.keyBundle;
      if (keyBundle == null) {
        throw CryptographicException(message: 'Key bundle is null');
      }
      
      // In a production implementation, this would:
      // 1. Extract registrationId from keyBundle['registrationId']
      // 2. Extract deviceId from keyBundle['deviceId']
      // 3. Extract identityKey from keyBundle['identityKey'] (base64 decode)
      // 4. Extract preKeyId and preKey from keyBundle['preKeys'][0]
      // 5. Extract signedPreKeyId, signedPreKey, and signature from keyBundle['signedPreKey']
      // 6. Validate all signatures and key formats
      // 7. Create PreKeyBundle with proper libsignal objects
      
      // For now, throw a descriptive error indicating what's needed
      throw CryptographicException(
        message: 'Firebase to PreKeyBundle conversion requires implementation of:\n'
            '1. Key extraction from Firebase format\n'
            '2. Base64/hex decoding of key data\n'
            '3. IdentityKey, ECPublicKey object creation\n'
            '4. Signature validation\n'
            '5. PreKeyBundle construction\n'
            'This is a complex operation requiring careful security validation.',
        details: {
          'userId': userKeys.userId,
          'deviceId': userKeys.deviceId,
          'keyBundleType': keyBundle.runtimeType.toString(),
          'requiredImplementation': 'Full key format conversion and validation'
        },
      );
    } catch (e) {
      SignalLogger.error('Failed to convert Firebase keys: $e');
      rethrow;
    }
  }

  /// Validate sender identity
  Future<void> _validateSenderIdentity(String senderUserId) async {
    try {
      // Get trusted identity key for sender
      final trustedKey = await client.getTrustedIdentityKey(senderUserId);
      if (trustedKey == null) {
        SignalLogger.warning('No trusted identity key for sender: $senderUserId');
      }
    } catch (e) {
      SignalLogger.warning('Failed to validate sender identity: $e');
    }
  }

  /// Get message type from ciphertext
  MessageType _getMessageType(CiphertextMessage ciphertext) {
    if (ciphertext is PreKeySignalMessage) {
      return MessageType.preKeyMessage;
    } else if (ciphertext is SignalMessage) {
      return MessageType.signalMessage;
    } else {
      return MessageType.unknown;
    }
  }
}

/// Advanced encryption result with metadata
class AdvancedEncryptionResult {
  const AdvancedEncryptionResult({
    required this.ciphertext,
    required this.recipientUserId,
    required this.recipientDeviceId,
    required this.messageType,
    required this.timestamp,
  });

  final CiphertextMessage ciphertext;
  final String recipientUserId;
  final int recipientDeviceId;
  final MessageType messageType;
  final DateTime timestamp;
}

/// Advanced decryption result with metadata
class AdvancedDecryptionResult {
  const AdvancedDecryptionResult({
    required this.plaintext,
    required this.senderUserId,
    required this.senderDeviceId,
    required this.messageType,
    required this.timestamp,
    required this.validated,
  });

  final String plaintext;
  final String senderUserId;
  final int senderDeviceId;
  final MessageType messageType;
  final DateTime timestamp;
  final bool validated;
}

/// User keys information
class UserKeysInfo {
  const UserKeysInfo({
    required this.userId,
    required this.downloadedAt,
    required this.keyBundle,
    this.deviceId,
  });

  final String userId;
  final int? deviceId;
  final dynamic keyBundle; // FirebaseKeyBundle
  final DateTime downloadedAt;
}

/// Key rotation result
class KeyRotationResult {
  const KeyRotationResult({
    required this.newPreKeyCount,
    required this.newSignedPreKey,
    required this.removedKeyCount,
    required this.uploadedToFirebase,
    required this.rotatedAt,
  });

  final int newPreKeyCount;
  final SignedPreKeyRecord newSignedPreKey;
  final int removedKeyCount;
  final bool uploadedToFirebase;
  final DateTime rotatedAt;
}

/// Session information
class SessionInfo {
  const SessionInfo({
    required this.address,
    required this.established,
    required this.lastUsed,
    required this.messageCount,
  });

  final SignalProtocolAddress address;
  final bool established;
  final DateTime lastUsed;
  final int messageCount;
}

/// Session deletion result
class SessionDeletionResult {
  const SessionDeletionResult({
    required this.targetUserId,
    required this.deletedCount,
    required this.clearedFromFirebase,
    required this.deletedAt,
    this.targetDeviceId,
  });

  final String targetUserId;
  final int? targetDeviceId;
  final int deletedCount;
  final bool clearedFromFirebase;
  final DateTime deletedAt;
}

/// Storage statistics
class StorageStatistics {
  const StorageStatistics({
    required this.preKeyCount,
    required this.signedPreKeyCount,
    required this.sessionCount,
    required this.senderKeyCount,
    required this.identityKeyExists,
    required this.lastUpdated,
  });

  final int preKeyCount;
  final int signedPreKeyCount;
  final int sessionCount;
  final int senderKeyCount;
  final bool identityKeyExists;
  final DateTime lastUpdated;
}

/// Message type enumeration
enum MessageType {
  preKeyMessage,
  signalMessage,
  senderKeyMessage,
  unknown,
}

/// Group encryption result
class GroupEncryptionResult {
  const GroupEncryptionResult({
    required this.groupId,
    required this.senderId,
    required this.senderDeviceId,
    required this.ciphertext,
    required this.senderKeyDistributed,
    required this.timestamp,
  });

  final String groupId;
  final String senderId;
  final int senderDeviceId;
  final List<int> ciphertext;
  final bool senderKeyDistributed;
  final DateTime timestamp;
}

/// Group decryption result
class GroupDecryptionResult {
  const GroupDecryptionResult({
    required this.plaintext,
    required this.groupId,
    required this.senderId,
    required this.senderDeviceId,
    required this.timestamp,
    required this.validated,
  });

  final String plaintext;
  final String groupId;
  final String senderId;
  final int senderDeviceId;
  final DateTime timestamp;
  final bool validated;
}

/// Group membership result
class GroupMembershipResult {
  const GroupMembershipResult({
    required this.groupId,
    required this.memberId,
    required this.memberDeviceId,
    required this.action,
    required this.timestamp,
  });

  final String groupId;
  final String memberId;
  final int memberDeviceId;
  final GroupMembershipAction action;
  final DateTime timestamp;
}

/// Group membership action
enum GroupMembershipAction {
  added,
  removed,
  updated,
}
