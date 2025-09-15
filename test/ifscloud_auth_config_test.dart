import 'package:flutter_test/flutter_test.dart';
import 'package:ifscloud_auth_flutter/src/ifscloud_auth_config.dart';

void main() {
  group('IfsCloudAuthConfig', () {
    test('should create config with required parameters', () {
      const config = IfsCloudAuthConfig(
        domain: 'test.ifscloud.com',
        clientId: 'test-client',
      );

      expect(config.domain, equals('test.ifscloud.com'));
      expect(config.clientId, equals('test-client'));
      expect(config.realm, equals('ifs')); // default value
      expect(config.scopes, equals(['openid', 'profile', 'email'])); // default value
    });

    test('should create config with custom parameters', () {
      const config = IfsCloudAuthConfig(
        domain: 'custom.ifscloud.com',
        clientId: 'custom-client',
        realm: 'custom-realm',
        scopes: ['openid', 'custom'],
        redirectUriScheme: 'custom-scheme://',
      );

      expect(config.domain, equals('custom.ifscloud.com'));
      expect(config.clientId, equals('custom-client'));
      expect(config.realm, equals('custom-realm'));
      expect(config.scopes, equals(['openid', 'custom']));
      expect(config.redirectUriScheme, equals('custom-scheme://'));
    });

    test('should generate correct endpoint URLs', () {
      const config = IfsCloudAuthConfig(
        domain: 'test.ifscloud.com',
        clientId: 'test-client',
      );

      expect(
        config.authorizationEndpoint,
        equals('https://test.ifscloud.com/auth/realms/ifs/protocol/openid-connect/auth'),
      );
      expect(
        config.tokenEndpoint,
        equals('https://test.ifscloud.com/auth/realms/ifs/protocol/openid-connect/token'),
      );
      expect(
        config.discoveryUrl,
        equals('https://test.ifscloud.com/auth/realms/ifs/.well-known/openid-configuration'),
      );
      expect(
        config.endSessionEndpoint,
        equals('https://test.ifscloud.com/auth/realms/ifs/protocol/openid-connect/logout'),
      );
    });

    test('should generate correct endpoint URLs with custom realm', () {
      const config = IfsCloudAuthConfig(
        domain: 'test.ifscloud.com',
        clientId: 'test-client',
        realm: 'custom',
      );

      expect(
        config.authorizationEndpoint,
        equals('https://test.ifscloud.com/auth/realms/custom/protocol/openid-connect/auth'),
      );
      expect(
        config.discoveryUrl,
        equals('https://test.ifscloud.com/auth/realms/custom/.well-known/openid-configuration'),
      );
    });

    test('should use clientId as redirect URI scheme when not specified', () {
      const config = IfsCloudAuthConfig(
        domain: 'test.ifscloud.com',
        clientId: 'test-client',
      );

      expect(config.effectiveRedirectUriScheme, equals('test-client://'));
    });

    test('should use custom redirect URI scheme when specified', () {
      const config = IfsCloudAuthConfig(
        domain: 'test.ifscloud.com',
        clientId: 'test-client',
        redirectUriScheme: 'custom://scheme',
      );

      expect(config.effectiveRedirectUriScheme, equals('custom://scheme'));
    });

    test('should support equality comparison', () {
      const config1 = IfsCloudAuthConfig(
        domain: 'test.ifscloud.com',
        clientId: 'test-client',
      );
      const config2 = IfsCloudAuthConfig(
        domain: 'test.ifscloud.com',
        clientId: 'test-client',
      );
      const config3 = IfsCloudAuthConfig(
        domain: 'different.ifscloud.com',
        clientId: 'test-client',
      );

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test('should have consistent hashCode for equal objects', () {
      const config1 = IfsCloudAuthConfig(
        domain: 'test.ifscloud.com',
        clientId: 'test-client',
      );
      const config2 = IfsCloudAuthConfig(
        domain: 'test.ifscloud.com',
        clientId: 'test-client',
      );

      expect(config1.hashCode, equals(config2.hashCode));
    });

    test('toString should contain key information', () {
      const config = IfsCloudAuthConfig(
        domain: 'test.ifscloud.com',
        clientId: 'test-client',
        realm: 'custom',
      );

      final toString = config.toString();
      expect(toString, contains('test.ifscloud.com'));
      expect(toString, contains('test-client'));
      expect(toString, contains('custom'));
    });
  });
}