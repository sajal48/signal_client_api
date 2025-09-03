import 'dart:async';

import '../exceptions/signal_exceptions.dart';
import 'logger.dart';

/// Error handler utility for the Signal Protocol package
class ErrorHandler {
  ErrorHandler._();
  
  /// Handles and wraps errors in appropriate Signal Protocol exceptions
  static Never handleError(Object error, StackTrace stackTrace, {String? context}) {
    final contextMessage = context != null ? ' in $context' : '';
    
    SignalLogger.error(
      'Error occurred$contextMessage: $error',
      error: error,
      stackTrace: stackTrace,
    );
    
    // If it's already a Signal exception, rethrow as-is
    if (error is SignalException) {
      throw error;
    }
    
    // Handle specific error types
    if (error is StateError || error is ArgumentError) {
      throw ValidationException(
        message: 'Invalid state or argument$contextMessage: ${error.toString()}',
      );
    }
    
    if (error is TimeoutException) {
      throw NetworkException(
        message: 'Operation timed out$contextMessage',
      );
    }
    
    if (error is FormatException) {
      throw SerializationException(
        message: 'Data format error$contextMessage: ${error.toString()}',
      );
    }
    
    // Default to generic exception
    throw CryptographicException(
      message: 'Unexpected error$contextMessage: ${error.toString()}',
    );
  }
  
  /// Creates a storage exception from an error
  static StorageException createStorageException(Object error, {String? context}) {
    final contextMessage = context != null ? ' in $context' : '';
    
    if (error is StorageException) {
      return error;
    }
    
    return StorageException(
      message: 'Storage operation failed$contextMessage: ${error.toString()}',
    );
  }
  
  /// Creates a cryptographic exception from an error
  static CryptographicException createCryptographicException(Object error, {String? context}) {
    final contextMessage = context != null ? ' in $context' : '';
    
    if (error is CryptographicException) {
      return error;
    }
    
    return CryptographicException(
      message: 'Cryptographic operation failed$contextMessage: ${error.toString()}',
    );
  }
  
  /// Creates a validation exception from an error
  static ValidationException createValidationException(Object error, {String? context}) {
    final contextMessage = context != null ? ' in $context' : '';
    
    if (error is ValidationException) {
      return error;
    }
    
    return ValidationException(
      message: 'Validation failed$contextMessage: ${error.toString()}',
    );
  }
  
  /// Creates a network exception from an error
  static NetworkException createNetworkException(Object error, {String? context}) {
    final contextMessage = context != null ? ' in $context' : '';
    
    if (error is NetworkException) {
      return error;
    }
    
    return NetworkException(
      message: 'Network operation failed$contextMessage: ${error.toString()}',
    );
  }
}
