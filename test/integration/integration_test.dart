import 'package:flutter_test/flutter_test.dart';
import 'package:signal_protocol_flutter/src/exceptions/signal_exceptions.dart';
import 'package:signal_protocol_flutter/src/utils/logger.dart';
import 'package:signal_protocol_flutter/src/utils/validators.dart';

void main() {
  group('Integration Tests', () {
    setUpAll(() {
      // Initialize test environment
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    group('Exception Handling Integration', () {
      test('should create and handle ValidationException', () {
        const exception = ValidationException(
          message: 'Test validation error',
          code: 'VALIDATION_001',
          details: {'field': 'userId'},
        );

        expect(exception.message, equals('Test validation error'));
        expect(exception.code, equals('VALIDATION_001'));
        expect(exception.details, isNotNull);
        expect(exception.details!['field'], equals('userId'));
        expect(exception.toString(), contains('Test validation error'));
      });

      test('should create and handle StorageException', () {
        const exception = StorageException(
          message: 'Storage operation failed',
          code: 'STORAGE_001',
        );

        expect(exception.message, equals('Storage operation failed'));
        expect(exception.code, equals('STORAGE_001'));
        expect(exception.toString(), contains('Storage operation failed'));
      });

      test('should create and handle CryptographicException', () {
        const exception = CryptographicException(
          message: 'Cryptographic operation failed',
          details: {'operation': 'encryption'},
        );

        expect(exception.message, equals('Cryptographic operation failed'));
        expect(exception.details, isNotNull);
        expect(exception.details!['operation'], equals('encryption'));
      });
    });

    group('Logger Integration', () {
      test('should handle different log levels without error', () {
        // These should not throw exceptions
        expect(() => SignalLogger.debug('Debug message'), returnsNormally);
        expect(() => SignalLogger.info('Info message'), returnsNormally);
        expect(() => SignalLogger.warning('Warning message'), returnsNormally);
        expect(() => SignalLogger.error('Error message'), returnsNormally);
      });

      test('should handle complex log messages', () {
        final data = {'key': 'value', 'count': 42};
        expect(() => SignalLogger.info('Complex message with data: $data'), returnsNormally);
      });
    });

    group('Validators Integration', () {
      test('should validate user IDs correctly', () {
        // Valid user IDs
        expect(() => Validators.validateUserId('valid-user-123'), returnsNormally);
        expect(() => Validators.validateUserId('user_123'), returnsNormally);
        expect(() => Validators.validateUserId('User123'), returnsNormally);

        // Invalid user IDs
        expect(
          () => Validators.validateUserId(''),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => Validators.validateUserId('user with spaces'),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => Validators.validateUserId('a' * 256),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate device IDs correctly', () {
        // Valid device IDs
        expect(() => Validators.validateDeviceId(1), returnsNormally);
        expect(() => Validators.validateDeviceId(12345), returnsNormally);
        expect(() => Validators.validateDeviceId(2147483647), returnsNormally);

        // Invalid device IDs
        expect(
          () => Validators.validateDeviceId(null),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => Validators.validateDeviceId(-1),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate messages correctly', () {
        // Valid messages
        expect(() => Validators.validateMessage('Hello, world!'), returnsNormally);
        expect(() => Validators.validateMessage('A' * 1000), returnsNormally);

        // Invalid messages
        expect(
          () => Validators.validateMessage(''),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => Validators.validateMessage(null),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => Validators.validateMessage('A' * (1024 * 1024 + 1)),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate group IDs correctly', () {
        // Valid group IDs
        expect(() => Validators.validateGroupId('group-123'), returnsNormally);
        expect(() => Validators.validateGroupId('group_test'), returnsNormally);

        // Invalid group IDs
        expect(
          () => Validators.validateGroupId(''),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => Validators.validateGroupId('group with spaces'),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => Validators.validateGroupId('a' * 256),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate Firebase URLs correctly', () {
        // Valid URLs
        expect(() => Validators.validateFirebaseUrl('https://test.firebaseio.com/'), returnsNormally);
        expect(() => Validators.validateFirebaseUrl('https://test-default-rtdb.firebaseio.com/'), returnsNormally);

        // Invalid URLs
        expect(
          () => Validators.validateFirebaseUrl(''),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => Validators.validateFirebaseUrl('not-a-url'),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => Validators.validateFirebaseUrl(null),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('Cross-Component Integration', () {
      test('should handle validation errors with proper logging', () {
        expect(() {
          try {
            Validators.validateUserId('');
          } catch (e) {
            SignalLogger.error('Validation failed: $e');
            rethrow;
          }
        }, throwsA(isA<ValidationException>()));
      });

      test('should create proper error context for debugging', () {
        try {
          Validators.validateDeviceId(-1);
          fail('Should have thrown ValidationException');
        } catch (e) {
          expect(e, isA<ValidationException>());
          final exception = e as ValidationException;
          expect(exception.message, contains('Device ID'));
          expect(exception.toString(), isNotEmpty);
        }
      });

      test('should handle exception chaining properly', () {
        Exception? originalException;
        try {
          Validators.validateMessage('');
        } catch (e) {
          originalException = e as Exception;
        }

        expect(originalException, isNotNull);
        expect(originalException, isA<ValidationException>());

        // Test that exceptions can be properly wrapped
        final wrappedException = StorageException(
          message: 'Storage operation failed due to validation error',
          code: 'STORAGE_VALIDATION',
          details: {'originalError': originalException.toString()},
        );

        expect(wrappedException.details!['originalError'], contains('Message'));
      });
    });

    group('Performance Integration', () {
      test('should handle rapid validation calls efficiently', () {
        final stopwatch = Stopwatch()..start();
        
        for (int i = 1; i <= 1000; i++) {
          Validators.validateDeviceId(i);
          Validators.validateUserId('user_$i');
          Validators.validateGroupId('group_$i');
        }
        
        stopwatch.stop();
        
        // Should complete within reasonable time (adjust threshold as needed)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('should handle rapid logging calls efficiently', () {
        final stopwatch = Stopwatch()..start();
        
        for (int i = 1; i <= 1000; i++) {
          SignalLogger.debug('Debug message $i');
          SignalLogger.info('Info message $i');
        }
        
        stopwatch.stop();
        
        // Logging should be very fast
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });
    });

    group('Error Recovery Integration', () {
      test('should recover gracefully from validation errors', () {
        final validUserIds = <String>[];
        final invalidUserIds = ['', 'user with spaces', 'a' * 256];
        
        for (final userId in ['valid1', 'valid2', ...invalidUserIds, 'valid3']) {
          try {
            Validators.validateUserId(userId);
            validUserIds.add(userId);
          } catch (e) {
            // Continue processing other user IDs
            SignalLogger.warning('Skipping invalid user ID: $userId');
          }
        }
        
        expect(validUserIds, hasLength(3));
        expect(validUserIds, containsAll(['valid1', 'valid2', 'valid3']));
      });

      test('should provide helpful error messages for debugging', () {
        final errors = <String>[];
        
        final testCases = [
          {'userId': '', 'deviceId': null, 'message': ''},
          {'userId': 'valid', 'deviceId': -1, 'message': 'valid'},
          {'userId': 'user with spaces', 'deviceId': 1, 'message': 'valid'},
        ];
        
        for (final testCase in testCases) {
          try {
            Validators.validateUserId(testCase['userId']! as String);
            Validators.validateDeviceId(testCase['deviceId'] as int?);
            Validators.validateMessage(testCase['message']! as String);
          } catch (e) {
            errors.add(e.toString());
          }
        }
        
        expect(errors, hasLength(3));
        expect(errors[0], contains('User ID'));
        expect(errors[1], contains('Device ID'));
        expect(errors[2], contains('User ID')); // The third case fails on user ID validation first
      });
    });

    group('Comprehensive Workflow Tests', () {
      test('should validate complete user registration flow', () {
        // Simulate user registration data
        final userData = {
          'userId': 'test-user-123',
          'deviceId': 12345,
          'groupId': 'test-group-456',
          'message': 'Hello, Signal!',
          'firebaseUrl': 'https://test-default-rtdb.firebaseio.com/',
        };

        // All validations should pass
        expect(() {
          Validators.validateUserId(userData['userId']! as String);
          Validators.validateDeviceId(userData['deviceId']! as int);
          Validators.validateGroupId(userData['groupId']! as String);
          Validators.validateMessage(userData['message']! as String);
          Validators.validateFirebaseUrl(userData['firebaseUrl']! as String);
          
          SignalLogger.info('User registration data validated successfully');
        }, returnsNormally);
      });

      test('should handle mixed validation results gracefully', () {
        final results = <String, bool>{};
        
        final testInputs = [
          {'type': 'userId', 'value': 'valid-user'},
          {'type': 'userId', 'value': ''},
          {'type': 'deviceId', 'value': 123},
          {'type': 'deviceId', 'value': -1},
          {'type': 'message', 'value': 'Hello'},
          {'type': 'message', 'value': null},
        ];

        for (final input in testInputs) {
          final key = '${input['type']}_${input['value']}';
          try {
            switch (input['type']) {
              case 'userId':
                Validators.validateUserId(input['value'] as String?);
                break;
              case 'deviceId':
                Validators.validateDeviceId(input['value'] as int?);
                break;
              case 'message':
                Validators.validateMessage(input['value'] as String?);
                break;
            }
            results[key] = true;
          } catch (e) {
            results[key] = false;
            SignalLogger.debug('Validation failed for $key: $e');
          }
        }

        // Check that we have expected results
        expect(results.length, equals(6));
        expect(results['userId_valid-user'], isTrue);
        expect(results['userId_'], isFalse);
        expect(results['deviceId_123'], isTrue);
        expect(results['deviceId_-1'], isFalse);
        expect(results['message_Hello'], isTrue);
        expect(results['message_null'], isFalse);
      });
    });
  });
}
