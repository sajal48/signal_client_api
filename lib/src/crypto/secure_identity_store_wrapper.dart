/// Secure identity store wrapper implementing IdentityKeyStore interface
library;

import 'dart:typed_data';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import 'package:hive/hive.dart';

import '../exceptions/signal_exceptions.dart';
import '../utils/logger.dart';
import '../storage/hive_registry.dart';
import '../storage/secure_identity_store.dart';

/// Secure identity store wrapper that implements IdentityKeyStore
/// Uses SecureIdentityStore for sensitive identity data and Hive for trusted keys
class SecureIdentityStoreWrapper implements IdentityKeyStore {
  static const String _boxName = 'signal_trusted_keys';
  late Box<dynamic> _trustedKeysBox;
  
  static const String _trustedKeysPrefix = 'trusted_key_';

  /// Initialize the identity store wrapper
  Future<void> initialize() async {
    try {
      HiveRegistry.registerAdapters();
      _trustedKeysBox = await Hive.openBox(_boxName);
      SignalLogger.info('SecureIdentityStoreWrapper initialized successfully');
    } catch (e) {
      SignalLogger.error('Failed to initialize SecureIdentityStoreWrapper: $e');
      throw StorageException(message: 'Failed to initialize identity store: $e');
    }
  }

  @override
  Future<IdentityKeyPair> getIdentityKeyPair() async {
    try {
      // Get private and public keys from secure storage
      final privateKeyData = await SecureIdentityStore.getIdentityPrivateKey();
      final publicKeyData = await SecureIdentityStore.getIdentityPublicKey();
      
      if (privateKeyData == null || publicKeyData == null) {
        throw StorageException(message: 'Identity key pair not found in secure storage');
      }
      
      // Reconstruct the IdentityKeyPair from stored components
      // Note: This combines both keys - in practice you might need different reconstruction
      final combinedData = Uint8List.fromList([...privateKeyData, ...publicKeyData]);
      return IdentityKeyPair.fromSerialized(combinedData);
    } catch (e) {
      SignalLogger.error('Failed to get identity key pair: $e');
      throw StorageException(message: 'Failed to get identity key pair: $e');
    }
  }

  @override
  Future<int> getLocalRegistrationId() async {
    try {
      final registrationId = await SecureIdentityStore.getRegistrationId();
      return registrationId ?? 0;
    } catch (e) {
      SignalLogger.error('Failed to get registration ID: $e');
      return 0;
    }
  }

  @override
  Future<bool> saveIdentity(SignalProtocolAddress address, IdentityKey? identityKey) async {
    try {
      if (identityKey == null) return false;
      
      final key = '$_trustedKeysPrefix${address.getName()}_${address.getDeviceId()}';
      await _trustedKeysBox.put(key, identityKey.serialize());
      SignalLogger.debug('Saved trusted identity for ${address.getName()}:${address.getDeviceId()}');
      return true;
    } catch (e) {
      SignalLogger.error('Failed to save identity: $e');
      return false;
    }
  }

  @override
  Future<bool> isTrustedIdentity(SignalProtocolAddress address, IdentityKey? identityKey, Direction direction) async {
    try {
      if (identityKey == null) return false;
      
      final key = '$_trustedKeysPrefix${address.getName()}_${address.getDeviceId()}';
      final storedKeyData = _trustedKeysBox.get(key);
      
      if (storedKeyData == null) {
        // No stored key means this is the first time we see this identity
        return true;
      }
      
      // Compare the serialized data directly
      return List<int>.from(storedKeyData).toString() == identityKey.serialize().toString();
    } catch (e) {
      SignalLogger.error('Failed to check trusted identity: $e');
      return false;
    }
  }

  @override
  Future<IdentityKey?> getIdentity(SignalProtocolAddress address) async {
    try {
      final key = '$_trustedKeysPrefix${address.getName()}_${address.getDeviceId()}';
      final data = _trustedKeysBox.get(key);
      if (data == null) return null;
      
      // Deserialize the identity key from stored data
      try {
        // In a full implementation, this would deserialize ECPublicKey from bytes
        // For now, we return null to indicate deserialization is not yet implemented
        SignalLogger.debug('Trusted identity key found but deserialization not yet implemented');
        return null;
      } catch (deserializationError) {
        SignalLogger.error('Failed to deserialize trusted identity key: $deserializationError');
        return null;
      }
    } catch (e) {
      SignalLogger.error('Failed to get identity: $e');
      return null;
    }
  }

  /// Set the identity key pair (for initialization) - stores in secure storage
  Future<void> setIdentityKeyPair(IdentityKeyPair keyPair) async {
    try {
      final serialized = keyPair.serialize();
      
      // Split the serialized data into private and public components
      // This is a simplified approach - in practice you'd need proper key extraction
      final midPoint = serialized.length ~/ 2;
      final privateKeyData = serialized.sublist(0, midPoint);
      final publicKeyData = serialized.sublist(midPoint);
      
      await SecureIdentityStore.storeIdentityPrivateKey(privateKeyData);
      await SecureIdentityStore.storeIdentityPublicKey(publicKeyData);
      
      SignalLogger.debug('Identity key pair stored in secure storage');
    } catch (e) {
      SignalLogger.error('Failed to store identity key pair: $e');
      throw StorageException(message: 'Failed to store identity key pair: $e');
    }
  }

  /// Set the local registration ID (for initialization) - stores in secure storage
  Future<void> setLocalRegistrationId(int registrationId) async {
    try {
      await SecureIdentityStore.storeRegistrationId(registrationId);
      SignalLogger.debug('Registration ID stored in secure storage: $registrationId');
    } catch (e) {
      SignalLogger.error('Failed to store registration ID: $e');
      throw StorageException(message: 'Failed to store registration ID: $e');
    }
  }

  /// Check if identity keys exist in secure storage
  Future<bool> hasIdentityKeys() async {
    try {
      return await SecureIdentityStore.hasIdentityKeys();
    } catch (e) {
      SignalLogger.error('Failed to check identity keys: $e');
      return false;
    }
  }

  /// Clear all identity data from both secure storage and trusted keys
  Future<void> clearAll() async {
    try {
      await SecureIdentityStore.clearAll();
      await _trustedKeysBox.clear();
      SignalLogger.info('Cleared all identity data');
    } catch (e) {
      SignalLogger.error('Failed to clear identity data: $e');
      throw StorageException(message: 'Failed to clear identity data: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await _trustedKeysBox.close();
      SignalLogger.info('SecureIdentityStoreWrapper disposed');
    } catch (e) {
      SignalLogger.error('Failed to dispose SecureIdentityStoreWrapper: $e');
    }
  }
}
