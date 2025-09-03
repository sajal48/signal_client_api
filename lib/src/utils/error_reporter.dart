/// Advanced error handling and reporting for Signal Protocol operations
library;

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

import '../exceptions/signal_exceptions.dart';
import 'logger.dart';

/// Advanced error reporter with context and telemetry
class SignalErrorReporter {
  SignalErrorReporter._();
  static SignalErrorReporter? _instance;
  
  /// Get the singleton instance
  static SignalErrorReporter get instance {
    _instance ??= SignalErrorReporter._();
    return _instance!;
  }

  /// Device information for error context
  Map<String, dynamic>? _deviceInfo;
  
  /// App information for error context
  Map<String, String>? _appInfo;
  
  /// Error report listeners
  final List<ErrorReportListener> _listeners = [];

  /// Initialize the error reporter
  Future<void> initialize() async {
    try {
      await _loadDeviceInfo();
      await _loadAppInfo();
      SignalLogger.info('Error reporter initialized');
    } catch (e) {
      SignalLogger.warning('Failed to initialize error reporter: $e');
    }
  }

  /// Add an error report listener
  void addListener(ErrorReportListener listener) {
    _listeners.add(listener);
  }

  /// Remove an error report listener
  void removeListener(ErrorReportListener listener) {
    _listeners.remove(listener);
  }

  /// Report an error with context
  Future<void> reportError({
    required Object error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    ErrorSeverity severity = ErrorSeverity.error,
    String? userId,
    String? operation,
  }) async {
    try {
      final errorReport = await _createErrorReport(
        error: error,
        stackTrace: stackTrace,
        context: context,
        severity: severity,
        userId: userId,
        operation: operation,
      );

      // Log the error
      _logError(errorReport);

      // Notify listeners
      for (final listener in _listeners) {
        try {
          await listener.onErrorReport(errorReport);
        } catch (e) {
          SignalLogger.warning('Error report listener failed: $e');
        }
      }
    } catch (e) {
      SignalLogger.error('Failed to report error: $e');
    }
  }

  /// Report a validation error
  Future<void> reportValidationError({
    required String field,
    required String value,
    required String reason,
    Map<String, dynamic>? context,
  }) async {
    final error = ValidationException(
      message: 'Validation failed for $field: $reason',
      details: {
        'field': field,
        'value': value,
        'reason': reason,
      },
    );

    await reportError(
      error: error,
      context: {
        'type': 'validation_error',
        'field': field,
        'value': value,
        'reason': reason,
        ...?context,
      },
      severity: ErrorSeverity.warning,
    );
  }

  /// Report a network error
  Future<void> reportNetworkError({
    required Object error,
    required String endpoint,
    int? statusCode,
    Map<String, dynamic>? context,
  }) async {
    await reportError(
      error: error,
      context: {
        'type': 'network_error',
        'endpoint': endpoint,
        'status_code': statusCode,
        ...?context,
      },
      severity: ErrorSeverity.error,
      operation: 'network_request',
    );
  }

  /// Report a cryptographic error
  Future<void> reportCryptographicError({
    required Object error,
    required String operation,
    String? keyType,
    Map<String, dynamic>? context,
  }) async {
    await reportError(
      error: error,
      context: {
        'type': 'cryptographic_error',
        'operation': operation,
        'key_type': keyType,
        ...?context,
      },
      severity: ErrorSeverity.critical,
      operation: 'cryptographic_operation',
    );
  }

  /// Report a storage error
  Future<void> reportStorageError({
    required Object error,
    required String store,
    required String operation,
    Map<String, dynamic>? context,
  }) async {
    await reportError(
      error: error,
      context: {
        'type': 'storage_error',
        'store': store,
        'operation': operation,
        ...?context,
      },
      severity: ErrorSeverity.error,
      operation: 'storage_operation',
    );
  }

  /// Report a session error
  Future<void> reportSessionError({
    required Object error,
    required String userId,
    required int deviceId,
    required String operation,
    Map<String, dynamic>? context,
  }) async {
    await reportError(
      error: error,
      context: {
        'type': 'session_error',
        'target_user': userId,
        'target_device': deviceId,
        'operation': operation,
        ...?context,
      },
      severity: ErrorSeverity.error,
      userId: userId,
      operation: 'session_operation',
    );
  }

  /// Report a Firebase error
  Future<void> reportFirebaseError({
    required Object error,
    required String operation,
    String? path,
    Map<String, dynamic>? context,
  }) async {
    await reportError(
      error: error,
      context: {
        'type': 'firebase_error',
        'operation': operation,
        'path': path,
        ...?context,
      },
      severity: ErrorSeverity.error,
      operation: 'firebase_operation',
    );
  }

  /// Get error statistics
  ErrorStatistics getStatistics() {
    // This would typically be implemented with persistent storage
    // For now, return empty statistics
    return const ErrorStatistics(
      totalErrors: 0,
      errorsByType: {},
      errorsBySeverity: {},
      recentErrors: [],
    );
  }

