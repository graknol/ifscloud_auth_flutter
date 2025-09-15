/// Result of a successful authentication
class IfsCloudAuthResult {
  /// The access token
  final String accessToken;
  
  /// The refresh token (if available)
  final String? refreshToken;
  
  /// The ID token containing user claims
  final String? idToken;
  
  /// The token type (usually "Bearer")
  final String? tokenType;
  
  /// When the access token expires
  final DateTime? accessTokenExpirationDateTime;
  
  /// Additional authorization response parameters
  final Map<String, dynamic>? authorizationAdditionalParameters;
  
  /// Additional token response parameters
  final Map<String, dynamic>? tokenAdditionalParameters;

  const IfsCloudAuthResult({
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    this.tokenType,
    this.accessTokenExpirationDateTime,
    this.authorizationAdditionalParameters,
    this.tokenAdditionalParameters,
  });

  /// Creates an IfsCloudAuthResult from flutter_appauth AuthorizationTokenResponse
  factory IfsCloudAuthResult.fromAppAuthResponse(dynamic response) {
    return IfsCloudAuthResult(
      accessToken: response.accessToken!,
      refreshToken: response.refreshToken,
      idToken: response.idToken,
      tokenType: response.tokenType,
      accessTokenExpirationDateTime: response.accessTokenExpirationDateTime,
      authorizationAdditionalParameters: response.authorizationAdditionalParameters,
      tokenAdditionalParameters: response.tokenAdditionalParameters,
    );
  }

  /// Whether the access token is expired
  bool get isExpired {
    if (accessTokenExpirationDateTime == null) return false;
    return DateTime.now().isAfter(accessTokenExpirationDateTime!);
  }

  /// Whether the access token will expire within the given duration
  bool willExpireWithin(Duration duration) {
    if (accessTokenExpirationDateTime == null) return false;
    return DateTime.now().add(duration).isAfter(accessTokenExpirationDateTime!);
  }

  @override
  String toString() {
    return 'IfsCloudAuthResult(accessToken: ${accessToken.substring(0, 20)}..., '
           'hasRefreshToken: ${refreshToken != null}, '
           'hasIdToken: ${idToken != null}, '
           'isExpired: $isExpired)';
  }
}