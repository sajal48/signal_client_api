/// Session store implementation using Hive for persistent storage
library;

import 'package:hive/hive.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import '../exceptions/signal_exceptions.dart';
import '../utils/logger.dart';
import '../utils/validators.dart';
import 'hive_models.dart';
import 'hive_registry.dart';

/// Hive-based implementation of SessionStore for persistent session storage
class HiveSessionStore implements SessionStore {
  static const String _boxName = 'signal_sessions';
  late Box<HiveSessionRecord> _sessionBox;

  /// Initializes the Hive session store
  Future<void> initialize() async {
    try {
      // Ensure Hive adapters are registered before opening boxes
      HiveRegistry.registerAdapters();
      
      _sessionBox = await Hive.openBox<HiveSessionRecord>(_boxName);
      SignalLogger.info('HiveSessionStore initialized successfully');
    } catch (e) {
      SignalLogger.error('Failed to initialize HiveSessionStore: $e');
      throw StorageException(message: 'Failed to initialize session store: $e');
    }
  }

  /// Closes the session store and cleans up resources
  Future<void> close() async {
    try {
      await _sessionBox.close();
      SignalLogger.info('HiveSessionStore closed successfully');
    } catch (e) {
      SignalLogger.error('Failed to close HiveSessionStore: $e');
      throw StorageException(message: 'Failed to close session store: $e');
    }
  }

  @override
  Future<SessionRecord> loadSession(SignalProtocolAddress address) async {
    try {
      final addressKey = _addressToKey(address);
      final hiveRecord = _sessionBox.get(addressKey);
      
      if (hiveRecord == null) {
        SignalLogger.debug('No session found for address: $address, creating new session');
        return SessionRecord();
      }

      SignalLogger.debug('Session loaded for address: $address');
      return SessionRecord.fromSerialized(hiveRecord.sessionData);
    } catch (e) {
      SignalLogger.error('Failed to load session for $address: $e');
      throw StorageException(message: 'Failed to load session: $e');
    }
  }

  @override
  Future<List<int>> getSubDeviceSessions(String name) async {
    try {
      Validators.validateUserId(name);
      
      final subDeviceIds = <int>[];
      
      for (final key in _sessionBox.keys) {
        if (key is String && key.startsWith('$name.')) {
          final parts = key.split('.');
          if (parts.length == 2) {
            final deviceId = int.tryParse(parts[1]);
            if (deviceId != null) {
              subDeviceIds.add(deviceId);
            }
          }
        }
      }
      
      SignalLogger.debug('Found ${subDeviceIds.length} sub-device sessions for $name');
      return subDeviceIds;
    } catch (e) {
      SignalLogger.error('Failed to get sub-device sessions for $name: $e');
      throw StorageException(message: 'Failed to get sub-device sessions: $e');
    }
  }

  @override
  Future<void> storeSession(SignalProtocolAddress address, SessionRecord record) async {
    try {
      final addressKey = _addressToKey(address);
      final sessionData = record.serialize();
      
      final hiveRecord = HiveSessionRecord(
        address: addressKey,
        sessionData: sessionData,
        lastUsed: DateTime.now(),
      );
      
      await _sessionBox.put(addressKey, hiveRecord);
      SignalLogger.debug('Session stored for address: $address');
    } catch (e) {
      SignalLogger.error('Failed to store session for $address: $e');
      throw StorageException(message: 'Failed to store session: $e');
    }
  }

  @override
  Future<bool> containsSession(SignalProtocolAddress address) async {
    try {
      final addressKey = _addressToKey(address);
      final exists = _sessionBox.containsKey(addressKey);
      SignalLogger.debug('Session exists for $address: $exists');
      return exists;
    } catch (e) {
      SignalLogger.error('Failed to check session existence for $address: $e');
      throw StorageException(message: 'Failed to check session existence: $e');
    }
  }

  @override
  Future<void> deleteSession(SignalProtocolAddress address) async {
    try {
      final addressKey = _addressToKey(address);
      await _sessionBox.delete(addressKey);
      SignalLogger.debug('Session deleted for address: $address');
    } catch (e) {
      SignalLogger.error('Failed to delete session for $address: $e');
      throw StorageException(message: 'Failed to delete session: $e');
    }
  }

  @override
  Future<void> deleteAllSessions(String name) async {
    try {
      Validators.validateUserId(name);
      
      final keysToDelete = <String>[];
      
      for (final key in _sessionBox.keys) {
        if (key is String && (key == name || key.startsWith('$name.'))) {
          keysToDelete.add(key);
        }
      }
      
      await _sessionBox.deleteAll(keysToDelete);
      SignalLogger.debug('Deleted ${keysToDelete.length} sessions for $name');
    } catch (e) {
      SignalLogger.error('Failed to delete all sessions for $name: $e');
      throw StorageException(message: 'Failed to delete all sessions: $e');
    }
  }

  /// Converts a SignalProtocolAddress to a string key for storage
  String _addressToKey(SignalProtocolAddress address) {
    return '${address.getName()}.${address.getDeviceId()}';
  }

  /// Gets all stored sessions (useful for debugging and cleanup)
  Future<List<HiveSessionRecord>> getAllSessions() async {
    try {
      return _sessionBox.values.toList();
    } catch (e) {
      SignalLogger.error('Failed to get all sessions: $e');
      throw StorageException(message: 'Failed to get all sessions: $e');
    }
  }

  /// Cleans up old sessions based on last used timestamp
  Future<int> cleanupOldSessions({Duration? olderThan}) async {
    try {
      olderThan ??= const Duration(days: 30);
      final cutoffDate = DateTime.now().subtract(olderThan);
      
      final keysToDelete = <String>[];
      
      for (final entry in _sessionBox.toMap().entries) {
        if (entry.value.lastUsed.isBefore(cutoffDate)) {
          keysToDelete.add(entry.key);
        }
      }
      
      await _sessionBox.deleteAll(keysToDelete);
      SignalLogger.info('Cleaned up ${keysToDelete.length} old sessions');
      return keysToDelete.length;
    } catch (e) {
      SignalLogger.error('Failed to cleanup old sessions: $e');
      throw StorageException(message: 'Failed to cleanup old sessions: $e');
    }
  }

  /// Gets the total number of stored sessions
  int get sessionCount => _sessionBox.length;

  /// Checks if the store is initialized
  bool get isInitialized => _sessionBox.isOpen;

  /// Clear all sessions from storage
  Future<void> clearAllSessions() async {
    try {
      await _sessionBox.clear();
      SignalLogger.info('Cleared all sessions from storage');
    } catch (e) {
      SignalLogger.error('Failed to clear all sessions: $e');
      throw StorageException(message: 'Failed to clear all sessions: $e');
    }
  }
}
