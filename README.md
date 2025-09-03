# Signal Protocol Flutter

A comprehensive Flutter package implementing the Signal Protocol for secure end-to-end encryption, with Firebase integration for key synchronization across devices.

## Features

- **Signal Protocol Implementation**: Built on the robust `libsignal_protocol_dart` library
- **Persistent Storage**: Secure local storage using Hive with encrypted adapters
- **Firebase Integration**: Real-time key synchronization across multiple devices
- **Multi-Device Support**: Complete session management for multiple devices per user
- **Comprehensive Error Handling**: Detailed exception classes for different error scenarios
- **Offline Support**: Queue operations when offline and sync when connectivity is restored
- **Performance Optimized**: Efficient caching and lazy loading strategies

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  signal_protocol_flutter: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Run the Examples

```bash
# Quick 5-minute example
dart run quick_start.dart

# Comprehensive usage examples
dart run usage_example.dart

# See the working Flutter app
cd example && flutter run
```

### 2. Basic Usage

```dart
import 'package:signal_protocol_flutter/signal_protocol_flutter.dart';

// Initialize the Signal Protocol
final signalApi = SignalProtocolApi();

// Create Firebase configuration
final firebaseConfig = FirebaseConfig();
await FirebaseConfig.initialize(
  databaseURL: 'https://your-project.firebaseio.com',
);

// Initialize for a user
await signalApi.initialize(
  userId: 'user123',
  firebaseConfig: firebaseConfig,
);

// Upload keys to Firebase for other devices to discover
await signalApi.uploadKeysToFirebase();

// Check if keys exist for a recipient
final hasKeys = await signalApi.hasKeysForUser('recipient456');

// Get instance information
final info = await signalApi.getInstanceInfo();
print('Initialized: ${info['isInitialized']}');
```

### 3. Examples

#### Quick Start (5 minutes)
```bash
dart run quick_start.dart
```

#### Comprehensive Examples
```bash
dart run usage_example.dart
```

#### Automatic Key Sync
```bash
dart run auto_sync_example.dart
```

#### Complete End-to-End Example
```bash
dart run complete_example.dart
```

#### Flutter Example App
```bash
cd example && flutter run
```

The examples demonstrate:
- Two-user messaging setup
- Key management and Firebase integration  
- Automatic vs manual key sync patterns
- Real encryption/decryption with Signal Protocol
- Production-ready service patterns
- Error handling and offline support

## Core Components

### SignalProtocolApi

The main interface for all Signal Protocol operations:

```dart
final api = SignalProtocolApi();

// Initialize
await api.initialize(
  userId: 'your-user-id',
  firebaseConfig: firebaseConfig,
);

// Key operations
await api.uploadKeysToFirebase();
final hasKeys = await api.hasKeysForUser('recipient-id');

// Instance management
final info = await api.getInstanceInfo();
await api.dispose();
```

### Storage Components

Secure local storage for all Signal Protocol data:

- **SecureIdentityStore**: Identity keys and registration data
- **HiveSessionStore**: Session state management
- **HivePreKeyStore**: One-time pre-keys
- **HiveSignedPreKeyStore**: Signed pre-keys
- **HiveSenderKeyStore**: Group messaging keys

### Firebase Integration

Real-time synchronization of public keys and metadata:

- **FirebaseKeyManager**: Upload/download operations
- **FirebaseSyncService**: Real-time listeners and sync
- **FirebaseConfig**: Configuration and initialization

### Validation and Error Handling

Comprehensive validation and error management:

```dart
try {
  await api.initialize(userId: userId, firebaseConfig: config);
} catch (e) {
  if (e is ValidationException) {
    print('Invalid input: ${e.message}');
  } else if (e is InitializationException) {
    print('Initialization failed: ${e.message}');
  } else if (e is StorageException) {
    print('Storage error: ${e.message}');
  }
}
```

## API Reference

### SignalProtocolApi Methods

| Method | Description | Returns |
|--------|-------------|---------|
| `initialize()` | Initialize Signal Protocol for a user | `Future<void>` |
| `uploadKeysToFirebase()` | Upload public keys to Firebase | `Future<void>` |
| `hasKeysForUser(String userId)` | Check if keys exist for user | `Future<bool>` |
| `getInstanceInfo()` | Get initialization status and info | `Future<Map<String, dynamic>>` |
| `dispose()` | Clean up resources | `Future<void>` |

### Exception Classes

- **ValidationException**: Input validation errors
- **InitializationException**: Setup and configuration errors  
- **StorageException**: Local storage errors
- **CryptographyException**: Encryption/decryption errors

### Validators

Static validation methods for common inputs:

```dart
Validators.validateUserId('user123');
Validators.validateDeviceId(1);
Validators.validateMessage('hello');
Validators.validateGroupId('group456');
Validators.validateFirebaseUrl('https://project.firebaseio.com');
```

## Security Notes

- **Private keys never leave the device** - only public keys are synchronized
- All local storage is encrypted using platform-specific secure storage
- Firebase rules should be configured to restrict access appropriately
- Regular key rotation is recommended for enhanced security

## Development Status

This package is currently in **Phase 6 (Testing & Documentation)**:

- ✅ Core API implementation complete
- ✅ Storage components operational
- ✅ Firebase integration functional
- ✅ Comprehensive testing suite
- ✅ Example application
- ⏳ Full encryption/decryption (planned for Phase 5)

See `DEVELOPMENT_TRACKING.md` for detailed progress and roadmap.

## Requirements

- Flutter 3.0.0 or higher
- Dart 3.0.0 or higher
- Firebase project with Realtime Database enabled

## Dependencies

- `hive`: Local storage
- `hive_flutter`: Flutter integration for Hive
- `firebase_core`: Firebase core functionality
- `firebase_database`: Firebase Realtime Database
- `libsignal_protocol_dart`: Signal Protocol implementation
- `flutter_secure_storage`: Secure local storage
- And more (see `pubspec.yaml`)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or contributions, please visit the [GitHub repository](https://github.com/your-repo/signal_protocol_flutter).

## Acknowledgments

- Built on the excellent `libsignal_protocol_dart` library
- Inspired by the Signal messenger protocol
- Firebase integration for real-time synchronization
