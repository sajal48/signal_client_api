/// Firebase key manager for Signal Protocol keys
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import '../exceptions/signal_exceptions.dart';
import '../utils/logger.dart';
import '../utils/validators.dart';
import 'firebase_config.dart';
import 'firebase_models.dart';

/// Manages uploading, downloading, and syncing Signal Protocol keys with Firebase
class FirebaseKeyManager {
  
  /// Upload user's identity key to Firebase
  static Future<void> uploadIdentityKey({
    required String userId,
    required String deviceId,
    required IdentityKey identityKey,
  }) async {
    try {
      Validators.validateUserId(userId);
      // Note: deviceId is String in our Firebase models
      
      final publicKeyBytes = identityKey.serialize();
      final publicKeyBase64 = base64Encode(publicKeyBytes);

      final firebaseIdentityKey = FirebaseIdentityKey(
        publicKey: publicKeyBase64,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        deviceId: deviceId,
      );

      final ref = FirebaseConfig.database.ref(
        FirebaseConfig.userIdentityKeyPath(userId),
      );

      await ref.set(firebaseIdentityKey.toJson());

      SignalLogger.info('Identity key uploaded for user: $userId, device: $deviceId');
    } catch (e) {
      SignalLogger.error('Failed to upload identity key: $e');
      throw FirebaseException(message: 'Failed to upload identity key: $e');
    }
  }

