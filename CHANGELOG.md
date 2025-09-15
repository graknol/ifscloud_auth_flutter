# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-09-15

### Added
- Initial release of IFS Cloud Auth Flutter library
- Support for OAuth2/OpenID Connect authentication with IFS Cloud
- Authorization Code flow with PKCE (Proof Key for Code Exchange)
- Automatic discovery document fetching from IFS Cloud/Keycloak
- Token refresh functionality
- Logout support
- Configurable domain, realm, and client ID
- Comprehensive error handling with specific exception types
- Support for custom scopes and redirect URI schemes
- Built on top of flutter_appauth for robust OAuth2 implementation