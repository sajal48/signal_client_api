/// Network connectivity manager for real-time sync
library;

import 'dart:async';
import 'dart:io';

import 'logger.dart';

/// Manages network connectivity state and provides callbacks for changes
class ConnectivityManager {
  static Timer? _pingTimer;
  static bool _isOnline = false;
  static DateTime? _lastOnlineTime;
  static DateTime? _lastOfflineTime;
  static int _consecutiveFailures = 0;
  
  /// Callback for connectivity state changes
  static Function(bool isOnline)? onConnectivityChanged;
  
  /// Callback for connectivity events (with details)
  static Function(ConnectivityEvent event)? onConnectivityEvent;
  
  /// Current connectivity state
  static bool get isOnline => _isOnline;
  
  /// Last time we were online
  static DateTime? get lastOnlineTime => _lastOnlineTime;
  
  /// Last time we went offline
  static DateTime? get lastOfflineTime => _lastOfflineTime;
  
  /// Number of consecutive connection failures
  static int get consecutiveFailures => _consecutiveFailures;
  
  /// Start monitoring network connectivity
  /// 
  /// This will periodically check internet connectivity and notify
  /// listeners of changes. Uses exponential backoff for failed checks.
  /// 
  /// Parameters:
  /// - [checkInterval]: How often to check connectivity (default: 30 seconds)
  /// - [hostUrl]: URL to ping for connectivity check (default: Google DNS)
  /// - [timeout]: Timeout for connectivity check (default: 10 seconds)
  static Future<void> startMonitoring({
    Duration checkInterval = const Duration(seconds: 30),
    String hostUrl = 'https://dns.google',
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      SignalLogger.info('Starting connectivity monitoring');
      
      // Stop any existing monitoring
      await stopMonitoring();
      
      // Do initial check
      await _checkConnectivity(hostUrl, timeout);
      
      // Start periodic checks
      _pingTimer = Timer.periodic(checkInterval, (timer) async {
        await _checkConnectivity(hostUrl, timeout);
      });
      
      SignalLogger.info('Connectivity monitoring started');
    } catch (e) {
      SignalLogger.error('Failed to start connectivity monitoring: $e');
    }
  }
  
  /// Stop monitoring network connectivity
  static Future<void> stopMonitoring() async {
    try {
      _pingTimer?.cancel();
      _pingTimer = null;
      
      SignalLogger.info('Connectivity monitoring stopped');
    } catch (e) {
      SignalLogger.error('Failed to stop connectivity monitoring: $e');
    }
  }
  
  /// Force a connectivity check
  /// 
  /// Returns true if online, false if offline
  static Future<bool> checkConnectivityNow({
    String hostUrl = 'https://dns.google',
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return await _checkConnectivity(hostUrl, timeout);
  }
  
  /// Get detailed connectivity information
  static Map<String, dynamic> getConnectivityInfo() {
    return {
      'is_online': _isOnline,
      'last_online_time': _lastOnlineTime?.toIso8601String(),
      'last_offline_time': _lastOfflineTime?.toIso8601String(),
      'consecutive_failures': _consecutiveFailures,
      'monitoring_active': _pingTimer != null,
      'uptime_duration': _lastOnlineTime != null && _isOnline 
          ? DateTime.now().difference(_lastOnlineTime!).inSeconds
          : null,
      'downtime_duration': _lastOfflineTime != null && !_isOnline
          ? DateTime.now().difference(_lastOfflineTime!).inSeconds
          : null,
    };
  }
  
  /// Dispose of connectivity manager resources
  static Future<void> dispose() async {
    await stopMonitoring();
    onConnectivityChanged = null;
    onConnectivityEvent = null;
    
    SignalLogger.info('Connectivity manager disposed');
  }
  
  /// Check connectivity by attempting to reach a host
  static Future<bool> _checkConnectivity(String hostUrl, Duration timeout) async {
    bool newOnlineState = false;
    
    try {
      // Parse URL to get host and port
      final uri = Uri.parse(hostUrl);
      final host = uri.host;
      final port = uri.port != 0 ? uri.port : (uri.scheme == 'https' ? 443 : 80);
      
      // Attempt socket connection
      final socket = await Socket.connect(host, port, timeout: timeout);
      await socket.close();
      
      newOnlineState = true;
      _consecutiveFailures = 0;
      
    } catch (e) {
      newOnlineState = false;
      _consecutiveFailures++;
      
      SignalLogger.debug('Connectivity check failed: $e (failures: $_consecutiveFailures)');
    }
    
    // Check if state changed
    if (newOnlineState != _isOnline) {
      _handleConnectivityChange(newOnlineState);
    }
    
    return newOnlineState;
  }
  
  /// Handle connectivity state changes
  static void _handleConnectivityChange(bool isOnline) {
    final previousState = _isOnline;
    _isOnline = isOnline;
    
    if (isOnline) {
      _lastOnlineTime = DateTime.now();
      SignalLogger.info('Connectivity restored (was offline for ${_getOfflineDuration()})');
    } else {
      _lastOfflineTime = DateTime.now();
      SignalLogger.warning('Connectivity lost (was online for ${_getOnlineDuration()})');
    }
    
    // Create connectivity event
    final event = ConnectivityEvent(
      isOnline: isOnline,
      previousState: previousState,
      timestamp: DateTime.now(),
      consecutiveFailures: _consecutiveFailures,
      lastOnlineTime: _lastOnlineTime,
      lastOfflineTime: _lastOfflineTime,
    );
    
    // Notify listeners
    try {
      onConnectivityChanged?.call(isOnline);
      onConnectivityEvent?.call(event);
    } catch (e) {
      SignalLogger.error('Failed to notify connectivity listeners: $e');
    }
  }
  
  /// Get duration we've been online
  static String _getOnlineDuration() {
    if (_lastOnlineTime == null) return 'unknown';
    
    final duration = DateTime.now().difference(_lastOnlineTime!);
    return _formatDuration(duration);
  }
  
  /// Get duration we've been offline
  static String _getOfflineDuration() {
    if (_lastOfflineTime == null) return 'unknown';
    
    final duration = DateTime.now().difference(_lastOfflineTime!);
    return _formatDuration(duration);
  }
  
  /// Format duration for human reading
  static String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}

/// Represents a connectivity change event
class ConnectivityEvent {
  final bool isOnline;
  final bool previousState;
  final DateTime timestamp;
  final int consecutiveFailures;
  final DateTime? lastOnlineTime;
  final DateTime? lastOfflineTime;
  
  const ConnectivityEvent({
    required this.isOnline,
    required this.previousState,
    required this.timestamp,
    required this.consecutiveFailures,
    this.lastOnlineTime,
    this.lastOfflineTime,
  });
  
  /// Get the type of connectivity change
  String get changeType {
    if (!previousState && isOnline) {
      return 'came_online';
    } else if (previousState && !isOnline) {
      return 'went_offline';
    } else {
      return 'no_change';
    }
  }
  
  /// Convert to map for logging/serialization
  Map<String, dynamic> toMap() {
    return {
      'is_online': isOnline,
      'previous_state': previousState,
      'timestamp': timestamp.toIso8601String(),
      'change_type': changeType,
      'consecutive_failures': consecutiveFailures,
      'last_online_time': lastOnlineTime?.toIso8601String(),
      'last_offline_time': lastOfflineTime?.toIso8601String(),
    };
  }
  
  @override
  String toString() {
    return 'ConnectivityEvent($changeType, failures: $consecutiveFailures)';
  }
}
