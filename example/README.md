# Signal Protocol Flutter Example

This example demonstrates how to use the Signal Protocol Flutter package for secure messaging.

## Features Demonstrated

- **Basic Setup**: Initialize the Signal Protocol
- **Key Management**: Generate and manage encryption keys
- **Device Management**: Handle multiple devices per user
- **Storage**: Persistent local storage for keys and sessions
- **Firebase Sync**: Synchronize keys across devices
- **Error Handling**: Proper exception handling

## Running the Example

1. Set up Firebase project (see Firebase Setup section)
2. Run the example:
   ```bash
   flutter run
   ```

## Firebase Setup

1. Create a new Firebase project at https://console.firebase.google.com
2. Enable Realtime Database
3. Download the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place the configuration files in the appropriate directories
5. Update the Firebase configuration in the example

## Example Code Structure

```
example/
├── lib/
│   ├── main.dart                 # Main application entry point
│   ├── screens/
│   │   ├── home_screen.dart      # Home screen with navigation
│   │   ├── setup_screen.dart     # Initial setup and initialization
│   │   ├── messaging_screen.dart # Message encryption/decryption demo
│   │   └── keys_screen.dart      # Key management interface
│   ├── services/
│   │   └── signal_service.dart   # Signal Protocol service wrapper
│   └── models/
│       └── user_model.dart       # User data model
├── android/
│   └── app/
│       └── google-services.json  # Firebase config (Android)
├── ios/
│   └── Runner/
│       └── GoogleService-Info.plist # Firebase config (iOS)
└── pubspec.yaml
```

## Key Concepts Demonstrated

### 1. Initialization
```dart
final signalService = SignalService();
await signalService.initialize(
  userId: 'user123',
  firebaseConfig: firebaseConfig,
);
```

### 2. Key Management
```dart
// Upload keys to Firebase
await signalService.uploadKeys();

// Check if keys exist for a user
final hasKeys = await signalService.hasKeysForUser('recipient123');
```

### 3. Message Encryption (Placeholder)
```dart
// Will be implemented when encryption is available
final encryptedMessage = await signalService.encryptMessage(
  recipientId: 'recipient123',
  message: 'Hello, secure world!',
);
```

### 4. Storage Management
```dart
// Get storage statistics
final stats = await signalService.getStorageStats();

// Clean local storage
await signalService.cleanLocalStorage();
```

## Security Notes

- Private keys never leave the device
- Only public keys and metadata are synchronized via Firebase
- All cryptographic operations use the Signal Protocol library
- Storage is encrypted using platform-specific secure storage

## Troubleshooting

### Common Issues

1. **Firebase Connection Issues**
   - Verify Firebase configuration files are in the correct locations
   - Check that Realtime Database is enabled
   - Ensure proper network connectivity

2. **Storage Issues**
   - Clear app data if encountering storage conflicts
   - Check device storage permissions

3. **Key Generation Issues**
   - Ensure proper initialization before key operations
   - Check device entropy for key generation

### Debug Information

The example includes comprehensive logging and error handling to help debug issues:

- Enable debug logging to see detailed operation logs
- Check the instance info to verify proper initialization
- Use the storage statistics to monitor data usage

## Learn More

- [Signal Protocol Documentation](https://signal.org/docs/)
- [Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup)
- [Package Documentation](../README.md)
