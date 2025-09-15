import 'package:flutter_test/flutter_test.dart';
import 'package:ifscloud_auth_flutter/src/ifscloud_auth_config.dart';
import 'package:ifscloud_auth_flutter/src/ifscloud_auth_service.dart';
import 'package:ifscloud_auth_flutter/src/ifscloud_auth_exception.dart';

void main() {
  group('IfsCloudAuthService', () {
    late IfsCloudAuthConfig config;

    setUp(() {
      config = const IfsCloudAuthConfig(
        domain: 'test.ifscloud.com',
        clientId: 'test-client',
      );
    });

    test('should create service with config', () {
      final service = IfsCloudAuthService(config);
      
      expect(service.config, equals(config));
    });

    test('should validate configuration on authenticate', () async {
      final invalidConfig = const IfsCloudAuthConfig(
        domain: '',
        clientId: 'test-client',
      );
      final service = IfsCloudAuthService(invalidConfig);

      expect(
        () async => await service.authenticate(),
        throwsA(isA<IfsCloudAuthConfigException>()),
      );
    });

    test('should validate configuration on refresh token', () async {
      final invalidConfig = const IfsCloudAuthConfig(
        domain: 'test.ifscloud.com',
        clientId: '',
      );
      final service = IfsCloudAuthService(invalidConfig);

      expect(
        () async => await service.refreshToken('test-refresh-token'),
        throwsA(isA<IfsCloudAuthConfigException>()),
      );
    });

    test('should validate configuration on logout', () async {
      final invalidConfig = const IfsCloudAuthConfig(
        domain: 'test.ifscloud.com',
        clientId: 'test-client',
        realm: '',
      );
      final service = IfsCloudAuthService(invalidConfig);

      expect(
        () async => await service.logout(),
        throwsA(isA<IfsCloudAuthConfigException>()),
      );
    });

    test('should validate that scopes are not empty', () async {
      final invalidConfig = const IfsCloudAuthConfig(
        domain: 'test.ifscloud.com',
        clientId: 'test-client',
        scopes: [],
      );
      final service = IfsCloudAuthService(invalidConfig);

      expect(
        () async => await service.authenticate(),
        throwsA(isA<IfsCloudAuthConfigException>()),
      );
    });
  });
}