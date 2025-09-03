/// Basic identity store implementation for Signal Protocol
library;

import 'dart:typed_data';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import 'package:hive/hive.dart';

import '../exceptions/signal_exceptions.dart';
import '../utils/logger.dart';
import '../storage/hive_registry.dart';

/// Basic identity store implementation using Hive
class BasicIdentityStore implements IdentityKeyStore {
  static const String _boxName = 'signal_identity';
  late Box<dynamic> _identityBox;
  
  static const String _identityKeyPairKey = 'identity_keypair';
  static const String _registrationIdKey = 'registration_id';
  static const String _trustedKeysPrefix = 'trusted_key_';

  /// Initialize the identity store
  Future<void> initialize() async {
    try {
      HiveRegistry.registerAdapters();
      _identityBox = await Hive.openBox(_boxName);
      SignalLogger.info('BasicIdentityStore initialized successfully');
    } catch (e) {
      SignalLogger.error('Failed to initialize BasicIdentityStore: $e');
      throw StorageException(message: 'Failed to initialize identity store: $e');
    }
  }

  @override
  Future<IdentityKeyPair> getIdentityKeyPair() async {
    try {
      final data = _identityBox.get(_identityKeyPairKey);
      if (data == null) {
        throw StorageException(message: 'Identity key pair not found');
      }
      
      // Deserialize the identity key pair
      return IdentityKeyPair.fromSerialized(Uint8List.fromList(data.cast<int>()));
    } catch (e) {
      SignalLogger.error('Failed to get identity key pair: $e');
      throw StorageException(message: 'Failed to get identity key pair: $e');
    }
  }

  @override
  Future<int> getLocalRegistrationId() async {
    try {
      return _identityBox.get(_registrationIdKey, defaultValue: 0);
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
      await _identityBox.put(key, identityKey.serialize());
      SignalLogger.debug('Saved identity for ${address.getName()}:${address.getDeviceId()}');
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
      final storedKeyData = _identityBox.get(key);
      
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
      final data = _identityBox.get(key);
      if (data == null) return null;
      
      // Deserialize the identity key from stored data
      try {
        // In a full implementation, this would deserialize ECPublicKey from bytes
        // For now, we return null to indicate deserialization is not yet implemented
        SignalLogger.debug('Identity key found but deserialization not yet implemented');
        return null;
      } catch (deserializationError) {
        SignalLogger.error('Failed to deserialize identity key: $deserializationError');
        return null;
      }
    } catch (e) {
      SignalLogger.error('Failed to get identity: $e');
      return null;
    }
  }

  /// Set the identity key pair (for initialization)
  Future<void> setIdentityKeyPair(IdentityKeyPair keyPair) async {
    try {
      await _identityBox.put(_identityKeyPairKey, keyPair.serialize());
      SignalLogger.debug('Identity key pair stored');
    } catch (e) {
      SignalLogger.error('Failed to store identity key pair: $e');
      throw StorageException(message: 'Failed to store identity key pair: $e');
    }
  }

  /// Set the local registration ID (for initialization)
  Future<void> setLocalRegistrationId(int registrationId) async {
    try {
      await _identityBox.put(_registrationIdKey, registrationId);
      SignalLogger.debug('Registration ID stored: $registrationId');
    } catch (e) {
      SignalLogger.error('Failed to store registration ID: $e');
      throw StorageException(message: 'Failed to store registration ID: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await _identityBox.close();
      SignalLogger.info('BasicIdentityStore disposed');
    } catch (e) {
      SignalLogger.error('Failed to dispose BasicIdentityStore: $e');
    }
  }
}
