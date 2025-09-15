import 'package:flutter/material.dart';
import 'package:ifscloud_auth_flutter/ifscloud_auth_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configure your IFS Cloud authentication
    const config = IfsCloudAuthConfig(
      domain: 'your-company.ifscloud.com', // Replace with your IFS Cloud domain
      clientId: 'your-client-id',           // Replace with your OAuth2 client ID
      realm: 'ifs',                         // Usually 'ifs' for IFS Cloud
    );

    return MaterialApp(
      title: 'IFS Cloud Auth Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: IfsCloudAuthProvider(
        config: config,
        onRequireLogin: () {
          // This callback is triggered when user needs to log in
          // You can navigate to login screen here
          debugPrint('Login required - user will be redirected to login');
        },
        onAuthStateChanged: (state, result) {
          debugPrint('Auth state changed: $state');
        },
        onAuthError: (error) {
          debugPrint('Auth error: $error');
        },
        child: const AuthFlowApp(),
      ),
    );
  }
}

class AuthFlowApp extends StatelessWidget {
  const AuthFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return IfsCloudAuthStateBuilder(
      authenticated: (context, authResult) => const MainAppScreen(),
      unauthenticated: (context) => const LoginScreen(),
      loading: (context) => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Authenticating...'),
            ],
          ),
        ),
      ),
      error: (context, error) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 64),
              SizedBox(height: 16),
              Text('Authentication Error'),
              SizedBox(height: 8),
              Text(error.message, textAlign: TextAlign.center),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Retry authentication
                  IfsCloudAuthProvider.maybeOf(context).authenticate();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = IfsCloudAuthProvider.maybeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IFS Cloud Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome to IFS Cloud',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please sign in to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : () {
                    authProvider.authenticate();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign In with IFS Cloud'),
                ),
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
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Domain: your-company.ifscloud.com'),
                      Text('Client ID: your-client-id'),
                      Text('Realm: ifs'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = IfsCloudAuthProvider.maybeOf(context);
    final authResult = authProvider.authResult!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IFS Cloud App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
            },
          ),
        ],
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
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Authenticated Successfully',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Token Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildTokenInfo('Access Token', authResult.accessToken != null),
                    _buildTokenInfo('Refresh Token', authResult.refreshToken != null),
                    _buildTokenInfo('ID Token', authResult.idToken != null),
                    _buildTokenInfo('Token Valid', !authResult.isExpired),
                    if (authResult.accessTokenExpirationDateTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Expires: ${authResult.accessTokenExpirationDateTime}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Demo',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your access token is automatically included in HTTP requests. '
                      'The library handles 401 responses by refreshing tokens or '
                      'redirecting to login.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _simulateApiCall(context);
                      },
                      child: const Text('Test API Call'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: authProvider.isLoading ? null : () async {
                try {
                  await authProvider.refreshToken();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Token refreshed successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Token refresh failed: $e')),
                  );
                }
              },
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Refresh Token'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await authProvider.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenInfo(String label, bool hasValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            hasValue ? Icons.check : Icons.close,
            size: 16,
            color: hasValue ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text('$label: ${hasValue ? 'Available' : 'Not Available'}'),
        ],
      ),
    );
  }

  void _simulateApiCall(BuildContext context) {
    // Simulate an API call that might return 401
    final authProvider = IfsCloudAuthProvider.maybeOf(context);
    
    // Example of how you would handle 401 in a real HTTP call:
    // try {
    //   final response = await httpClient.get(apiUrl);
    //   if (response.statusCode == 401) {
    //     await authProvider.handleHttpError(401);
    //   }
    // } catch (e) {
    //   // Handle error
    // }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Simulated API call with token: ${authProvider.accessToken?.substring(0, 20)}...'
        ),
      ),
    );
  }
}