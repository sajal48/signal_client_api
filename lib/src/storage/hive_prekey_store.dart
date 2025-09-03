/// PreKey store implementation using Hive for persistent storage
library;

import 'package:hive/hive.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import '../exceptions/signal_exceptions.dart';
import '../utils/logger.dart';
import 'hive_models.dart';
import 'hive_registry.dart';

/// Hive-based implementation of PreKeyStore for persistent prekey storage
class HivePreKeyStore implements PreKeyStore {
  static const String _boxName = 'signal_prekeys';
  late Box<HivePreKeyRecord> _preKeyBox;

  /// Initializes the Hive prekey store
  Future<void> initialize() async {
    try {
      // Ensure Hive adapters are registered before opening boxes
      HiveRegistry.registerAdapters();
      
      _preKeyBox = await Hive.openBox<HivePreKeyRecord>(_boxName);
      SignalLogger.info('HivePreKeyStore initialized successfully');
    } catch (e) {
      SignalLogger.error('Failed to initialize HivePreKeyStore: $e');
      throw StorageException(message: 'Failed to initialize prekey store: $e');
    }
  }

  /// Closes the prekey store and cleans up resources
  Future<void> close() async {
    try {
      await _preKeyBox.close();
      SignalLogger.info('HivePreKeyStore closed successfully');
    } catch (e) {
      SignalLogger.error('Failed to close HivePreKeyStore: $e');
      throw StorageException(message: 'Failed to close prekey store: $e');
    }
  }

  @override
  Future<PreKeyRecord> loadPreKey(int preKeyId) async {
    try {
      final hiveRecord = _preKeyBox.get(preKeyId);
      
      if (hiveRecord == null) {
        SignalLogger.debug('PreKey $preKeyId not found');
        throw InvalidKeyIdException('PreKey $preKeyId not found');
      }

      SignalLogger.debug('PreKey $preKeyId loaded successfully');
      // Deserialize using the correct libsignal API
      return PreKeyRecord.fromBuffer(hiveRecord.keyData);
    } catch (e) {
      if (e is InvalidKeyIdException) rethrow;
      if (e is UnimplementedError) rethrow;
      SignalLogger.error('Failed to load prekey $preKeyId: $e');
      throw StorageException(message: 'Failed to load prekey: $e');
    }
  }

  @override
  Future<void> storePreKey(int preKeyId, PreKeyRecord record) async {
    try {
      final keyData = record.serialize();
      
      final hiveRecord = HivePreKeyRecord(
        id: preKeyId,
        keyData: keyData,
        created: DateTime.now(),
      );
      
      await _preKeyBox.put(preKeyId, hiveRecord);
      SignalLogger.debug('PreKey $preKeyId stored successfully');
    } catch (e) {
      SignalLogger.error('Failed to store prekey $preKeyId: $e');
      throw StorageException(message: 'Failed to store prekey: $e');
    }
  }

  @override
  Future<bool> containsPreKey(int preKeyId) async {
    try {
      final exists = _preKeyBox.containsKey(preKeyId);
      SignalLogger.debug('PreKey $preKeyId exists: $exists');
      return exists;
    } catch (e) {
      SignalLogger.error('Failed to check prekey existence $preKeyId: $e');
      throw StorageException(message: 'Failed to check prekey existence: $e');
    }
  }

  @override
  Future<void> removePreKey(int preKeyId) async {
    try {
      await _preKeyBox.delete(preKeyId);
      SignalLogger.debug('PreKey $preKeyId removed successfully');
    } catch (e) {
      SignalLogger.error('Failed to remove prekey $preKeyId: $e');
      throw StorageException(message: 'Failed to remove prekey: $e');
    }
  }

  /// Gets all stored prekey IDs
  Future<List<int>> getAllPreKeyIds() async {
    try {
      return _preKeyBox.keys.cast<int>().toList();
    } catch (e) {
      SignalLogger.error('Failed to get all prekey IDs: $e');
      throw StorageException(message: 'Failed to get all prekey IDs: $e');
    }
  }

  /// Gets all stored prekeys (useful for debugging and management)
  Future<List<HivePreKeyRecord>> getAllPreKeys() async {
    try {
      return _preKeyBox.values.toList();
    } catch (e) {
      SignalLogger.error('Failed to get all prekeys: $e');
      throw StorageException(message: 'Failed to get all prekeys: $e');
    }
  }

  /// Cleans up old prekeys based on creation date
  Future<int> cleanupOldPreKeys({Duration? olderThan}) async {
    try {
      olderThan ??= const Duration(days: 30);
      final cutoffDate = DateTime.now().subtract(olderThan);
      
      final keysToDelete = <int>[];
      
      for (final entry in _preKeyBox.toMap().entries) {
        if (entry.value.created.isBefore(cutoffDate)) {
          keysToDelete.add(entry.key);
        }
      }
      
      await _preKeyBox.deleteAll(keysToDelete);
      SignalLogger.info('Cleaned up ${keysToDelete.length} old prekeys');
      return keysToDelete.length;
    } catch (e) {
      SignalLogger.error('Failed to cleanup old prekeys: $e');
      throw StorageException(message: 'Failed to cleanup old prekeys: $e');
    }
  }

  /// Gets the count of stored prekeys
  int get preKeyCount => _preKeyBox.length;

  /// Checks if the store is initialized
  bool get isInitialized => _preKeyBox.isOpen;

  /// Gets prekeys within a specific ID range
  Future<List<HivePreKeyRecord>> getPreKeysInRange(int minId, int maxId) async {
    try {
      final preKeysInRange = <HivePreKeyRecord>[];
      
      for (final entry in _preKeyBox.toMap().entries) {
        if (entry.key >= minId && entry.key <= maxId) {
          preKeysInRange.add(entry.value);
        }
      }
      
      SignalLogger.debug('Found ${preKeysInRange.length} prekeys in range $minId-$maxId');
      return preKeysInRange;
    } catch (e) {
      SignalLogger.error('Failed to get prekeys in range $minId-$maxId: $e');
      throw StorageException(message: 'Failed to get prekeys in range: $e');
    }
  }

  /// Removes prekeys in batch
  Future<void> removePreKeys(List<int> preKeyIds) async {
    try {
      await _preKeyBox.deleteAll(preKeyIds);
      SignalLogger.debug('Removed ${preKeyIds.length} prekeys in batch');
    } catch (e) {
      SignalLogger.error('Failed to remove prekeys in batch: $e');
      throw StorageException(message: 'Failed to remove prekeys in batch: $e');
    }
  }

  /// Clear all prekeys from storage
  Future<void> clearAllPreKeys() async {
    try {
      await _preKeyBox.clear();
      SignalLogger.info('Cleared all prekeys from storage');
    } catch (e) {
      SignalLogger.error('Failed to clear all prekeys: $e');
      throw StorageException(message: 'Failed to clear all prekeys: $e');
    }
  }

  /// Get the total count of stored prekeys
  Future<int> getPreKeyCount() async {
    try {
      return _preKeyBox.length;
    } catch (e) {
      SignalLogger.error('Failed to get prekey count: $e');
      return 0;
    }
  }
}
