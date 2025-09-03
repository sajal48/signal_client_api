import 'package:signal_protocol_flutter/signal_protocol_flutter.dart';

/// Service wrapper for Signal Protocol operations
/// Provides a simplified interface for the example app
class SignalService {
  SignalProtocolApi? _api;
  String? _currentUserId;

  /// Check if the service is initialized
  Future<bool> isInitialized() async {
    try {
      if (_api == null) return false;
      final info = await _api!.getInstanceInfo();
      return info['isInitialized'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Initialize the Signal Protocol for a user
  Future<void> initialize({
    required String userId,
    required FirebaseConfig firebaseConfig,
  }) async {
    try {
      _currentUserId = userId;
      _api = SignalProtocolApi();
      
      await _api!.initialize(
        userId: userId,
        firebaseConfig: firebaseConfig,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Upload keys to Firebase (if configured)
  Future<void> uploadKeys() async {
    if (_api == null) throw Exception('Not initialized');
    await _api!.uploadKeysToFirebase();
  }

  /// Check if keys exist for a user
  Future<bool> hasKeysForUser(String userId) async {
    if (_api == null) throw Exception('Not initialized');
    return await _api!.hasKeysForUser(userId);
  }

  /// Get instance information (includes storage stats)
  Future<Map<String, dynamic>> getInstanceInfo() async {
    if (_api == null) throw Exception('Not initialized');
    return await _api!.getInstanceInfo();
  }

  /// Dispose resources
  Future<void> dispose() async {
    if (_api != null) {
      await _api!.dispose();
      _api = null;
      _currentUserId = null;
    }
  }

  /// Get current user ID
  String? get currentUserId => _currentUserId;

  /// Check if API is available
  bool get isApiAvailable => _api != null;

  /// Validate user ID format (basic validation)
  bool isValidUserId(String userId) {
    try {
      Validators.validateUserId(userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validate Firebase URL format (basic validation)
  bool isValidFirebaseUrl(String url) {
    try {
      Validators.validateFirebaseUrl(url);
      return true;
    } catch (e) {
      return false;
    }
  }
}
