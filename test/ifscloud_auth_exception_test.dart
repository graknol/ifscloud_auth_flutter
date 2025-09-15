import 'package:flutter_test/flutter_test.dart';
import 'package:ifscloud_auth_flutter/src/ifscloud_auth_exception.dart';

void main() {
  group('IfsCloudAuthException', () {
    test('IfsCloudAuthUserCancelledException should have correct message', () {
      const exception = IfsCloudAuthUserCancelledException();
      
      expect(exception.message, equals('User cancelled the authentication flow'));
      expect(exception.details, isNull);
      expect(exception.originalError, isNull);
    });

    test('IfsCloudAuthFailedException should store message and details', () {
      const exception = IfsCloudAuthFailedException(
        'Authentication failed',
        details: 'Invalid credentials',
        originalError: 'Original error',
      );
      
      expect(exception.message, equals('Authentication failed'));
      expect(exception.details, equals('Invalid credentials'));
      expect(exception.originalError, equals('Original error'));
    });

    test('IfsCloudAuthTokenRefreshException should store message and details', () {
      const exception = IfsCloudAuthTokenRefreshException(
        'Token refresh failed',
        details: 'Refresh token expired',
        originalError: 'Original error',
      );
      
      expect(exception.message, equals('Token refresh failed'));
      expect(exception.details, equals('Refresh token expired'));
      expect(exception.originalError, equals('Original error'));
    });

    test('IfsCloudAuthConfigException should store message and details', () {
      const exception = IfsCloudAuthConfigException(
        'Configuration error',
        details: 'Missing client ID',
      );
      
      expect(exception.message, equals('Configuration error'));
      expect(exception.details, equals('Missing client ID'));
    });

    test('IfsCloudAuthDiscoveryException should store message and details', () {
      const exception = IfsCloudAuthDiscoveryException(
        'Discovery failed',
        details: 'Network error',
        originalError: 'Connection timeout',
      );
      
      expect(exception.message, equals('Discovery failed'));
      expect(exception.details, equals('Network error'));
      expect(exception.originalError, equals('Connection timeout'));
    });

    test('toString should include message only when no details', () {
      const exception = IfsCloudAuthFailedException('Test error');
      
      expect(exception.toString(), equals('IfsCloudAuthException: Test error'));
    });

    test('toString should include message and details when available', () {
      const exception = IfsCloudAuthFailedException(
        'Test error',
        details: 'Additional info',
      );
      
      expect(exception.toString(), equals('IfsCloudAuthException: Test error (Additional info)'));
    });
  });
}