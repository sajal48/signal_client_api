import '../exceptions/signal_exceptions.dart';

/// Utility class for input validation
class Validators {
  Validators._();
  
  /// Validates that a user ID is not null or empty
  static void validateUserId(String? userId) {
    if (userId == null || userId.trim().isEmpty) {
      throw const ValidationException(
        message: 'User ID cannot be null or empty',
        code: 'INVALID_USER_ID',
      );
    }
    
    if (userId.length > 255) {
      throw const ValidationException(
        message: 'User ID cannot be longer than 255 characters',
        code: 'USER_ID_TOO_LONG',
      );
    }
    
    // Check for invalid characters
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(userId)) {
      throw const ValidationException(
        message: 'User ID can only contain alphanumeric characters, dots, underscores, and hyphens',
        code: 'INVALID_USER_ID_CHARACTERS',
      );
    }
  }
  
  /// Validates that a device ID is valid
  static void validateDeviceId(int? deviceId) {
    if (deviceId == null) {
      throw const ValidationException(
        message: 'Device ID cannot be null',
        code: 'INVALID_DEVICE_ID',
      );
    }
    
    if (deviceId < 0) {
      throw const ValidationException(
        message: 'Device ID cannot be negative',
        code: 'INVALID_DEVICE_ID',
      );
    }
    
    if (deviceId > 0x7FFFFFFF) {
      throw const ValidationException(
        message: 'Device ID cannot exceed maximum value',
        code: 'DEVICE_ID_TOO_LARGE',
      );
    }
  }
  
  /// Validates that a message is not null or empty
  static void validateMessage(String? message) {
    if (message == null || message.isEmpty) {
      throw const ValidationException(
        message: 'Message cannot be null or empty',
        code: 'INVALID_MESSAGE',
      );
    }
    
    // Check message size limit (1MB)
    if (message.length > 1024 * 1024) {
      throw const ValidationException(
        message: 'Message cannot be larger than 1MB',
        code: 'MESSAGE_TOO_LARGE',
      );
    }
  }
  
  /// Validates that a group ID is not null or empty
  static void validateGroupId(String? groupId) {
    if (groupId == null || groupId.trim().isEmpty) {
      throw const ValidationException(
        message: 'Group ID cannot be null or empty',
        code: 'INVALID_GROUP_ID',
      );
    }
    
    if (groupId.length > 255) {
      throw const ValidationException(
        message: 'Group ID cannot be longer than 255 characters',
        code: 'GROUP_ID_TOO_LONG',
      );
    }
    
    // Check for invalid characters
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(groupId)) {
      throw const ValidationException(
        message: 'Group ID can only contain alphanumeric characters, dots, underscores, and hyphens',
        code: 'INVALID_GROUP_ID_CHARACTERS',
      );
    }
  }
  
  /// Validates Firebase database URL
  static void validateFirebaseUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      throw const ValidationException(
        message: 'Firebase URL cannot be null or empty',
        code: 'INVALID_FIREBASE_URL',
      );
    }
    
    // Basic URL validation
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAbsolutePath) {
      throw const ValidationException(
        message: 'Firebase URL must be a valid URL',
        code: 'INVALID_FIREBASE_URL_FORMAT',
      );
    }
  }
}
