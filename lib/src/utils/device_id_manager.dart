/// Device ID management utility for Signal Protocol.
/// 
/// Handles generation and storage of unique device identifiers
/// using secure storage to persist across app restarts.
library;

import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../exceptions/signal_exceptions.dart';
import 'logger.dart';

/// Manages device ID generation and storage.
/// 
/// Device IDs are used to identify different devices for the same user
/// in the Signal Protocol. Each device must have a unique ID to
/// maintain separate cryptographic sessions.
class DeviceIdManager {
  static const String _deviceIdKey = 'signal_device_id';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  /// Get the existing device ID or create a new one if none exists.
  /// 
  /// Returns a unique device ID that persists across app restarts.
  /// Device IDs are positive integers starting from 1.
  /// 
  /// Throws:
  /// - [SignalStorageException] if device ID cannot be generated or stored
  static Future<int> getOrCreateDeviceId() async {
    try {
      SignalLogger.debug('Getting or creating device ID');
      
      // Try to get existing device ID
      final existingId = await _secureStorage.read(key: _deviceIdKey);
      if (existingId != null) {
        final deviceId = int.tryParse(existingId);
        if (deviceId != null && deviceId > 0) {
          SignalLogger.debug('Found existing device ID: $deviceId');
          return deviceId;
        }
      }
      
      // Generate new device ID
      final newDeviceId = _generateDeviceId();
      await _secureStorage.write(key: _deviceIdKey, value: newDeviceId.toString());
      
      SignalLogger.info('Generated new device ID: $newDeviceId');
      return newDeviceId;
      
    } catch (e) {
      SignalLogger.error('Failed to get or create device ID: $e');
      throw StorageException(message: 'Device ID management failed: $e');
    }
  }
  
  /// Get the current device ID if it exists.
  /// 
  /// Returns null if no device ID has been generated yet.
  /// 
  /// Throws:
  /// - [SignalStorageException] if device ID cannot be retrieved
  static Future<int?> getCurrentDeviceId() async {
    try {
      final existingId = await _secureStorage.read(key: _deviceIdKey);
      if (existingId != null) {
        return int.tryParse(existingId);
      }
      return null;
    } catch (e) {
      SignalLogger.error('Failed to get current device ID: $e');
      throw StorageException(message: 'Device ID retrieval failed: $e');
    }
  }
  
  /// Reset the device ID by generating a new one.
  /// 
  /// This will cause the device to be treated as a new device
  /// and will require re-establishing all sessions.
  /// 
  /// Use with caution as this can break existing encrypted conversations.
  /// 
  /// Throws:
  /// - [SignalStorageException] if device ID cannot be reset
  static Future<int> resetDeviceId() async {
    try {
      SignalLogger.warning('Resetting device ID');
      
      final newDeviceId = _generateDeviceId();
      await _secureStorage.write(key: _deviceIdKey, value: newDeviceId.toString());
      
      SignalLogger.info('Device ID reset to: $newDeviceId');
      return newDeviceId;
      
    } catch (e) {
      SignalLogger.error('Failed to reset device ID: $e');
      throw StorageException(message: 'Device ID reset failed: $e');
    }
  }
  
  /// Clear the stored device ID.
  /// 
  /// This will cause a new device ID to be generated on the next
  /// call to [getOrCreateDeviceId].
  /// 
  /// Throws:
  /// - [SignalStorageException] if device ID cannot be cleared
  static Future<void> clearDeviceId() async {
    try {
      SignalLogger.debug('Clearing stored device ID');
      await _secureStorage.delete(key: _deviceIdKey);
      SignalLogger.info('Device ID cleared');
    } catch (e) {
      SignalLogger.error('Failed to clear device ID: $e');
      throw StorageException(message: 'Device ID clearing failed: $e');
    }
  }
  
  /// Generate a new random device ID.
  /// 
  /// Device IDs are positive integers in the range 1-2147483647.
  /// This range avoids conflicts with special device ID values
  /// and ensures compatibility with the Signal Protocol.
  static int _generateDeviceId() {
    final random = Random.secure();
    // Generate a random positive integer (1 to 2^31 - 1)
    return random.nextInt(2147483647) + 1;
  }
}
