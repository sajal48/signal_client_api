/// Signal Protocol custom exceptions
library;

/// Base exception for Signal Protocol operations
abstract class SignalException implements Exception {
  const SignalException({
    required this.message,
    this.code,
    this.details,
  });

  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  @override
  String toString() {
    var result = 'SignalException: $message';
    if (code != null) result += ' (Code: $code)';
    if (details != null) result += ' Details: $details';
    return result;
  }
}

/// Exception thrown when validation fails
class ValidationException extends SignalException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Exception thrown when storage operations fail
class StorageException extends SignalException {
  const StorageException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Exception thrown when cryptographic operations fail
class CryptographicException extends SignalException {
  const CryptographicException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Exception thrown when Firebase operations fail
class FirebaseException extends SignalException {
  const FirebaseException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Exception thrown when initialization fails
class InitializationException extends SignalException {
  const InitializationException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Exception thrown when key operations fail
class KeyException extends SignalException {
  const KeyException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Exception thrown when session operations fail
class SessionException extends SignalException {
  const SessionException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Exception thrown when device operations fail
class DeviceException extends SignalException {
  const DeviceException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Exception thrown when serialization/deserialization fails
class SerializationException extends SignalException {
  const SerializationException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Exception thrown when network operations fail
class NetworkException extends SignalException {
  const NetworkException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Exception thrown when security operations fail
class SecurityException extends SignalException {
  const SecurityException({
    required super.message,
    super.code,
    super.details,
  });
}
