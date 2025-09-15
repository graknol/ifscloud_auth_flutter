import 'package:flutter/material.dart';
import 'package:ifscloud_auth_flutter/ifscloud_auth_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IFS Cloud Auth Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthExamplePage(),
    );
  }
}

class AuthExamplePage extends StatefulWidget {
  const AuthExamplePage({super.key});

  @override
  State<AuthExamplePage> createState() => _AuthExamplePageState();
}

class _AuthExamplePageState extends State<AuthExamplePage> {
  late final IfsCloudAuthService _authService;
  IfsCloudAuthResult? _authResult;
  String _status = 'Not authenticated';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Configure your IFS Cloud authentication
    const config = IfsCloudAuthConfig(
      domain: 'your-company.ifscloud.com', // Replace with your IFS Cloud domain
      clientId: 'your-client-id',           // Replace with your OAuth2 client ID
      realm: 'ifs',                         // Usually 'ifs' for IFS Cloud
    );
    
    _authService = IfsCloudAuthService(config);
  }

  Future<void> _authenticate() async {
    setState(() {
      _isLoading = true;
      _status = 'Authenticating...';
    });

    try {
      final result = await _authService.authenticate();
      setState(() {
        _authResult = result;
        _status = 'Authenticated successfully!';
        _isLoading = false;
      });
    } on IfsCloudAuthUserCancelledException {
      setState(() {
        _status = 'Authentication cancelled by user';
        _isLoading = false;
      });
    } on IfsCloudAuthException catch (e) {
      setState(() {
        _status = 'Authentication failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshToken() async {
    if (_authResult?.refreshToken == null) {
      setState(() {
        _status = 'No refresh token available';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Refreshing token...';
    });

    try {
      final result = await _authService.refreshToken(_authResult!.refreshToken!);
      setState(() {
        _authResult = result;
        _status = 'Token refreshed successfully!';
        _isLoading = false;
      });
    } on IfsCloudAuthTokenRefreshException catch (e) {
      setState(() {
        _status = 'Token refresh failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
      _status = 'Logging out...';
    });

    try {
      await _authService.logout(idTokenHint: _authResult?.idToken);
      setState(() {
        _authResult = null;
        _status = 'Logged out successfully';
        _isLoading = false;
      });
    } on IfsCloudAuthException catch (e) {
      setState(() {
        _status = 'Logout failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IFS Cloud Auth Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    if (_authResult != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Token Info',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Has Access Token: ✅'),
                      Text('Has Refresh Token: ${_authResult!.refreshToken != null ? '✅' : '❌'}'),
                      Text('Has ID Token: ${_authResult!.idToken != null ? '✅' : '❌'}'),
                      Text('Is Expired: ${_authResult!.isExpired ? '❌' : '✅'}'),
                      if (_authResult!.accessTokenExpirationDateTime != null)
                        Text('Expires: ${_authResult!.accessTokenExpirationDateTime}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _authenticate,
              child: _isLoading 
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Authenticate'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: (_isLoading || _authResult?.refreshToken == null) 
                  ? null 
                  : _refreshToken,
              child: const Text('Refresh Token'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: (_isLoading || _authResult == null) ? null : _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Domain: ${_authService.config.domain}'),
                    Text('Client ID: ${_authService.config.clientId}'),
                    Text('Realm: ${_authService.config.realm}'),
                    Text('Scopes: ${_authService.config.scopes.join(', ')}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}