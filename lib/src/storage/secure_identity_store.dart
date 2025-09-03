import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../utils/error_handler.dart';
import '../utils/logger.dart';

/// Secure storage keys used by the package
class SecureStorageKeys {
  static const String identityPrivateKey = 'signal_identity_private_key';
  static const String identityPublicKey = 'signal_identity_public_key';
  static const String registrationId = 'signal_registration_id';
  static const String currentUserId = 'signal_current_user_id';
  static const String currentDeviceId = 'signal_current_device_id';
  static const String deviceIdSalt = 'signal_device_id_salt';
}

/// Device ID manager for generating consistent device identifiers
class SecureDeviceIdManager {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Generate or retrieve consistent device ID for the given user
  static Future<String> getDeviceId(String userId) async {
    try {
      // Check if device ID already exists
      final existingId = await _secureStorage.read(key: SecureStorageKeys.currentDeviceId);
      if (existingId != null && existingId.isNotEmpty) {
        SignalLogger.debug('Retrieved existing device ID', component: 'SecureDeviceIdManager');
        return existingId;
      }

      // Generate new device ID
      final deviceId = await _generateDeviceId(userId);
      
      // Store the generated device ID
      await _secureStorage.write(
        key: SecureStorageKeys.currentDeviceId,
        value: deviceId,
      );
      
      SignalLogger.info('Generated new device ID: $deviceId', component: 'SecureDeviceIdManager');
      return deviceId;
    } catch (error, stackTrace) {
      ErrorHandler.handleError(error, stackTrace, context: 'SecureDeviceIdManager.getDeviceId');
    }
  }

  /// Generate a new device ID based on platform characteristics
  static Future<String> _generateDeviceId(String userId) async {
    try {
      final platformId = await _getPlatformIdentifier();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = _generateSecureRandom(8);
      
      // Format: userId_device_platformHash_timestamp_random
      return '${userId}_device_${platformId}_${timestamp}_$random';
    } catch (error, stackTrace) {
      ErrorHandler.handleError(error, stackTrace, context: 'SecureDeviceIdManager._generateDeviceId');
    }
  }

  /// Get platform-specific device identifier
  static Future<String> _getPlatformIdentifier() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        final deviceData = '${androidInfo.model}_${androidInfo.device}_${androidInfo.id}';
        return _hashString(deviceData).substring(0, 8);
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        final deviceData = '${iosInfo.model}_${iosInfo.identifierForVendor ?? 'unknown'}';
        return _hashString(deviceData).substring(0, 8);
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        final deviceData = '${windowsInfo.computerName}_${windowsInfo.systemMemoryInMegabytes}';
        return _hashString(deviceData).substring(0, 8);
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        final deviceData = '${macInfo.model}_${macInfo.systemGUID ?? 'unknown'}';
        return _hashString(deviceData).substring(0, 8);
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        final deviceData = '${linuxInfo.name}_${linuxInfo.machineId ?? 'unknown'}';
        return _hashString(deviceData).substring(0, 8);
      } else {
        // Fallback for other platforms (like web)
        return '${Platform.operatingSystem}_${_generateSecureRandom(8)}';
      }
    } catch (error) {
      SignalLogger.warning('Failed to get platform identifier, using fallback', 
                          component: 'SecureDeviceIdManager', error: error);
      return '${Platform.operatingSystem}_${_generateSecureRandom(8)}';
    }
  }

  /// Generate cryptographically secure random string
  static String _generateSecureRandom(int length) {
    final random = List<int>.generate(length, (i) => 
        DateTime.now().millisecondsSinceEpoch.hashCode % 256);
    return base64Url.encode(random).substring(0, length);
  }

  /// Hash a string using SHA-256
  static String _hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Clear stored device ID (for testing or reset purposes)
  static Future<void> clearDeviceId() async {
    await _secureStorage.delete(key: SecureStorageKeys.currentDeviceId);
    SignalLogger.info('Cleared stored device ID', component: 'SecureDeviceIdManager');
  }
}

