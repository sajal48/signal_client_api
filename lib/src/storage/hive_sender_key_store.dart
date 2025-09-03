/// Sender key store implementation using Hive for persistent storage (group messaging)
library;

import 'package:hive/hive.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import '../exceptions/signal_exceptions.dart';
import '../utils/logger.dart';
import 'hive_models.dart';
import 'hive_registry.dart';

/// Hive-based implementation of SenderKeyStore for persistent sender key storage
class HiveSenderKeyStore implements SenderKeyStore {
  static const String _boxName = 'signal_sender_keys';
  late Box<HiveSenderKeyRecord> _senderKeyBox;

  /// Initializes the Hive sender key store
  Future<void> initialize() async {
    try {
      // Ensure Hive adapters are registered before opening boxes
      HiveRegistry.registerAdapters();
      
      _senderKeyBox = await Hive.openBox<HiveSenderKeyRecord>(_boxName);
      SignalLogger.info('HiveSenderKeyStore initialized successfully');
    } catch (e) {
      SignalLogger.error('Failed to initialize HiveSenderKeyStore: $e');
      throw StorageException(message: 'Failed to initialize sender key store: $e');
    }
  }

  /// Closes the sender key store and cleans up resources
  Future<void> close() async {
    try {
      await _senderKeyBox.close();
      SignalLogger.info('HiveSenderKeyStore closed successfully');
    } catch (e) {
      SignalLogger.error('Failed to close HiveSenderKeyStore: $e');
      throw StorageException(message: 'Failed to close sender key store: $e');
    }
  }

  @override
  Future<SenderKeyRecord> loadSenderKey(SenderKeyName senderKeyName) async {
    try {
      final key = _senderKeyNameToKey(senderKeyName);
      final hiveRecord = _senderKeyBox.get(key);
      
      if (hiveRecord == null) {
        SignalLogger.debug('SenderKey not found for $senderKeyName, creating new record');
        return SenderKeyRecord();
      }

      SignalLogger.debug('SenderKey loaded for $senderKeyName');
      // Deserialize using the correct libsignal API
      return SenderKeyRecord.fromSerialized(hiveRecord.keyData);
    } catch (e) {
      if (e is UnimplementedError) rethrow;
      SignalLogger.error('Failed to load sender key for $senderKeyName: $e');
      throw StorageException(message: 'Failed to load sender key: $e');
    }
  }

  @override
  Future<void> storeSenderKey(SenderKeyName senderKeyName, SenderKeyRecord record) async {
    try {
      final key = _senderKeyNameToKey(senderKeyName);
      final keyData = record.serialize();
      
      final hiveRecord = HiveSenderKeyRecord(
        groupId: senderKeyName.groupId,
        senderId: _senderAddressToString(senderKeyName.sender),
        keyData: keyData,
        created: DateTime.now(),
      );
      
      await _senderKeyBox.put(key, hiveRecord);
      SignalLogger.debug('SenderKey stored for $senderKeyName');
    } catch (e) {
      SignalLogger.error('Failed to store sender key for $senderKeyName: $e');
      throw StorageException(message: 'Failed to store sender key: $e');
    }
  }

  /// Converts a SenderKeyName to a string key for storage
  String _senderKeyNameToKey(SenderKeyName senderKeyName) {
    final senderAddress = _senderAddressToString(senderKeyName.sender);
    return '${senderKeyName.groupId}:$senderAddress';
  }

  /// Converts a SignalProtocolAddress to a string
  String _senderAddressToString(SignalProtocolAddress address) {
    return '${address.getName()}.${address.getDeviceId()}';
  }

  /// Gets all stored sender keys for a specific group
  Future<List<HiveSenderKeyRecord>> getSenderKeysForGroup(String groupId) async {
    try {
      final groupKeys = <HiveSenderKeyRecord>[];
      
      for (final record in _senderKeyBox.values) {
        if (record.groupId == groupId) {
          groupKeys.add(record);
        }
      }
      
      SignalLogger.debug('Found ${groupKeys.length} sender keys for group $groupId');
      return groupKeys;
    } catch (e) {
      SignalLogger.error('Failed to get sender keys for group $groupId: $e');
      throw StorageException(message: 'Failed to get sender keys for group: $e');
    }
  }

  /// Gets all stored sender keys for a specific sender
  Future<List<HiveSenderKeyRecord>> getSenderKeysForSender(String senderId) async {
    try {
      final senderKeys = <HiveSenderKeyRecord>[];
      
      for (final record in _senderKeyBox.values) {
        if (record.senderId == senderId) {
          senderKeys.add(record);
        }
      }
      
      SignalLogger.debug('Found ${senderKeys.length} sender keys for sender $senderId');
      return senderKeys;
    } catch (e) {
      SignalLogger.error('Failed to get sender keys for sender $senderId: $e');
      throw StorageException(message: 'Failed to get sender keys for sender: $e');
    }
  }

