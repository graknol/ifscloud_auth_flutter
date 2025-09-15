# IFS Cloud Auth Flutter

A Flutter library that simplifies authentication with IFS Cloud using OpenID Connect. This library uses `flutter_appauth` to handle the OAuth2/OpenID Connect flow with PKCE (Proof Key for Code Exchange).

## Features

- ✅ OAuth2/OpenID Connect authentication with IFS Cloud
- ✅ Authorization Code flow with PKCE (default and recommended)
- ✅ Automatic discovery document fetching
- ✅ Token refresh functionality
- ✅ Logout support
- ✅ Simple configuration with sensible defaults
- ✅ **NEW**: AuthenticationProvider widget for state management
- ✅ **NEW**: Automatic HTTP 401 handling with token refresh
- ✅ **NEW**: Navigation helpers for login/logout flows

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  ifscloud_auth_flutter: ^1.0.0
```

## Configuration

### Android

Add the following to your `android/app/build.gradle` file in the `defaultConfig` section:

```gradle
android {
    defaultConfig {
        manifestPlaceholders += [
            'appAuthRedirectScheme': 'your.client.id'
        ]
    }
}
```

### iOS

Add the following to your `ios/Runner/Info.plist` file:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>your.client.id</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>your.client.id</string>
        </array>
    </dict>
</array>
```

## Usage

### Option 1: Using AuthenticationProvider (Recommended)

The simplest way to use this library is with the `IfsCloudAuthProvider` widget that manages authentication state automatically:

```dart
import 'package:flutter/material.dart';
import 'package:ifscloud_auth_flutter/ifscloud_auth_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = IfsCloudAuthConfig(
      domain: 'mycompany.ifscloud.com',
      clientId: 'your-client-id',
      realm: 'ifs',
    );

    return MaterialApp(
      home: IfsCloudAuthProvider(
        config: config,
        // Automatically handle 401s and redirect to login when needed
        onRequireLogin: () {
          // Navigate to login screen
          Navigator.pushNamed(context, '/login');
        },
        child: MyAuthApp(),
      ),
    );
  }
}

class MyAuthApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IfsCloudAuthStateBuilder(
      authenticated: (context, authResult) => MainScreen(),
      unauthenticated: (context) => LoginScreen(),
      loading: (context) => LoadingScreen(),
      error: (context, error) => ErrorScreen(error),
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = IfsCloudAuthProvider.maybeOf(context);
    
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => authProvider.authenticate(),
          child: Text('Sign In with IFS Cloud'),
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = IfsCloudAuthProvider.maybeOf(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: Text('Welcome! Token: ${authProvider.accessToken}'),
    );
  }
}
```

### Automatic HTTP 401 Handling

The provider automatically handles HTTP 401 responses. When your API returns 401, just call:

```dart
final authProvider = IfsCloudAuthProvider.maybeOf(context);
await authProvider.handleHttpError(401);
// The provider will automatically refresh the token or redirect to login
```

Or use the built-in HTTP client:

```dart
final httpClient = IfsCloudAuthHttpClient.fromContext(context);
final response = await httpClient.get(Uri.parse('https://api.example.com/data'));
// 401s are handled automatically!
```

### Option 2: Direct Service Usage

For more control, you can use the service directly:

```dart
import 'package:ifscloud_auth_flutter/ifscloud_auth_flutter.dart';

// Configure the authentication service
final config = IfsCloudAuthConfig(
  domain: 'mycompany.ifscloud.com',
  clientId: 'your-client-id',
  realm: 'ifs', // Optional, defaults to 'ifs'
);

final authService = IfsCloudAuthService(config);
```

### Authenticate

```dart
try {
  final result = await authService.authenticate();
  print('Access token: ${result.accessToken}');
  print('Refresh token: ${result.refreshToken}');
  print('ID token: ${result.idToken}');
} on IfsCloudAuthUserCancelledException {
  print('User cancelled authentication');
} on IfsCloudAuthException catch (e) {
  print('Authentication failed: $e');
}
```

### Refresh Token

```dart
try {
  final newResult = await authService.refreshToken(oldResult.refreshToken!);
  print('New access token: ${newResult.accessToken}');
} on IfsCloudAuthTokenRefreshException catch (e) {
  print('Token refresh failed: $e');
  // Need to re-authenticate
}
```

### Logout

```dart
try {
  await authService.logout(idTokenHint: result.idToken);
  print('Logged out successfully');
} on IfsCloudAuthException catch (e) {
  print('Logout failed: $e');
}
```

### Check Token Expiry

```dart
if (result.isExpired) {
  print('Token is expired');
}

if (result.willExpireWithin(Duration(minutes: 5))) {
  print('Token will expire soon, consider refreshing');
}
```

## Advanced Features

### Custom Navigation

Use the navigation helpers for custom flows:

```dart
// Navigate to login when authentication is required
IfsCloudAuthNavigator.requireLogin(
  context, 
  loginRoute: '/login',
  clearStack: true,
);

// Navigate to main app after successful login
IfsCloudAuthNavigator.navigateToApp(
  context,
  homeRoute: '/home',
  clearStack: true,
);
```

### Custom HTTP Interceptor

Create your own HTTP interceptor for different HTTP clients:

```dart
final interceptor = IfsCloudAuthInterceptor.fromContext(context);

// Add auth header to requests
final headers = <String, String>{};
interceptor.addAuthHeader(headers);

// Handle responses
await interceptor.handleResponse(response);
```

## Configuration Options

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `domain` | String | Yes | - | The domain name of your IFS Cloud instance |
| `clientId` | String | Yes | - | OAuth2 client ID for your application |
| `realm` | String | No | `'ifs'` | Keycloak realm name |
| `scopes` | List<String> | No | `['openid', 'profile', 'email']` | OAuth2 scopes to request |
| `redirectUriScheme` | String | No | `clientId://` | Custom redirect URI scheme |

### AuthenticationProvider Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `autoHandleTokenRefresh` | bool | `true` | Automatically refresh tokens when they expire |
| `tokenRefreshThreshold` | Duration | `5 minutes` | Refresh tokens when they expire within this duration |
| `onAuthStateChanged` | Function | - | Callback when authentication state changes |
| `onAuthError` | Function | - | Callback when authentication errors occur |
| `onRequireLogin` | Function | - | Callback when user needs to be redirected to login |

## Error Handling

The library provides specific exception types:

- `IfsCloudAuthUserCancelledException` - User cancelled the authentication
- `IfsCloudAuthFailedException` - Authentication failed
- `IfsCloudAuthTokenRefreshException` - Token refresh failed
- `IfsCloudAuthConfigException` - Invalid configuration
- `IfsCloudAuthDiscoveryException` - Discovery document fetch failed

## Dependencies

This library depends on:
- [flutter_appauth](https://pub.dev/packages/flutter_appauth) - Handles the OAuth2/OpenID Connect flow

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
