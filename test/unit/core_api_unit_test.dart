import 'package:flutter_test/flutter_test.dart';
import 'package:signal_protocol_flutter/src/core_api.dart';
import 'package:signal_protocol_flutter/src/exceptions/signal_exceptions.dart';

void main() {
  group('SignalProtocolApi Unit Tests (Basic State)', () {
    late SignalProtocolApi api;

    setUp(() {
      api = SignalProtocolApi();
    });

    tearDown(() async {
      if (api.isInitialized) {
        await api.dispose();
      }
    });

    group('Basic State Tests', () {
      test('should start uninitialized', () {
        expect(api.isInitialized, isFalse);
      });

      test('should return null user ID when not initialized', () {
        expect(api.userId, isNull);
      });

      test('should return null device ID when not initialized', () {
        expect(api.deviceId, isNull);
      });

      test('should track real-time sync status', () {
        expect(api.isRealTimeSyncEnabled, isFalse);
      });
    });

    group('Error Handling Tests', () {
      test('should throw exception for operations on uninitialized API', () async {
        expect(
          () async => await api.uploadKeysToFirebase(),
          throwsA(isA<SignalException>()),
        );
        expect(
          () async => await api.refreshUserKeys('test-user'),
          throwsA(isA<SignalException>()),
        );
        expect(
          () async => await api.hasKeysForUser('test-user'),
          throwsA(isA<SignalException>()),
        );
      });

      test('should handle dispose on uninitialized API', () async {
        // Should not throw exception
        await api.dispose();
        expect(api.isInitialized, isFalse);
      });
    });

    group('Method Coverage Tests', () {
      test('should have working toString method', () {
        final apiString = api.toString();
        expect(apiString, isA<String>());
        expect(apiString, contains('SignalProtocolApi'));
      });

      test('should handle getInstanceInfo for uninitialized API', () async {
        final info = await api.getInstanceInfo();
        expect(info, isA<Map<String, dynamic>>());
        expect(info['isInitialized'], isFalse);
      });

      test('should handle clean operations for uninitialized API', () async {
        // These should throw since API is not initialized
        expect(
          () async => await api.cleanLocal(),
          throwsA(isA<SignalException>()),
        );
        expect(
          () async => await api.cleanAll(),
          throwsA(isA<SignalException>()),
        );
        
        // Firebase cleanup should throw since it's not implemented
        expect(
          () async => await api.cleanFirebase(),
          throwsA(isA<SignalException>()),
        );
      });
    });

    group('API Contract Tests', () {
      test('should handle multiple dispose calls gracefully', () async {
        await api.dispose();
        await api.dispose(); // Should not throw
        await api.dispose(); // Should not throw
        
        expect(api.isInitialized, isFalse);
      });
    });
  });
}
