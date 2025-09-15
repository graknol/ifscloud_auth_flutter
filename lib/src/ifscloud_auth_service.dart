import 'package:flutter_appauth/flutter_appauth.dart';

import 'ifscloud_auth_config.dart';
import 'ifscloud_auth_result.dart';
import 'ifscloud_auth_exception.dart';

/// Main service for handling IFS Cloud authentication
class IfsCloudAuthService {
  final IfsCloudAuthConfig _config;
  final FlutterAppAuth _appAuth;

  /// Creates a new IFS Cloud authentication service
  IfsCloudAuthService(this._config) : _appAuth = const FlutterAppAuth();

  /// Internal constructor for testing
  IfsCloudAuthService.withAppAuth(this._config, this._appAuth);

  /// Performs the authentication flow using Authorization Code with PKCE
  /// 
  /// Returns [IfsCloudAuthResult] on success.
  /// Throws [IfsCloudAuthException] on error.
  Future<IfsCloudAuthResult> authenticate() async {
    try {
      _validateConfig();

      final AuthorizationTokenRequest request = AuthorizationTokenRequest(
        _config.clientId,
        _config.effectiveRedirectUriScheme,
        discoveryUrl: _config.discoveryUrl,
        scopes: _config.scopes,
        // Enable PKCE by default
        additionalParameters: {},
        promptValues: ['login'], // Force login prompt
      );

      final AuthorizationTokenResponse? result = await _appAuth.authorizeAndExchangeCode(request);

      if (result == null) {
        throw const IfsCloudAuthUserCancelledException();
      }

      return IfsCloudAuthResult.fromAppAuthResponse(result);
    } on FlutterAppAuthUserCancelledException {
      throw const IfsCloudAuthUserCancelledException();
    } on FlutterAppAuthPlatformException catch (e) {
      throw IfsCloudAuthFailedException(
        'Authentication failed: ${e.code}',
        details: e.message,
        originalError: e,
      );
    } catch (e) {
      throw IfsCloudAuthFailedException(
        'Unexpected authentication error',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  /// Refreshes the access token using the refresh token
  /// 
  /// Returns [IfsCloudAuthResult] with new tokens on success.
  /// Throws [IfsCloudAuthTokenRefreshException] on error.
  Future<IfsCloudAuthResult> refreshToken(String refreshToken) async {
    try {
      _validateConfig();

      final TokenRequest request = TokenRequest(
        _config.clientId,
        _config.effectiveRedirectUriScheme,
        refreshToken: refreshToken,
        discoveryUrl: _config.discoveryUrl,
      );

      final TokenResponse? result = await _appAuth.token(request);

      if (result == null) {
        throw const IfsCloudAuthTokenRefreshException('Token refresh returned null');
      }

      return IfsCloudAuthResult(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken ?? refreshToken, // Keep original if not provided
        idToken: result.idToken,
        tokenType: result.tokenType,
        accessTokenExpirationDateTime: result.accessTokenExpirationDateTime,
        tokenAdditionalParameters: result.additionalParameters,
      );
    } on FlutterAppAuthPlatformException catch (e) {
      throw IfsCloudAuthTokenRefreshException(
        'Token refresh failed: ${e.code}',
        details: e.message,
        originalError: e,
      );
    } catch (e) {
      throw IfsCloudAuthTokenRefreshException(
        'Unexpected token refresh error',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  /// Performs logout by clearing the session
  /// 
  /// [idTokenHint] - The ID token to use as a hint for logout
  /// [postLogoutRedirectUri] - Where to redirect after logout
  Future<void> logout({
    String? idTokenHint,
    String? postLogoutRedirectUri,
  }) async {
    try {
      _validateConfig();

      final EndSessionRequest request = EndSessionRequest(
        idTokenHint: idTokenHint,
        postLogoutRedirectUrl: postLogoutRedirectUri ?? _config.effectiveRedirectUriScheme,
        discoveryUrl: _config.discoveryUrl,
      );

      await _appAuth.endSession(request);
    } on FlutterAppAuthPlatformException catch (e) {
      throw IfsCloudAuthFailedException(
        'Logout failed: ${e.code}',
        details: e.message,
        originalError: e,
      );
    } catch (e) {
      throw IfsCloudAuthFailedException(
        'Unexpected logout error',
        details: e.toString(),
        originalError: e,
      );
    }
  }

  /// Validates the configuration
  void _validateConfig() {
    if (_config.domain.isEmpty) {
      throw const IfsCloudAuthConfigException('Domain cannot be empty');
    }
    if (_config.clientId.isEmpty) {
      throw const IfsCloudAuthConfigException('Client ID cannot be empty');
    }
    if (_config.realm.isEmpty) {
      throw const IfsCloudAuthConfigException('Realm cannot be empty');
    }
    if (_config.scopes.isEmpty) {
      throw const IfsCloudAuthConfigException('Scopes cannot be empty');
    }
  }

  /// Gets the current configuration
  IfsCloudAuthConfig get config => _config;
}