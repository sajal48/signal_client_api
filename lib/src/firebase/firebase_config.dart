/// Firebase configuration for Signal Protocol package
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

/// Firebase configuration and initialization for Signal Protocol
class FirebaseConfig {
  static FirebaseDatabase? _database;
  static bool _initialized = false;

  /// Initialize Firebase for Signal Protocol package
  /// 
  /// [app] Optional Firebase app instance. If null, uses default app.
  /// [databaseURL] Optional database URL for Realtime Database
  static Future<void> initialize({
    FirebaseApp? app,
    String? databaseURL,
  }) async {
    if (_initialized) {
      return;
    }

    // Ensure Firebase Core is initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    // Initialize Realtime Database
    _database = FirebaseDatabase.instanceFor(
      app: app ?? Firebase.app(),
      databaseURL: databaseURL,
    );

    _initialized = true;
  }

  /// Get the Firebase Realtime Database instance
  static FirebaseDatabase get database {
    if (!_initialized || _database == null) {
      throw StateError(
        'FirebaseConfig must be initialized before accessing database. '
        'Call FirebaseConfig.initialize() first.',
      );
    }
    return _database!;
  }

  /// Check if Firebase is initialized
  static bool get isInitialized => _initialized;

  /// Database schema paths for Signal Protocol data
  static const String _basePath = 'signal_protocol';
  
  /// Path structure:
  /// signal_protocol/
  /// ├── users/
  /// │   └── {userId}/
  /// │       ├── identity_key
  /// │       ├── registration_id
  /// │       ├── prekeys/
  /// │       │   └── {preKeyId}
  /// │       ├── signed_prekey/
  /// │       └── metadata/
  /// └── groups/
  ///     └── {groupId}/
  ///         └── sender_keys/
  ///             └── {deviceId}

  static String userPath(String userId) => '$_basePath/users/$userId';
  static String userIdentityKeyPath(String userId) => '${userPath(userId)}/identity_key';
  static String userRegistrationIdPath(String userId) => '${userPath(userId)}/registration_id';
  static String userPreKeysPath(String userId) => '${userPath(userId)}/prekeys';
  static String userPreKeyPath(String userId, int preKeyId) => '${userPreKeysPath(userId)}/$preKeyId';
  static String userSignedPreKeyPath(String userId) => '${userPath(userId)}/signed_prekey';
  static String userMetadataPath(String userId) => '${userPath(userId)}/metadata';
  
  static String groupPath(String groupId) => '$_basePath/groups/$groupId';
  static String groupSenderKeysPath(String groupId) => '${groupPath(groupId)}/sender_keys';
  static String groupSenderKeyPath(String groupId, String deviceId) => '${groupSenderKeysPath(groupId)}/$deviceId';

  /// Cleanup resources
  static void dispose() {
    _database = null;
    _initialized = false;
  }
}
