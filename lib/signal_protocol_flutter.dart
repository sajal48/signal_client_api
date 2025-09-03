/// Signal Protocol Flutter Package
/// 
/// A comprehensive Signal Protocol implementation for Flutter apps with
/// persistent storage using Hive/Secure Storage and Firebase integration
/// for key management and real-time synchronization.
/// 
/// ## Features
/// 
/// - **Persistent Storage**: Uses Hive for performance and flutter_secure_storage for sensitive data
/// - **Firebase Integration**: Real-time key synchronization and management
/// - **Multi-device Support**: Handles multiple devices per user
/// - **Security First**: Private keys never leave the device
/// - **Production Ready**: Comprehensive error handling and logging
/// 
/// ## Basic Usage
/// 
/// ```dart
/// import 'package:signal_protocol_flutter/signal_protocol_flutter.dart';
/// 
/// // Initialize the Signal Protocol
/// final signalApi = SignalProtocolApi();
/// await signalApi.initialize(
///   userId: 'user123',
///   firebaseConfig: FirebaseConfig(
///     databaseUrl: 'https://your-project.firebaseio.com',
///   ),
/// );
/// 
/// // Check if keys are available for a user
/// final hasKeys = await signalApi.hasKeysForUser('recipient456');
/// 
/// // Upload your keys to Firebase
/// await signalApi.uploadKeysToFirebase();
/// ```
/// 
/// ## Core Components
/// 
/// - [SignalProtocolApi]: Main API interface
/// - [FirebaseConfig]: Firebase configuration
/// - [EncryptedMessage]: Message encryption result
/// - [GroupEncryptedMessage]: Group message encryption result
/// 
/// See individual class documentation for detailed usage information.
library;

// Core API (Primary interface)
export 'src/core_api.dart';

// Advanced API (Comprehensive features)
export 'signal_protocol_api.dart';

// Configuration
export 'src/firebase/firebase_config.dart';

// Models
export 'src/firebase/firebase_models.dart';

// Core crypto exports
export 'src/crypto/crypto.dart';

// Storage exports
export 'src/storage/basic_identity_store.dart';
export 'src/storage/hive_session_store.dart';
export 'src/storage/hive_prekey_store.dart';
export 'src/storage/hive_signed_prekey_store.dart';
export 'src/storage/hive_sender_key_store.dart';
export 'src/storage/secure_identity_store.dart';

// Firebase exports
export 'src/firebase/firebase.dart';

// Utility exports
export 'src/utils/logger.dart';
export 'src/utils/validators.dart';
export 'src/utils/error_handler.dart';
export 'src/utils/device_id_manager.dart';
export 'src/utils/performance_cache.dart';
export 'src/utils/error_reporter.dart';
export 'src/utils/platform_optimizer.dart';

// Exception exports
export 'src/exceptions/signal_exceptions.dart';
