/// Firebase schema validation for Signal Protocol
library;

import '../exceptions/signal_exceptions.dart';
import '../utils/logger.dart';
import 'firebase_models.dart';

/// Validator for Firebase data schemas
class FirebaseSchemaValidator {
  
  /// Validate Firebase identity key data
  static void validateIdentityKey(Map<String, dynamic> data) {
    try {
      final identityKey = FirebaseIdentityKey.fromJson(data);
      
      // Additional validation
      if (identityKey.publicKey.isEmpty) {
        throw const ValidationException(
          message: 'Identity key public key cannot be empty',
          code: 'INVALID_IDENTITY_KEY',
        );
      }
      
      if (identityKey.deviceId.isEmpty) {
        throw const ValidationException(
          message: 'Identity key device ID cannot be empty',
          code: 'INVALID_DEVICE_ID',
        );
      }
      
      if (identityKey.timestamp <= 0) {
        throw const ValidationException(
          message: 'Identity key timestamp must be positive',
          code: 'INVALID_TIMESTAMP',
        );
      }
      
      SignalLogger.info('Identity key schema validation passed');
    } catch (e) {
      SignalLogger.error('Identity key schema validation failed: $e');
      rethrow;
    }
  }
  
  /// Validate Firebase registration ID data
  static void validateRegistrationId(Map<String, dynamic> data) {
    try {
      final registrationId = FirebaseRegistrationId.fromJson(data);
      
      // Additional validation
      if (registrationId.registrationId < 0) {
        throw const ValidationException(
          message: 'Registration ID cannot be negative',
          code: 'INVALID_REGISTRATION_ID',
        );
      }
      
      if (registrationId.deviceId.isEmpty) {
        throw const ValidationException(
          message: 'Registration ID device ID cannot be empty',
          code: 'INVALID_DEVICE_ID',
        );
      }
      
      if (registrationId.timestamp <= 0) {
        throw const ValidationException(
          message: 'Registration ID timestamp must be positive',
          code: 'INVALID_TIMESTAMP',
        );
      }
      
      SignalLogger.info('Registration ID schema validation passed');
    } catch (e) {
      SignalLogger.error('Registration ID schema validation failed: $e');
      rethrow;
    }
  }
  
  /// Validate Firebase prekey data
  static void validatePreKey(Map<String, dynamic> data) {
    try {
      final preKey = FirebasePreKey.fromJson(data);
      
      // Additional validation
      if (preKey.preKeyId < 0) {
        throw const ValidationException(
          message: 'PreKey ID cannot be negative',
          code: 'INVALID_PREKEY_ID',
        );
      }
      
      if (preKey.publicKey.isEmpty) {
        throw const ValidationException(
          message: 'PreKey public key cannot be empty',
          code: 'INVALID_PREKEY',
        );
      }
      
      if (preKey.deviceId.isEmpty) {
        throw const ValidationException(
          message: 'PreKey device ID cannot be empty',
          code: 'INVALID_DEVICE_ID',
        );
      }
      
      if (preKey.timestamp <= 0) {
        throw const ValidationException(
          message: 'PreKey timestamp must be positive',
          code: 'INVALID_TIMESTAMP',
        );
      }
      
      SignalLogger.info('PreKey schema validation passed');
    } catch (e) {
      SignalLogger.error('PreKey schema validation failed: $e');
      rethrow;
    }
  }
  
  /// Validate Firebase signed prekey data
  static void validateSignedPreKey(Map<String, dynamic> data) {
    try {
      final signedPreKey = FirebaseSignedPreKey.fromJson(data);
      
      // Additional validation
      if (signedPreKey.signedPreKeyId < 0) {
        throw const ValidationException(
          message: 'Signed PreKey ID cannot be negative',
          code: 'INVALID_SIGNED_PREKEY_ID',
        );
      }
      
      if (signedPreKey.publicKey.isEmpty) {
        throw const ValidationException(
          message: 'Signed PreKey public key cannot be empty',
          code: 'INVALID_SIGNED_PREKEY',
        );
      }
      
      if (signedPreKey.signature.isEmpty) {
        throw const ValidationException(
          message: 'Signed PreKey signature cannot be empty',
          code: 'INVALID_SIGNATURE',
        );
      }
      
      if (signedPreKey.deviceId.isEmpty) {
        throw const ValidationException(
          message: 'Signed PreKey device ID cannot be empty',
          code: 'INVALID_DEVICE_ID',
        );
      }
      
      if (signedPreKey.timestamp <= 0) {
        throw const ValidationException(
          message: 'Signed PreKey timestamp must be positive',
          code: 'INVALID_TIMESTAMP',
        );
      }
      
      SignalLogger.info('Signed PreKey schema validation passed');
    } catch (e) {
      SignalLogger.error('Signed PreKey schema validation failed: $e');
      rethrow;
    }
  }
  
  /// Validate Firebase sender key data
  static void validateSenderKey(Map<String, dynamic> data) {
    try {
      final senderKey = FirebaseSenderKey.fromJson(data);
      
      // Additional validation
      if (senderKey.groupId.isEmpty) {
        throw const ValidationException(
          message: 'Sender key group ID cannot be empty',
          code: 'INVALID_GROUP_ID',
        );
      }
      
      if (senderKey.senderKeyData.isEmpty) {
        throw const ValidationException(
          message: 'Sender key data cannot be empty',
          code: 'INVALID_SENDER_KEY',
        );
      }
      
      if (senderKey.deviceId.isEmpty) {
        throw const ValidationException(
          message: 'Sender key device ID cannot be empty',
          code: 'INVALID_DEVICE_ID',
        );
      }
      
      if (senderKey.timestamp <= 0) {
        throw const ValidationException(
          message: 'Sender key timestamp must be positive',
          code: 'INVALID_TIMESTAMP',
        );
      }
      
      SignalLogger.info('Sender key schema validation passed');
    } catch (e) {
      SignalLogger.error('Sender key schema validation failed: $e');
      rethrow;
    }
  }
  