  /// Download user's identity key from Firebase
  static Future<IdentityKey?> downloadIdentityKey({
    required String userId,
  }) async {
    try {
      Validators.validateUserId(userId);

      final ref = FirebaseConfig.database.ref(
        FirebaseConfig.userIdentityKeyPath(userId),
      );

      final snapshot = await ref.get();
      if (!snapshot.exists) {
        SignalLogger.info('No identity key found for user: $userId');
        return null;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final firebaseIdentityKey = FirebaseIdentityKey.fromJson(data);

      final publicKeyBytes = base64Decode(firebaseIdentityKey.publicKey);
      final identityKey = IdentityKey.fromBytes(
        Uint8List.fromList(publicKeyBytes),
        0, // offset
      );

      SignalLogger.info('Identity key downloaded for user: $userId');
      return identityKey;
    } catch (e) {
      SignalLogger.error('Failed to download identity key: $e');
      throw FirebaseException(message: 'Failed to download identity key: $e');
    }
  }

  /// Upload user's registration ID to Firebase
  static Future<void> uploadRegistrationId({
    required String userId,
    required String deviceId,
    required int registrationId,
  }) async {
    try {
      Validators.validateUserId(userId);

      final firebaseRegistrationId = FirebaseRegistrationId(
        registrationId: registrationId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        deviceId: deviceId,
      );

      final ref = FirebaseConfig.database.ref(
        FirebaseConfig.userRegistrationIdPath(userId),
      );

      await ref.set(firebaseRegistrationId.toJson());

      SignalLogger.info('Registration ID uploaded for user: $userId, device: $deviceId');
    } catch (e) {
      SignalLogger.error('Failed to upload registration ID: $e');
      throw FirebaseException(message: 'Failed to upload registration ID: $e');
    }
  }

  /// Download user's registration ID from Firebase
  static Future<int?> downloadRegistrationId({
    required String userId,
  }) async {
    try {
      Validators.validateUserId(userId);

      final ref = FirebaseConfig.database.ref(
        FirebaseConfig.userRegistrationIdPath(userId),
      );

      final snapshot = await ref.get();
      if (!snapshot.exists) {
        SignalLogger.info('No registration ID found for user: $userId');
        return null;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final firebaseRegistrationId = FirebaseRegistrationId.fromJson(data);

      SignalLogger.info('Registration ID downloaded for user: $userId');
      return firebaseRegistrationId.registrationId;
    } catch (e) {
      SignalLogger.error('Failed to download registration ID: $e');
      throw FirebaseException(message: 'Failed to download registration ID: $e');
    }
  }

  /// Upload signed prekey to Firebase
  static Future<void> uploadSignedPreKey({
    required String userId,
    required String deviceId,
    required SignedPreKeyRecord signedPreKey,
  }) async {
    try {
      Validators.validateUserId(userId);

      final publicKeyBytes = signedPreKey.getKeyPair().publicKey.serialize();
      final signatureBytes = signedPreKey.signature;

      final firebaseSignedPreKey = FirebaseSignedPreKey(
        signedPreKeyId: signedPreKey.id,
        publicKey: base64Encode(publicKeyBytes),
        signature: base64Encode(signatureBytes),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        deviceId: deviceId,
        isActive: true,
      );

      final ref = FirebaseConfig.database.ref(
        FirebaseConfig.userSignedPreKeyPath(userId),
      );

      await ref.set(firebaseSignedPreKey.toJson());

      SignalLogger.info('Signed prekey uploaded for user: $userId, device: $deviceId');
    } catch (e) {
      SignalLogger.error('Failed to upload signed prekey: $e');
      throw FirebaseException(message: 'Failed to upload signed prekey: $e');
    }
  }

  /// Upload prekeys to Firebase
  static Future<void> uploadPreKeys({
    required String userId,
    required String deviceId,
    required List<PreKeyRecord> preKeys,
  }) async {
    try {
      Validators.validateUserId(userId);

      if (preKeys.isEmpty) {
        throw const ValidationException(message: 'PreKeys list cannot be empty');
      }

      final preKeysPath = FirebaseConfig.userPreKeysPath(userId);
      final updates = <String, dynamic>{};

      for (final preKey in preKeys) {
        final publicKeyBytes = preKey.getKeyPair().publicKey.serialize();
        
        final firebasePreKey = FirebasePreKey(
          preKeyId: preKey.id,
          publicKey: base64Encode(publicKeyBytes),
          timestamp: DateTime.now().millisecondsSinceEpoch,
          deviceId: deviceId,
          isActive: true,
        );

        updates['$preKeysPath/${preKey.id}'] = firebasePreKey.toJson();
      }

      await FirebaseConfig.database.ref().update(updates);

      SignalLogger.info('${preKeys.length} prekeys uploaded for user: $userId, device: $deviceId');
    } catch (e) {
      SignalLogger.error('Failed to upload prekeys: $e');
      throw FirebaseException(message: 'Failed to upload prekeys: $e');
    }
  }

  /// Download available prekeys for a user
  static Future<List<FirebasePreKey>> downloadPreKeys({
    required String userId,
    int? limit,
  }) async {
    try {
      Validators.validateUserId(userId);

      final ref = FirebaseConfig.database.ref(
        FirebaseConfig.userPreKeysPath(userId),
      );

      Query query = ref.orderByChild('isActive').equalTo(true);
      if (limit != null && limit > 0) {
        query = query.limitToFirst(limit);
      }

      final snapshot = await query.get();
      if (!snapshot.exists) {
        SignalLogger.info('No prekeys found for user: $userId');
        return [];
      }

      final preKeys = <FirebasePreKey>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in data.entries) {
        final preKeyData = Map<String, dynamic>.from(entry.value as Map);
        final firebasePreKey = FirebasePreKey.fromJson(preKeyData);
        preKeys.add(firebasePreKey);
      }

      SignalLogger.info('${preKeys.length} prekeys downloaded for user: $userId');
      return preKeys;
    } catch (e) {
      SignalLogger.error('Failed to download prekeys: $e');
      throw FirebaseException(message: 'Failed to download prekeys: $e');
    }
  }

  /// Mark a prekey as used/inactive
  static Future<void> markPreKeyAsUsed({
    required String userId,
    required int preKeyId,
  }) async {
    try {
      Validators.validateUserId(userId);

      final ref = FirebaseConfig.database.ref(
        FirebaseConfig.userPreKeyPath(userId, preKeyId),
      );

      await ref.update({'isActive': false});

      SignalLogger.info('PreKey $preKeyId marked as used for user: $userId');
    } catch (e) {
      SignalLogger.error('Failed to mark prekey as used: $e');
      throw FirebaseException(message: 'Failed to mark prekey as used: $e');
    }
  }

  /// Get complete key bundle for a user
  static Future<FirebaseKeyBundle?> downloadKeyBundle({
    required String userId,
  }) async {
    try {
      Validators.validateUserId(userId);

      // Download all components in parallel
      final futures = await Future.wait([
        downloadIdentityKey(userId: userId),
        downloadRegistrationId(userId: userId),
        downloadPreKeys(userId: userId, limit: 1), // Get one prekey
        _downloadSignedPreKeyData(userId: userId),
        _downloadUserMetadata(userId: userId),
      ]);

      final identityKey = futures[0] as IdentityKey?;
      final registrationId = futures[1] as int?;
      final preKeys = futures[2] as List<FirebasePreKey>;
      final signedPreKeyData = futures[3] as FirebaseSignedPreKey?;
      final metadata = futures[4] as FirebaseUserMetadata?;

      if (identityKey == null || 
          registrationId == null || 
          signedPreKeyData == null || 
          metadata == null) {
        SignalLogger.info('Incomplete key bundle for user: $userId');
        return null;
      }

      final firebaseIdentityKey = FirebaseIdentityKey(
        publicKey: base64Encode(identityKey.serialize()),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        deviceId: metadata.deviceId,
      );

      final firebaseRegistrationId = FirebaseRegistrationId(
        registrationId: registrationId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        deviceId: metadata.deviceId,
      );

      final keyBundle = FirebaseKeyBundle(
        userId: userId,
        deviceId: metadata.deviceId,
        identityKey: firebaseIdentityKey,
        registrationId: firebaseRegistrationId,
        signedPreKey: signedPreKeyData,
        preKeys: preKeys,
        metadata: metadata,
      );

      SignalLogger.info('Complete key bundle downloaded for user: $userId');
      return keyBundle;
    } catch (e) {
      SignalLogger.error('Failed to download key bundle: $e');
      throw FirebaseException(message: 'Failed to download key bundle: $e');
    }
  }

  /// Download signed prekey data (metadata only)
  static Future<FirebaseSignedPreKey?> _downloadSignedPreKeyData({
    required String userId,
  }) async {
    final ref = FirebaseConfig.database.ref(
      FirebaseConfig.userSignedPreKeyPath(userId),
    );

    final snapshot = await ref.get();
    if (!snapshot.exists) {
      return null;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return FirebaseSignedPreKey.fromJson(data);
  }

  /// Download user metadata
  static Future<FirebaseUserMetadata?> _downloadUserMetadata({
    required String userId,
  }) async {
    final ref = FirebaseConfig.database.ref(
      FirebaseConfig.userMetadataPath(userId),
    );

    final snapshot = await ref.get();
    if (!snapshot.exists) {
      return null;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return FirebaseUserMetadata.fromJson(data);
  }

  /// Update user metadata
  static Future<void> updateUserMetadata({
    required String userId,
    required String deviceId,
    String? displayName,
    Map<String, dynamic>? customData,
  }) async {
    try {
      Validators.validateUserId(userId);

      final metadata = FirebaseUserMetadata(
        userId: userId,
        deviceId: deviceId,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
        keysVersion: DateTime.now().millisecondsSinceEpoch, // Simple versioning
        displayName: displayName,
        customData: customData,
      );

      final ref = FirebaseConfig.database.ref(
        FirebaseConfig.userMetadataPath(userId),
      );

      await ref.set(metadata.toJson());

      SignalLogger.info('User metadata updated for user: $userId, device: $deviceId');
    } catch (e) {
      SignalLogger.error('Failed to update user metadata: $e');
      throw FirebaseException(message: 'Failed to update user metadata: $e');
    }
  }

  /// Delete all keys for a user
  static Future<void> deleteUserKeys({
    required String userId,
  }) async {
    try {
      Validators.validateUserId(userId);

      final ref = FirebaseConfig.database.ref(
        FirebaseConfig.userPath(userId),
      );

      await ref.remove();

      SignalLogger.info('All keys deleted for user: $userId');
    } catch (e) {
      SignalLogger.error('Failed to delete user keys: $e');
      throw FirebaseException(message: 'Failed to delete user keys: $e');
    }
  }

  /// Check if user has keys in Firebase
  static Future<bool> hasKeysForUser({
    required String userId,
  }) async {
    try {
      Validators.validateUserId(userId);

      final ref = FirebaseConfig.database.ref(
        FirebaseConfig.userPath(userId),
      );

      final snapshot = await ref.get();
      return snapshot.exists;
    } catch (e) {
      SignalLogger.error('Failed to check if user has keys: $e');
      throw FirebaseException(message: 'Failed to check if user has keys: $e');
    }
  }
}