  /// Removes all sender keys for a specific group
  Future<void> removeSenderKeysForGroup(String groupId) async {
    try {
      final keysToDelete = <String>[];
      
      for (final entry in _senderKeyBox.toMap().entries) {
        if (entry.value.groupId == groupId) {
          keysToDelete.add(entry.key);
        }
      }
      
      await _senderKeyBox.deleteAll(keysToDelete);
      SignalLogger.debug('Removed ${keysToDelete.length} sender keys for group $groupId');
    } catch (e) {
      SignalLogger.error('Failed to remove sender keys for group $groupId: $e');
      throw StorageException(message: 'Failed to remove sender keys for group: $e');
    }
  }

  /// Removes all sender keys for a specific sender
  Future<void> removeSenderKeysForSender(String senderId) async {
    try {
      final keysToDelete = <String>[];
      
      for (final entry in _senderKeyBox.toMap().entries) {
        if (entry.value.senderId == senderId) {
          keysToDelete.add(entry.key);
        }
      }
      
      await _senderKeyBox.deleteAll(keysToDelete);
      SignalLogger.debug('Removed ${keysToDelete.length} sender keys for sender $senderId');
    } catch (e) {
      SignalLogger.error('Failed to remove sender keys for sender $senderId: $e');
      throw StorageException(message: 'Failed to remove sender keys for sender: $e');
    }
  }

  /// Gets all stored sender keys (useful for debugging and cleanup)
  Future<List<HiveSenderKeyRecord>> getAllSenderKeys() async {
    try {
      return _senderKeyBox.values.toList();
    } catch (e) {
      SignalLogger.error('Failed to get all sender keys: $e');
      throw StorageException(message: 'Failed to get all sender keys: $e');
    }
  }

  /// Cleans up old sender keys based on creation date
  Future<int> cleanupOldSenderKeys({Duration? olderThan}) async {
    try {
      olderThan ??= const Duration(days: 30);
      final cutoffDate = DateTime.now().subtract(olderThan);
      
      final keysToDelete = <String>[];
      
      for (final entry in _senderKeyBox.toMap().entries) {
        if (entry.value.created.isBefore(cutoffDate)) {
          keysToDelete.add(entry.key);
        }
      }
      
      await _senderKeyBox.deleteAll(keysToDelete);
      SignalLogger.info('Cleaned up ${keysToDelete.length} old sender keys');
      return keysToDelete.length;
    } catch (e) {
      SignalLogger.error('Failed to cleanup old sender keys: $e');
      throw StorageException(message: 'Failed to cleanup old sender keys: $e');
    }
  }

  /// Gets the count of stored sender keys
  int get senderKeyCount => _senderKeyBox.length;

  /// Checks if the store is initialized
  bool get isInitialized => _senderKeyBox.isOpen;

  /// Gets all unique group IDs that have sender keys
  Future<List<String>> getAllGroupIds() async {
    try {
      final groupIds = <String>{};
      
      for (final record in _senderKeyBox.values) {
        groupIds.add(record.groupId);
      }
      
      final uniqueGroupIds = groupIds.toList();
      SignalLogger.debug('Found ${uniqueGroupIds.length} unique groups with sender keys');
      return uniqueGroupIds;
    } catch (e) {
      SignalLogger.error('Failed to get all group IDs: $e');
      throw StorageException(message: 'Failed to get all group IDs: $e');
    }
  }

  /// Gets all unique sender IDs that have sender keys
  Future<List<String>> getAllSenderIds() async {
    try {
      final senderIds = <String>{};
      
      for (final record in _senderKeyBox.values) {
        senderIds.add(record.senderId);
      }
      
      final uniqueSenderIds = senderIds.toList();
      SignalLogger.debug('Found ${uniqueSenderIds.length} unique senders with keys');
      return uniqueSenderIds;
    } catch (e) {
      SignalLogger.error('Failed to get all sender IDs: $e');
      throw StorageException(message: 'Failed to get all sender IDs: $e');
    }
  }

  /// Check if a sender key exists for the given SenderKeyName
  Future<bool> hasSenderKey(SenderKeyName senderKeyName) async {
    try {
      final key = _senderKeyNameToKey(senderKeyName);
      final exists = _senderKeyBox.containsKey(key);
      SignalLogger.debug('Sender key exists for $senderKeyName: $exists');
      return exists;
    } catch (e) {
      SignalLogger.error('Failed to check if sender key exists for $senderKeyName: $e');
      return false;
    }
  }

  /// Clear all sender keys from storage
  Future<void> clearAllSenderKeys() async {
    try {
      await _senderKeyBox.clear();
      SignalLogger.info('Cleared all sender keys from storage');
    } catch (e) {
      SignalLogger.error('Failed to clear all sender keys: $e');
      throw StorageException(message: 'Failed to clear all sender keys: $e');
    }
  }

  /// Get the total count of stored sender keys
  Future<int> getSenderKeyCount() async {
    try {
      return _senderKeyBox.length;
    } catch (e) {
      SignalLogger.error('Failed to get sender key count: $e');
      return 0;
    }
  }
}
