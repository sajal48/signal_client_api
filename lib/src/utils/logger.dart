import 'dart:developer' as developer;

/// Log levels for the Signal Protocol package
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Logger configuration for the Signal Protocol package
class LogConfig {
  const LogConfig({
    this.enabled = true,
    this.logLevel = LogLevel.info,
    this.includeStackTrace = false,
    this.prefix = 'SignalProtocol',
  });

  /// Whether logging is enabled
  final bool enabled;
  
  /// Minimum log level to output
  final LogLevel logLevel;
  
  /// Whether to include stack traces in error logs
  final bool includeStackTrace;
  
  /// Prefix for all log messages
  final String prefix;
}

/// Logger utility for the Signal Protocol package
class SignalLogger {
  static LogConfig _config = const LogConfig();
  
  /// Configure the logger
  static void configure(LogConfig config) {
    _config = config;
  }
  
  /// Log a debug message
  static void debug(String message, {String? component}) {
    _log(LogLevel.debug, message, component: component);
  }
  
  /// Log an info message
  static void info(String message, {String? component}) {
    _log(LogLevel.info, message, component: component);
  }
  
  /// Log a warning message
  static void warning(String message, {String? component, Object? error}) {
    _log(LogLevel.warning, message, component: component, error: error);
  }
  
  /// Log an error message
  static void error(String message, {String? component, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, component: component, error: error, stackTrace: stackTrace);
  }
  
  static void _log(
    LogLevel level,
    String message, {
    String? component,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_config.enabled || level.index < _config.logLevel.index) {
      return;
    }
    
    final componentPrefix = component != null ? '[$component] ' : '';
    final logMessage = '${_config.prefix}: $componentPrefix$message';
    
    switch (level) {
      case LogLevel.debug:
        developer.log(logMessage, name: _config.prefix, level: 700);
        break;
      case LogLevel.info:
        developer.log(logMessage, name: _config.prefix, level: 800);
        break;
      case LogLevel.warning:
        developer.log(
          logMessage,
          name: _config.prefix,
          level: 900,
          error: error,
        );
        break;
      case LogLevel.error:
        developer.log(
          logMessage,
          name: _config.prefix,
          level: 1000,
          error: error,
          stackTrace: stackTrace ?? (_config.includeStackTrace ? StackTrace.current : null),
        );
        break;
    }
  }
}