  /// Validate Firebase user metadata
  static void validateUserMetadata(Map<String, dynamic> data) {
    try {
      final metadata = FirebaseUserMetadata.fromJson(data);
      
      // Additional validation
      if (metadata.userId.isEmpty) {
        throw const ValidationException(
          message: 'User metadata user ID cannot be empty',
          code: 'INVALID_USER_ID',
        );
      }
      
      if (metadata.deviceId.isEmpty) {
        throw const ValidationException(
          message: 'User metadata device ID cannot be empty',
          code: 'INVALID_DEVICE_ID',
        );
      }
      
      if (metadata.lastUpdated <= 0) {
        throw const ValidationException(
          message: 'User metadata last updated timestamp must be positive',
          code: 'INVALID_TIMESTAMP',
        );
      }
      
      if (metadata.keysVersion <= 0) {
        throw const ValidationException(
          message: 'User metadata keys version must be positive',
          code: 'INVALID_VERSION',
        );
      }
      
      SignalLogger.info('User metadata schema validation passed');
    } catch (e) {
      SignalLogger.error('User metadata schema validation failed: $e');
      rethrow;
    }
  }
  
  /// Validate complete Firebase key bundle
  static void validateKeyBundle(Map<String, dynamic> data) {
    try {
      final keyBundle = FirebaseKeyBundle.fromJson(data);
      
      // Additional validation
      if (keyBundle.userId.isEmpty) {
        throw const ValidationException(
          message: 'Key bundle user ID cannot be empty',
          code: 'INVALID_USER_ID',
        );
      }
      
      if (keyBundle.deviceId.isEmpty) {
        throw const ValidationException(
          message: 'Key bundle device ID cannot be empty',
          code: 'INVALID_DEVICE_ID',
        );
      }
      
      // Validate nested components
      validateIdentityKey(keyBundle.identityKey.toJson());
      validateRegistrationId(keyBundle.registrationId.toJson());
      validateSignedPreKey(keyBundle.signedPreKey.toJson());
      validateUserMetadata(keyBundle.metadata.toJson());
      
      // Validate prekeys
      for (final preKey in keyBundle.preKeys) {
        validatePreKey(preKey.toJson());
      }
      
      SignalLogger.info('Key bundle schema validation passed');
    } catch (e) {
      SignalLogger.error('Key bundle schema validation failed: $e');
      rethrow;
    }
  }
  
  /// Validate Firebase sync event
  static void validateSyncEvent(Map<String, dynamic> data) {
    try {
      final syncEvent = FirebaseSyncEvent.fromJson(data);
      
      // Additional validation
      if (syncEvent.eventType.isEmpty) {
        throw const ValidationException(
          message: 'Sync event type cannot be empty',
          code: 'INVALID_EVENT_TYPE',
        );
      }
      
      if (syncEvent.userId.isEmpty) {
        throw const ValidationException(
          message: 'Sync event user ID cannot be empty',
          code: 'INVALID_USER_ID',
        );
      }
      
      if (syncEvent.deviceId.isEmpty) {
        throw const ValidationException(
          message: 'Sync event device ID cannot be empty',
          code: 'INVALID_DEVICE_ID',
        );
      }
      
      if (syncEvent.timestamp <= 0) {
        throw const ValidationException(
          message: 'Sync event timestamp must be positive',
          code: 'INVALID_TIMESTAMP',
        );
      }
      
      // Validate known event types
      const validEventTypes = {
        'key_updated',
        'key_deleted',
        'user_offline',
        'force_sync_complete',
        'local_keys_uploaded',
        'conflict_resolved',
        'sync_error',
        'group_key_updated',
      };
      
      if (!validEventTypes.contains(syncEvent.eventType)) {
        throw ValidationException(
          message: 'Unknown sync event type: ${syncEvent.eventType}',
          code: 'INVALID_EVENT_TYPE',
        );
      }
      
      SignalLogger.info('Sync event schema validation passed');
    } catch (e) {
      SignalLogger.error('Sync event schema validation failed: $e');
      rethrow;
    }
  }
  
  /// Validate any Firebase data based on type
  static void validateByType(String dataType, Map<String, dynamic> data) {
    switch (dataType.toLowerCase()) {
      case 'identity_key':
        validateIdentityKey(data);
        break;
      case 'registration_id':
        validateRegistrationId(data);
        break;
      case 'prekey':
        validatePreKey(data);
        break;
      case 'signed_prekey':
        validateSignedPreKey(data);
        break;
      case 'sender_key':
        validateSenderKey(data);
        break;
      case 'user_metadata':
        validateUserMetadata(data);
        break;
      case 'key_bundle':
        validateKeyBundle(data);
        break;
      case 'sync_event':
        validateSyncEvent(data);
        break;
      default:
        throw ValidationException(
          message: 'Unknown data type for validation: $dataType',
          code: 'UNKNOWN_DATA_TYPE',
        );
    }
  }
}
