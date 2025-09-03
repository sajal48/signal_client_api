/// Signed PreKey store implementation using Hive for persistent storage
library;

import 'package:hive/hive.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import '../exceptions/signal_exceptions.dart';
import '../utils/logger.dart';
import 'hive_models.dart';
import 'hive_registry.dart';

/// Hive-based implementation of SignedPreKeyStore for persistent signed prekey storage
class HiveSignedPreKeyStore implements SignedPreKeyStore {
  static const String _boxName = 'signal_signed_prekeys';
  late Box<HiveSignedPreKeyRecord> _signedPreKeyBox;

  /// Initializes the Hive signed prekey store
  Future<void> initialize() async {
    try {
      // Ensure Hive adapters are registered before opening boxes
      HiveRegistry.registerAdapters();
      
      _signedPreKeyBox = await Hive.openBox<HiveSignedPreKeyRecord>(_boxName);
      SignalLogger.info('HiveSignedPreKeyStore initialized successfully');
    } catch (e) {
      SignalLogger.error('Failed to initialize HiveSignedPreKeyStore: $e');
      throw StorageException(message: 'Failed to initialize signed prekey store: $e');
    }
  }

  /// Closes the signed prekey store and cleans up resources
  Future<void> close() async {
    try {
      await _signedPreKeyBox.close();
      SignalLogger.info('HiveSignedPreKeyStore closed successfully');
    } catch (e) {
      SignalLogger.error('Failed to close HiveSignedPreKeyStore: $e');
      throw StorageException(message: 'Failed to close signed prekey store: $e');
    }
  }

  @override
  Future<SignedPreKeyRecord> loadSignedPreKey(int signedPreKeyId) async {
    try {
      final hiveRecord = _signedPreKeyBox.get(signedPreKeyId);
      
      if (hiveRecord == null) {
        SignalLogger.debug('SignedPreKey $signedPreKeyId not found');
        throw InvalidKeyIdException('SignedPreKey $signedPreKeyId not found');
      }

      SignalLogger.debug('SignedPreKey $signedPreKeyId loaded successfully');
      // Deserialize using the correct libsignal API
      return SignedPreKeyRecord.fromSerialized(hiveRecord.keyData);
    } catch (e) {
      if (e is InvalidKeyIdException) rethrow;
      if (e is UnimplementedError) rethrow;
      SignalLogger.error('Failed to load signed prekey $signedPreKeyId: $e');
      throw StorageException(message: 'Failed to load signed prekey: $e');
    }
  }

  @override
  Future<List<SignedPreKeyRecord>> loadSignedPreKeys() async {
    try {
      final allRecords = <SignedPreKeyRecord>[];
      
      for (final entry in _signedPreKeyBox.toMap().entries) {
        final signedPreKeyRecord = SignedPreKeyRecord.fromSerialized(entry.value.keyData);
        allRecords.add(signedPreKeyRecord);
        SignalLogger.debug('Loaded signed prekey ID: ${entry.key}');
      }
      
      SignalLogger.debug('Loaded ${allRecords.length} signed prekeys');
      return allRecords;
    } catch (e) {
      if (e is UnimplementedError) rethrow;
      SignalLogger.error('Failed to load all signed prekeys: $e');
      throw StorageException(message: 'Failed to load all signed prekeys: $e');
    }
  }

  @override
  Future<void> storeSignedPreKey(int signedPreKeyId, SignedPreKeyRecord record) async {
    try {
      final keyData = record.serialize();
      
      final hiveRecord = HiveSignedPreKeyRecord(
        id: signedPreKeyId,
        keyData: keyData,
        signature: record.signature,
        created: DateTime.now(),
      );
      
      await _signedPreKeyBox.put(signedPreKeyId, hiveRecord);
      SignalLogger.debug('SignedPreKey $signedPreKeyId stored successfully');
    } catch (e) {
      SignalLogger.error('Failed to store signed prekey $signedPreKeyId: $e');
      throw StorageException(message: 'Failed to store signed prekey: $e');
    }
  }

  @override
  Future<bool> containsSignedPreKey(int signedPreKeyId) async {
    try {
      final exists = _signedPreKeyBox.containsKey(signedPreKeyId);
      SignalLogger.debug('SignedPreKey $signedPreKeyId exists: $exists');
      return exists;
    } catch (e) {
      SignalLogger.error('Failed to check signed prekey existence $signedPreKeyId: $e');
      throw StorageException(message: 'Failed to check signed prekey existence: $e');
    }
  }

