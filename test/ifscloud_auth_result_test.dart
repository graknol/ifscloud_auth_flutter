import 'package:flutter_test/flutter_test.dart';
import 'package:ifscloud_auth_flutter/src/ifscloud_auth_result.dart';

void main() {
  group('IfsCloudAuthResult', () {
    test('should create result with required access token', () {
      const result = IfsCloudAuthResult(
        accessToken: 'test-access-token',
      );

      expect(result.accessToken, equals('test-access-token'));
      expect(result.refreshToken, isNull);
      expect(result.idToken, isNull);
      expect(result.tokenType, isNull);
      expect(result.accessTokenExpirationDateTime, isNull);
    });

    test('should create result with all parameters', () {
      final expirationTime = DateTime.now().add(const Duration(hours: 1));
      final result = IfsCloudAuthResult(
        accessToken: 'test-access-token',
        refreshToken: 'test-refresh-token',
        idToken: 'test-id-token',
        tokenType: 'Bearer',
        accessTokenExpirationDateTime: expirationTime,
        authorizationAdditionalParameters: {'param1': 'value1'},
        tokenAdditionalParameters: {'param2': 'value2'},
      );

      expect(result.accessToken, equals('test-access-token'));
      expect(result.refreshToken, equals('test-refresh-token'));
      expect(result.idToken, equals('test-id-token'));
      expect(result.tokenType, equals('Bearer'));
      expect(result.accessTokenExpirationDateTime, equals(expirationTime));
      expect(result.authorizationAdditionalParameters, equals({'param1': 'value1'}));
      expect(result.tokenAdditionalParameters, equals({'param2': 'value2'}));
    });

    test('isExpired should return false when no expiration time', () {
      const result = IfsCloudAuthResult(
        accessToken: 'test-access-token',
      );

      expect(result.isExpired, isFalse);
    });

    test('isExpired should return false when token is not expired', () {
      final expirationTime = DateTime.now().add(const Duration(hours: 1));
      final result = IfsCloudAuthResult(
        accessToken: 'test-access-token',
        accessTokenExpirationDateTime: expirationTime,
      );

      expect(result.isExpired, isFalse);
    });

    test('isExpired should return true when token is expired', () {
      final expirationTime = DateTime.now().subtract(const Duration(hours: 1));
      final result = IfsCloudAuthResult(
        accessToken: 'test-access-token',
        accessTokenExpirationDateTime: expirationTime,
      );

      expect(result.isExpired, isTrue);
    });

    test('willExpireWithin should return false when no expiration time', () {
      const result = IfsCloudAuthResult(
        accessToken: 'test-access-token',
      );

      expect(result.willExpireWithin(const Duration(minutes: 5)), isFalse);
    });

    test('willExpireWithin should return false when token expires later', () {
      final expirationTime = DateTime.now().add(const Duration(hours: 1));
      final result = IfsCloudAuthResult(
        accessToken: 'test-access-token',
        accessTokenExpirationDateTime: expirationTime,
      );

      expect(result.willExpireWithin(const Duration(minutes: 5)), isFalse);
    });

    test('willExpireWithin should return true when token expires soon', () {
      final expirationTime = DateTime.now().add(const Duration(minutes: 2));
      final result = IfsCloudAuthResult(
        accessToken: 'test-access-token',
        accessTokenExpirationDateTime: expirationTime,
      );

      expect(result.willExpireWithin(const Duration(minutes: 5)), isTrue);
    });

    test('toString should contain truncated access token and status info', () {
      const result = IfsCloudAuthResult(
        accessToken: 'very-long-test-access-token-that-should-be-truncated',
        refreshToken: 'test-refresh-token',
        idToken: 'test-id-token',
      );

      final toString = result.toString();
      expect(toString, contains('very-long-test-access'));
      expect(toString, contains('hasRefreshToken: true'));
      expect(toString, contains('hasIdToken: true'));
      expect(toString, contains('isExpired: false'));
    });

    test('toString should show when tokens are missing', () {
      const result = IfsCloudAuthResult(
        accessToken: 'test-access-token',
      );

      final toString = result.toString();
      expect(toString, contains('hasRefreshToken: false'));
      expect(toString, contains('hasIdToken: false'));
    });
  });
}