/// Base exception for IFS Cloud authentication errors
abstract class IfsCloudAuthException implements Exception {
  /// Error message
  final String message;
  
  /// Additional error details
  final String? details;
  
  /// Original error that caused this exception (if any)
  final Object? originalError;

  const IfsCloudAuthException(this.message, {this.details, this.originalError});

  @override
  String toString() => 'IfsCloudAuthException: $message${details != null ? ' ($details)' : ''}';
}

/// Exception thrown when user cancels the authentication flow
class IfsCloudAuthUserCancelledException extends IfsCloudAuthException {
  const IfsCloudAuthUserCancelledException()
      : super('User cancelled the authentication flow');
}

/// Exception thrown when authentication fails
class IfsCloudAuthFailedException extends IfsCloudAuthException {
  const IfsCloudAuthFailedException(super.message, {super.details, super.originalError});
}

/// Exception thrown when token refresh fails
class IfsCloudAuthTokenRefreshException extends IfsCloudAuthException {
  const IfsCloudAuthTokenRefreshException(super.message, {super.details, super.originalError});
}

/// Exception thrown when configuration is invalid
class IfsCloudAuthConfigException extends IfsCloudAuthException {
  const IfsCloudAuthConfigException(super.message, {super.details});
}

/// Exception thrown when discovery document cannot be fetched
class IfsCloudAuthDiscoveryException extends IfsCloudAuthException {
  const IfsCloudAuthDiscoveryException(super.message, {super.details, super.originalError});
}