  @override
  Future<void> removeSignedPreKey(int signedPreKeyId) async {
    try {
      await _signedPreKeyBox.delete(signedPreKeyId);
      SignalLogger.debug('SignedPreKey $signedPreKeyId removed successfully');
    } catch (e) {
      SignalLogger.error('Failed to remove signed prekey $signedPreKeyId: $e');
      throw StorageException(message: 'Failed to remove signed prekey: $e');
    }
  }

  /// Gets all stored signed prekey IDs
  Future<List<int>> getAllSignedPreKeyIds() async {
    try {
      return _signedPreKeyBox.keys.cast<int>().toList();
    } catch (e) {
      SignalLogger.error('Failed to get all signed prekey IDs: $e');
      throw StorageException(message: 'Failed to get all signed prekey IDs: $e');
    }
  }

  /// Gets all stored signed prekeys (useful for debugging and management)
  Future<List<HiveSignedPreKeyRecord>> getAllSignedPreKeys() async {
    try {
      return _signedPreKeyBox.values.toList();
    } catch (e) {
      SignalLogger.error('Failed to get all signed prekeys: $e');
      throw StorageException(message: 'Failed to get all signed prekeys: $e');
    }
  }

  /// Cleans up old signed prekeys based on creation date
  Future<int> cleanupOldSignedPreKeys({Duration? olderThan}) async {
    try {
      olderThan ??= const Duration(days: 7); // More frequent cleanup for signed prekeys
      final cutoffDate = DateTime.now().subtract(olderThan);
      
      final keysToDelete = <int>[];
      
      for (final entry in _signedPreKeyBox.toMap().entries) {
        if (entry.value.created.isBefore(cutoffDate)) {
          keysToDelete.add(entry.key);
        }
      }
      
      await _signedPreKeyBox.deleteAll(keysToDelete);
      SignalLogger.info('Cleaned up ${keysToDelete.length} old signed prekeys');
      return keysToDelete.length;
    } catch (e) {
      SignalLogger.error('Failed to cleanup old signed prekeys: $e');
      throw StorageException(message: 'Failed to cleanup old signed prekeys: $e');
    }
  }

  /// Gets the count of stored signed prekeys
  int get signedPreKeyCount => _signedPreKeyBox.length;

  /// Checks if the store is initialized
  bool get isInitialized => _signedPreKeyBox.isOpen;

  /// Gets signed prekeys within a specific ID range
  Future<List<HiveSignedPreKeyRecord>> getSignedPreKeysInRange(int minId, int maxId) async {
    try {
      final signedPreKeysInRange = <HiveSignedPreKeyRecord>[];
      
      for (final entry in _signedPreKeyBox.toMap().entries) {
        if (entry.key >= minId && entry.key <= maxId) {
          signedPreKeysInRange.add(entry.value);
        }
      }
      
      SignalLogger.debug('Found ${signedPreKeysInRange.length} signed prekeys in range $minId-$maxId');
      return signedPreKeysInRange;
    } catch (e) {
      SignalLogger.error('Failed to get signed prekeys in range $minId-$maxId: $e');
      throw StorageException(message: 'Failed to get signed prekeys in range: $e');
    }
  }

  /// Removes signed prekeys in batch
  Future<void> removeSignedPreKeys(List<int> signedPreKeyIds) async {
    try {
      await _signedPreKeyBox.deleteAll(signedPreKeyIds);
      SignalLogger.debug('Removed ${signedPreKeyIds.length} signed prekeys in batch');
    } catch (e) {
      SignalLogger.error('Failed to remove signed prekeys in batch: $e');
      throw StorageException(message: 'Failed to remove signed prekeys in batch: $e');
    }
  }

  /// Clear all signed prekeys from storage
  Future<void> clearAllSignedPreKeys() async {
    try {
      await _signedPreKeyBox.clear();
      SignalLogger.info('Cleared all signed prekeys from storage');
    } catch (e) {
      SignalLogger.error('Failed to clear all signed prekeys: $e');
      throw StorageException(message: 'Failed to clear all signed prekeys: $e');
    }
  }

  /// Get the total count of stored signed prekeys
  Future<int> getSignedPreKeyCount() async {
    try {
      return _signedPreKeyBox.length;
    } catch (e) {
      SignalLogger.error('Failed to get signed prekey count: $e');
      return 0;
    }
  }
}