/// Secure storage wrapper for identity keys and sensitive data
class SecureIdentityStore {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Store identity private key
  static Future<void> storeIdentityPrivateKey(Uint8List privateKey) async {
    try {
      final encoded = base64.encode(privateKey);
      await _secureStorage.write(
        key: SecureStorageKeys.identityPrivateKey,
        value: encoded,
      );
      SignalLogger.debug('Stored identity private key', component: 'SecureIdentityStore');
    } catch (error) {
      throw ErrorHandler.createStorageException(error, context: 'storeIdentityPrivateKey');
    }
  }

  /// Retrieve identity private key
  static Future<Uint8List?> getIdentityPrivateKey() async {
    try {
      final encoded = await _secureStorage.read(key: SecureStorageKeys.identityPrivateKey);
      if (encoded == null) return null;
      
      return base64.decode(encoded);
    } catch (error) {
      throw ErrorHandler.createStorageException(error, context: 'getIdentityPrivateKey');
    }
  }

  /// Store identity public key
  static Future<void> storeIdentityPublicKey(Uint8List publicKey) async {
    try {
      final encoded = base64.encode(publicKey);
      await _secureStorage.write(
        key: SecureStorageKeys.identityPublicKey,
        value: encoded,
      );
      SignalLogger.debug('Stored identity public key', component: 'SecureIdentityStore');
    } catch (error) {
      throw ErrorHandler.createStorageException(error, context: 'storeIdentityPublicKey');
    }
  }

  /// Retrieve identity public key
  static Future<Uint8List?> getIdentityPublicKey() async {
    try {
      final encoded = await _secureStorage.read(key: SecureStorageKeys.identityPublicKey);
      if (encoded == null) return null;
      
      return base64.decode(encoded);
    } catch (error) {
      throw ErrorHandler.createStorageException(error, context: 'getIdentityPublicKey');
    }
  }

  /// Store registration ID
  static Future<void> storeRegistrationId(int registrationId) async {
    try {
      await _secureStorage.write(
        key: SecureStorageKeys.registrationId,
        value: registrationId.toString(),
      );
      SignalLogger.debug('Stored registration ID', component: 'SecureIdentityStore');
    } catch (error) {
      throw ErrorHandler.createStorageException(error, context: 'storeRegistrationId');
    }
  }

  /// Retrieve registration ID
  static Future<int?> getRegistrationId() async {
    try {
      final value = await _secureStorage.read(key: SecureStorageKeys.registrationId);
      if (value == null) return null;
      
      return int.parse(value);
    } catch (error) {
      throw ErrorHandler.createStorageException(error, context: 'getRegistrationId');
    }
  }

  /// Store current user ID
  static Future<void> storeCurrentUserId(String userId) async {
    try {
      await _secureStorage.write(
        key: SecureStorageKeys.currentUserId,
        value: userId,
      );
      SignalLogger.debug('Stored current user ID', component: 'SecureIdentityStore');
    } catch (error) {
      throw ErrorHandler.createStorageException(error, context: 'storeCurrentUserId');
    }
  }

  /// Retrieve current user ID
  static Future<String?> getCurrentUserId() async {
    try {
      return await _secureStorage.read(key: SecureStorageKeys.currentUserId);
    } catch (error) {
      throw ErrorHandler.createStorageException(error, context: 'getCurrentUserId');
    }
  }

  /// Clear all stored identity data
  static Future<void> clearAll() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: SecureStorageKeys.identityPrivateKey),
        _secureStorage.delete(key: SecureStorageKeys.identityPublicKey),
        _secureStorage.delete(key: SecureStorageKeys.registrationId),
        _secureStorage.delete(key: SecureStorageKeys.currentUserId),
      ]);
      
      SignalLogger.info('Cleared all secure storage data', component: 'SecureIdentityStore');
    } catch (error) {
      throw ErrorHandler.createStorageException(error, context: 'clearAll');
    }
  }

  /// Check if identity keys are stored
  static Future<bool> hasIdentityKeys() async {
    try {
      final privateKey = await _secureStorage.read(key: SecureStorageKeys.identityPrivateKey);
      final publicKey = await _secureStorage.read(key: SecureStorageKeys.identityPublicKey);
      return privateKey != null && publicKey != null;
    } catch (error) {
      throw ErrorHandler.createStorageException(error, context: 'hasIdentityKeys');
    }
  }
}
