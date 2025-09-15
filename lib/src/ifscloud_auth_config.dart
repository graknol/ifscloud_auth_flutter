/// Configuration class for IFS Cloud authentication
class IfsCloudAuthConfig {
  /// The domain name of the IFS Cloud instance (e.g., "mycompany.ifscloud.com")
  final String domain;
  
  /// The name of the Keycloak realm (defaults to "ifs")
  final String realm;
  
  /// The OAuth2 client ID for your application
  final String clientId;
  
  /// Additional scopes to request (defaults to ["openid", "profile", "email"])
  final List<String> scopes;
  
  /// Custom redirect URI scheme (defaults to clientId with :// suffix)
  final String? redirectUriScheme;

  const IfsCloudAuthConfig({
    required this.domain,
    required this.clientId,
    this.realm = 'ifs',
    this.scopes = const ['openid', 'profile', 'email'],
    this.redirectUriScheme,
  });

  /// Gets the authorization endpoint URL
  String get authorizationEndpoint =>
      'https://$domain/auth/realms/$realm/protocol/openid-connect/auth';

  /// Gets the token endpoint URL  
  String get tokenEndpoint =>
      'https://$domain/auth/realms/$realm/protocol/openid-connect/token';

  /// Gets the discovery document URL
  String get discoveryUrl =>
      'https://$domain/auth/realms/$realm/.well-known/openid-configuration';

  /// Gets the end session endpoint URL
  String get endSessionEndpoint =>
      'https://$domain/auth/realms/$realm/protocol/openid-connect/logout';

  /// Gets the redirect URI scheme, using clientId as fallback
  String get effectiveRedirectUriScheme => redirectUriScheme ?? '$clientId://';

  @override
  String toString() {
    return 'IfsCloudAuthConfig(domain: $domain, realm: $realm, clientId: $clientId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is IfsCloudAuthConfig &&
        other.domain == domain &&
        other.realm == realm &&
        other.clientId == clientId &&
        other.scopes.length == scopes.length &&
        other.scopes.every((scope) => scopes.contains(scope)) &&
        other.redirectUriScheme == redirectUriScheme;
  }

  @override
  int get hashCode {
    return Object.hash(
      domain,
      realm,
      clientId,
      Object.hashAll(scopes),
      redirectUriScheme,
    );
  }
}