  /// Load device information
  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceInfo = {
          'platform': 'android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdk_int': androidInfo.version.sdkInt,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'hardware': androidInfo.hardware,
          'is_physical_device': androidInfo.isPhysicalDevice,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceInfo = {
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'system_name': iosInfo.systemName,
          'system_version': iosInfo.systemVersion,
          'localized_model': iosInfo.localizedModel,
          'identifier_for_vendor': iosInfo.identifierForVendor,
          'is_physical_device': iosInfo.isPhysicalDevice,
        };
      } else {
        _deviceInfo = {
          'platform': Platform.operatingSystem,
          'version': Platform.operatingSystemVersion,
        };
      }
    } catch (e) {
      SignalLogger.warning('Failed to load device info: $e');
      _deviceInfo = {
        'platform': 'unknown',
        'error': e.toString(),
      };
    }
  }

  /// Load package information
  Future<void> _loadAppInfo() async {
    try {
      _appInfo = {
        'app_name': 'signal_protocol_flutter',
        'version': '0.0.1',
        'package_name': 'signal_protocol_flutter',
      };
    } catch (e) {
      SignalLogger.warning('Failed to load app info: $e');
    }
  }

  /// Create a comprehensive error report
  Future<ErrorReport> _createErrorReport({
    required Object error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    ErrorSeverity severity = ErrorSeverity.error,
    String? userId,
    String? operation,
  }) async {
    final now = DateTime.now();
    
    return ErrorReport(
      id: _generateErrorId(),
      timestamp: now,
      error: error,
      stackTrace: stackTrace,
      severity: severity,
      context: context ?? {},
      userId: userId,
      operation: operation,
      deviceInfo: _deviceInfo ?? {},
      packageInfo: _appInfo ?? {},
      errorType: _getErrorType(error),
      errorCategory: _getErrorCategory(error),
    );
  }

  /// Generate a unique error ID
  String _generateErrorId() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final random = timestamp.hashCode;
    return 'err_${timestamp}_$random';
  }

  /// Get error type from error object
  String _getErrorType(Object error) {
    if (error is SignalException) {
      return error.runtimeType.toString();
    } else if (error is Exception) {
      return error.runtimeType.toString();
    } else if (error is Error) {
      return error.runtimeType.toString();
    } else {
      return 'UnknownError';
    }
  }

  /// Get error category from error object
  ErrorCategory _getErrorCategory(Object error) {
    if (error is ValidationException) {
      return ErrorCategory.validation;
    } else if (error is NetworkException) {
      return ErrorCategory.network;
    } else if (error is CryptographicException) {
      return ErrorCategory.cryptographic;
    } else if (error is StorageException) {
      return ErrorCategory.storage;
    } else if (error is SessionException) {
      return ErrorCategory.session;
    } else if (error is KeyException) {
      return ErrorCategory.key;
    } else if (error is InitializationException) {
      return ErrorCategory.initialization;
    } else {
      return ErrorCategory.unknown;
    }
  }

  /// Log the error report
  void _logError(ErrorReport report) {
    final severity = report.severity;
    final message = 'Error Report [${report.id}]: ${report.error}';
    
    switch (severity) {
      case ErrorSeverity.debug:
        SignalLogger.debug(message);
        break;
      case ErrorSeverity.info:
        SignalLogger.info(message);
        break;
      case ErrorSeverity.warning:
        SignalLogger.warning(message);
        break;
      case ErrorSeverity.error:
        SignalLogger.error(message);
        break;
      case ErrorSeverity.critical:
        SignalLogger.error('CRITICAL: $message');
        break;
    }
  }
}

/// Error report data structure
class ErrorReport {
  const ErrorReport({
    required this.id,
    required this.timestamp,
    required this.error,
    required this.severity,
    required this.context,
    required this.deviceInfo,
    required this.packageInfo,
    required this.errorType,
    required this.errorCategory,
    this.stackTrace,
    this.userId,
    this.operation,
  });

  final String id;
  final DateTime timestamp;
  final Object error;
  final StackTrace? stackTrace;
  final ErrorSeverity severity;
  final Map<String, dynamic> context;
  final String? userId;
  final String? operation;
  final Map<String, dynamic> deviceInfo;
  final Map<String, dynamic> packageInfo;
  final String errorType;
  final ErrorCategory errorCategory;

  /// Convert to JSON for reporting
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'error_message': error.toString(),
      'error_type': errorType,
      'error_category': errorCategory.name,
      'severity': severity.name,
      'stack_trace': stackTrace?.toString(),
      'context': context,
      'user_id': userId,
      'operation': operation,
      'device_info': deviceInfo,
      'package_info': packageInfo,
    };
  }

  @override
  String toString() {
    return 'ErrorReport{id: $id, type: $errorType, severity: $severity, error: $error}';
  }
}

/// Error severity levels
enum ErrorSeverity {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Error categories
enum ErrorCategory {
  validation,
  network,
  cryptographic,
  storage,
  session,
  key,
  initialization,
  unknown,
}

/// Error statistics
class ErrorStatistics {
  const ErrorStatistics({
    required this.totalErrors,
    required this.errorsByType,
    required this.errorsBySeverity,
    required this.recentErrors,
  });

  final int totalErrors;
  final Map<String, int> errorsByType;
  final Map<ErrorSeverity, int> errorsBySeverity;
  final List<ErrorReport> recentErrors;
}

/// Error report listener interface
abstract class ErrorReportListener {
  Future<void> onErrorReport(ErrorReport report);
}

/// Console error report listener
class ConsoleErrorReportListener implements ErrorReportListener {
  @override
  Future<void> onErrorReport(ErrorReport report) async {
    print('ERROR REPORT: ${report.toString()}');
    if (report.severity == ErrorSeverity.critical) {
      print('CRITICAL ERROR DETAILS: ${report.toJson()}');
    }
  }
}

/// File error report listener
class FileErrorReportListener implements ErrorReportListener {
  FileErrorReportListener({required this.filePath});
  
  final String filePath;

  @override
  Future<void> onErrorReport(ErrorReport report) async {
    try {
      final file = File(filePath);
      final json = report.toJson();
      final line = '${DateTime.now().toIso8601String()}: ${json.toString()}\n';
      await file.writeAsString(line, mode: FileMode.append);
    } catch (e) {
      SignalLogger.warning('Failed to write error report to file: $e');
    }
  }
}
