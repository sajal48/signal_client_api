/// Offline queue manager for handling operations when connectivity is lost
library;

import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';

import '../firebase/firebase_key_manager.dart';
import 'logger.dart';

/// Manages a queue of operations to execute when connectivity is restored
class OfflineQueueManager {
  static Box<String>? _queueBox;
  static bool _isInitialized = false;
  static Timer? _retryTimer;
  static int _retryAttempts = 0;
  static const int _maxRetryAttempts = 5;
  
  /// Callback for when queued operations are processed
  static Function(QueuedOperation operation)? onOperationProcessed;
  
  /// Callback for when queue operations fail
  static Function(QueuedOperation operation, String error)? onOperationFailed;
  
  /// Initialize the offline queue manager
  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    
    try {
      _queueBox = await Hive.openBox<String>('signal_offline_queue');
      _isInitialized = true;
      
      SignalLogger.info('Offline queue manager initialized');
    } catch (e) {
      SignalLogger.error('Failed to initialize offline queue manager: $e');
      throw Exception('Offline queue initialization failed: $e');
    }
  }
  
  /// Add an operation to the offline queue
  /// 
  /// Operations will be executed when connectivity is restored
  static Future<void> queueOperation({
    required String operationType,
    required Map<String, dynamic> operationData,
    int priority = 1,
    Duration? maxAge,
  }) async {
    _ensureInitialized();
    
    try {
      final operation = QueuedOperation(
        id: _generateOperationId(),
        type: operationType,
        data: operationData,
        priority: priority,
        queuedAt: DateTime.now(),
        maxAge: maxAge,
        attempts: 0,
      );
      
      final key = '${operation.priority}_${operation.queuedAt.millisecondsSinceEpoch}_${operation.id}';
      await _queueBox!.put(key, jsonEncode(operation.toMap()));
      
      SignalLogger.debug('Queued operation: $operationType (id: ${operation.id})');
    } catch (e) {
      SignalLogger.error('Failed to queue operation: $e');
    }
  }
  
  /// Process all queued operations
  /// 
  /// This should be called when connectivity is restored
  static Future<void> processQueue() async {
    _ensureInitialized();
    
    if (_queueBox!.isEmpty) {
      SignalLogger.debug('Offline queue is empty');
      return;
    }
    
    try {
      SignalLogger.info('Processing offline queue (${_queueBox!.length} operations)');
      
      // Get all operations sorted by priority and timestamp
      final operations = _getQueuedOperations();
      
      int processed = 0;
      int failed = 0;
      
      for (final operation in operations) {
        try {
          // Check if operation has expired
          if (_isOperationExpired(operation)) {
            await _removeOperation(operation);
            SignalLogger.debug('Removed expired operation: ${operation.id}');
            continue;
          }
          
          // Process the operation
          await _processOperation(operation);
          await _removeOperation(operation);
          
          processed++;
          onOperationProcessed?.call(operation);
          
        } catch (e) {
          SignalLogger.error('Failed to process operation ${operation.id}: $e');
          
          // Increment attempts and check if we should retry
          operation.attempts++;
          
          if (operation.attempts >= _maxRetryAttempts) {
            await _removeOperation(operation);
            failed++;
            onOperationFailed?.call(operation, e.toString());
          } else {
            // Update operation with new attempt count
            await _updateOperation(operation);
          }
        }
      }
      
      SignalLogger.info('Queue processing complete: $processed processed, $failed failed');
      
      // Schedule retry for remaining operations if any
      if (_queueBox!.isNotEmpty) {
        _scheduleRetry();
      }
      
    } catch (e) {
      SignalLogger.error('Failed to process offline queue: $e');
    }
  }
  
  /// Get the number of queued operations
  static int get queueSize {
    return _queueBox?.length ?? 0;
  }
  
  /// Get queue statistics
  static Map<String, dynamic> getQueueStats() {
    if (!_isInitialized) {
      return {
        'initialized': false,
        'queue_size': 0,
      };
    }
    
    final operations = _getQueuedOperations();
    final now = DateTime.now();
    
    // Group by operation type
    final typeStats = <String, int>{};
    int expiredCount = 0;
    int recentCount = 0;
    
    for (final operation in operations) {
      typeStats[operation.type] = (typeStats[operation.type] ?? 0) + 1;
      
      if (_isOperationExpired(operation)) {
        expiredCount++;
      }
      
      if (now.difference(operation.queuedAt).inMinutes < 5) {
        recentCount++;
      }
    }
    
    return {
      'initialized': true,
      'queue_size': operations.length,
      'retry_attempts': _retryAttempts,
      'max_retry_attempts': _maxRetryAttempts,
      'expired_operations': expiredCount,
      'recent_operations': recentCount,
      'operation_types': typeStats,
      'oldest_operation': operations.isNotEmpty 
          ? operations.first.queuedAt.toIso8601String()
          : null,
    };
  }
  
  /// Clear all queued operations
  static Future<void> clearQueue() async {
    _ensureInitialized();
    
    try {
      await _queueBox!.clear();
      _retryAttempts = 0;
      _retryTimer?.cancel();
      
      SignalLogger.info('Offline queue cleared');
    } catch (e) {
      SignalLogger.error('Failed to clear offline queue: $e');
    }
  }
  
  /// Clean up expired operations
  static Future<void> cleanupExpiredOperations() async {
    _ensureInitialized();
    
    try {
      final operations = _getQueuedOperations();
      int cleaned = 0;
      
      for (final operation in operations) {
        if (_isOperationExpired(operation)) {
          await _removeOperation(operation);
          cleaned++;
        }
      }
      
      if (cleaned > 0) {
        SignalLogger.info('Cleaned up $cleaned expired operations');
      }
    } catch (e) {
      SignalLogger.error('Failed to cleanup expired operations: $e');
    }
  }
  
  /// Dispose of the offline queue manager
  static Future<void> dispose() async {
    try {
      _retryTimer?.cancel();
      await _queueBox?.close();
      
      _isInitialized = false;
      onOperationProcessed = null;
      onOperationFailed = null;
      
      SignalLogger.info('Offline queue manager disposed');
    } catch (e) {
      SignalLogger.error('Failed to dispose offline queue manager: $e');
    }
  }
  
  // Private helper methods
  
  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception('Offline queue manager not initialized. Call initialize() first.');
    }
  }
  
  static String _generateOperationId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  static List<QueuedOperation> _getQueuedOperations() {
    final operations = <QueuedOperation>[];
    
    for (final entry in _queueBox!.toMap().entries) {
      try {
        final operationMap = jsonDecode(entry.value) as Map<String, dynamic>;
        operations.add(QueuedOperation.fromMap(operationMap));
      } catch (e) {
        SignalLogger.error('Failed to parse queued operation: $e');
      }
    }
    
    // Sort by priority (higher first) then by timestamp (older first)
    operations.sort((a, b) {
      final priorityComparison = b.priority.compareTo(a.priority);
      if (priorityComparison != 0) return priorityComparison;
      return a.queuedAt.compareTo(b.queuedAt);
    });
    
    return operations;
  }
  
  static bool _isOperationExpired(QueuedOperation operation) {
    if (operation.maxAge == null) return false;
    
    final age = DateTime.now().difference(operation.queuedAt);
    return age > operation.maxAge!;
  }
  
  static Future<void> _processOperation(QueuedOperation operation) async {
    SignalLogger.debug('Processing operation: ${operation.type} (id: ${operation.id})');
    
    // Dispatch to appropriate handler based on operation type
    switch (operation.type) {
      case 'upload_keys':
        await _processKeyUpload(operation.data);
        break;
      case 'sync_keys':
        await _processSyncKeys(operation.data);
        break;
      case 'upload_message':
        await _processMessageUpload(operation.data);
        break;
      default:
        throw Exception('Unknown operation type: ${operation.type}');
    }
  }
  
  static Future<void> _processKeyUpload(Map<String, dynamic> data) async {
    SignalLogger.debug('Processing key upload: $data');
    
    try {
      final userId = data['user_id'] as String?;
      final deviceId = data['device_id'] as int?;
      
      if (userId == null || deviceId == null) {
        throw ArgumentError('Missing user_id or device_id in key upload data');
      }

      // This would involve calling the appropriate API to upload keys
      // For now, we simulate the operation with validation
      SignalLogger.info('Key upload operation processed for user: $userId, device: $deviceId');
      
      // Simulate processing time
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      SignalLogger.error('Failed to process key upload: $e');
      rethrow;
    }
  }
  
  static Future<void> _processSyncKeys(Map<String, dynamic> data) async {
    SignalLogger.debug('Processing key sync: $data');
    
    try {
      final userId = data['user_id'] as String?;
      
      if (userId == null) {
        throw ArgumentError('Missing user_id in key sync data');
      }

      // Download and process user keys from Firebase
      final keyBundle = await FirebaseKeyManager.downloadKeyBundle(userId: userId);
      
      if (keyBundle != null) {
        SignalLogger.info('Key sync operation processed for user: $userId');
      } else {
        SignalLogger.warning('No keys found during sync for user: $userId');
      }
      
      // Simulate processing time
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      SignalLogger.error('Failed to process key sync: $e');
      rethrow;
    }
  }
  
  static Future<void> _processMessageUpload(Map<String, dynamic> data) async {
    SignalLogger.debug('Processing message upload: $data');
    
    try {
      final messageId = data['message_id'] as String?;
      final recipientId = data['recipient_id'] as String?;
      
      if (messageId == null || recipientId == null) {
        throw ArgumentError('Missing message_id or recipient_id in message upload data');
      }

      // This would involve uploading encrypted messages to Firebase
      // For now, we simulate the operation with validation
      SignalLogger.info('Message upload operation processed for message: $messageId to recipient: $recipientId');
      
      // Simulate processing time
      await Future.delayed(const Duration(milliseconds: 150));
    } catch (e) {
      SignalLogger.error('Failed to process message upload: $e');
      rethrow;
    }
  }

  static Future<void> _removeOperation(QueuedOperation operation) async {
    final key = _findOperationKey(operation);
    if (key != null) {
      await _queueBox!.delete(key);
    }
  }
  
  static Future<void> _updateOperation(QueuedOperation operation) async {
    final key = _findOperationKey(operation);
    if (key != null) {
      await _queueBox!.put(key, jsonEncode(operation.toMap()));
    }
  }
  
  static String? _findOperationKey(QueuedOperation operation) {
    for (final entry in _queueBox!.toMap().entries) {
      try {
        final operationMap = jsonDecode(entry.value) as Map<String, dynamic>;
        if (operationMap['id'] == operation.id) {
          return entry.key;
        }
      } catch (e) {
        // Ignore malformed entries
      }
    }
    return null;
  }
  
  static void _scheduleRetry() {
    _retryTimer?.cancel();
    
    if (_retryAttempts >= _maxRetryAttempts) {
      SignalLogger.warning('Max retry attempts reached for offline queue processing');
      return;
    }
    
    // Exponential backoff: 1min, 2min, 4min, 8min, 16min
    final delayMinutes = 1 << _retryAttempts;
    final delay = Duration(minutes: delayMinutes);
    
    _retryTimer = Timer(delay, () async {
      _retryAttempts++;
      SignalLogger.info('Retrying offline queue processing (attempt $_retryAttempts)');
      await processQueue();
    });
    
    SignalLogger.debug('Scheduled retry in ${delay.inMinutes} minutes');
  }
}

/// Represents a queued operation to be executed when online
class QueuedOperation {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final int priority;
  final DateTime queuedAt;
  final Duration? maxAge;
  int attempts;
  
  QueuedOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.priority,
    required this.queuedAt,
    this.maxAge,
    this.attempts = 0,
  });
  
  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'priority': priority,
      'queued_at': queuedAt.toIso8601String(),
      'max_age_seconds': maxAge?.inSeconds,
      'attempts': attempts,
    };
  }
  
  /// Create from map (deserialization)
  factory QueuedOperation.fromMap(Map<String, dynamic> map) {
    return QueuedOperation(
      id: map['id'],
      type: map['type'],
      data: Map<String, dynamic>.from(map['data']),
      priority: map['priority'],
      queuedAt: DateTime.parse(map['queued_at']),
      maxAge: map['max_age_seconds'] != null 
          ? Duration(seconds: map['max_age_seconds'])
          : null,
      attempts: map['attempts'] ?? 0,
    );
  }
  
  @override
  String toString() {
    return 'QueuedOperation(id: $id, type: $type, priority: $priority, attempts: $attempts)';
  }
}
