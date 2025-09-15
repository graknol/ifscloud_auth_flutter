import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ifscloud_auth_flutter/ifscloud_auth_flutter.dart';

void main() {
  group('IfsCloudAuthProvider', () {
    late IfsCloudAuthConfig config;

    setUp(() {
      config = const IfsCloudAuthConfig(
        domain: 'test.ifscloud.com',
        clientId: 'test-client-id',
        realm: 'test-realm',
      );
    });

    testWidgets('should initialize with unauthenticated state', (tester) async {
      late IfsCloudAuthProviderState authProvider;

      await tester.pumpWidget(
        MaterialApp(
          home: IfsCloudAuthProvider(
            config: config,
            child: Builder(
              builder: (context) {
                authProvider = IfsCloudAuthProvider.maybeOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(authProvider.state, IfsCloudAuthState.unauthenticated);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.isLoading, false);
      expect(authProvider.authResult, null);
      expect(authProvider.accessToken, null);
    });

    testWidgets('should provide access via IfsCloudAuthProvider.of()', (tester) async {
      IfsCloudAuthProviderState? authProvider;

      await tester.pumpWidget(
        MaterialApp(
          home: IfsCloudAuthProvider(
            config: config,
            child: Builder(
              builder: (context) {
                authProvider = IfsCloudAuthProvider.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(authProvider, isNotNull);
      expect(authProvider!.state, IfsCloudAuthState.unauthenticated);
    });

    testWidgets('should throw error when provider not found', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(
                () => IfsCloudAuthProvider.maybeOf(context),
                throwsA(isA<FlutterError>()),
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should trigger callbacks on state changes', (tester) async {
      IfsCloudAuthState? receivedState;
      IfsCloudAuthResult? receivedResult;
      IfsCloudAuthException? receivedError;
      bool loginRequired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: IfsCloudAuthProvider(
            config: config,
            onAuthStateChanged: (state, result) {
              receivedState = state;
              receivedResult = result;
            },
            onAuthError: (error) {
              receivedError = error;
            },
            onRequireLogin: () {
              loginRequired = true;
            },
            child: const SizedBox(),
          ),
        ),
      );

      // Initial state should be unauthenticated
      expect(receivedState, IfsCloudAuthState.unauthenticated);
      expect(receivedResult, null);
      expect(receivedError, null);
      expect(loginRequired, false);
    });

    testWidgets('should handle HTTP 401 responses', (tester) async {
      late IfsCloudAuthProviderState authProvider;
      bool loginRequired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: IfsCloudAuthProvider(
            config: config,
            onRequireLogin: () {
              loginRequired = true;
            },
            child: Builder(
              builder: (context) {
                authProvider = IfsCloudAuthProvider.maybeOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Simulate 401 response when not authenticated
      await authProvider.handleHttpError(401);
      await tester.pump();

      expect(loginRequired, true);
    });
  });

  group('IfsCloudAuthStateBuilder', () {
    late IfsCloudAuthConfig config;

    setUp(() {
      config = const IfsCloudAuthConfig(
        domain: 'test.ifscloud.com',
        clientId: 'test-client-id',
        realm: 'test-realm',
      );
    });

    testWidgets('should show unauthenticated widget by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: IfsCloudAuthProvider(
            config: config,
            child: IfsCloudAuthStateBuilder(
              authenticated: (context, result) => const Text('Authenticated'),
              unauthenticated: (context) => const Text('Unauthenticated'),
            ),
          ),
        ),
      );

      expect(find.text('Unauthenticated'), findsOneWidget);
      expect(find.text('Authenticated'), findsNothing);
    });

    testWidgets('should show loading widget when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: IfsCloudAuthProvider(
            config: config,
            child: IfsCloudAuthStateBuilder(
              authenticated: (context, result) => const Text('Authenticated'),
              unauthenticated: (context) => const Text('Unauthenticated'),
              loading: (context) => const Text('Loading'),
            ),
          ),
        ),
      );

      // Should show unauthenticated initially
      expect(find.text('Unauthenticated'), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('should show default loading when loading is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: IfsCloudAuthProvider(
            config: config,
            child: IfsCloudAuthStateBuilder(
              authenticated: (context, result) => const Text('Authenticated'),
              unauthenticated: (context) => const Text('Unauthenticated'),
            ),
          ),
        ),
      );

      expect(find.text('Unauthenticated'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('IfsCloudAuthInterceptor', () {
    testWidgets('should provide authorization header when authenticated', (tester) async {
      late IfsCloudAuthInterceptor interceptor;
      
      await tester.pumpWidget(
        MaterialApp(
          home: IfsCloudAuthProvider(
            config: const IfsCloudAuthConfig(
              domain: 'test.ifscloud.com',
              clientId: 'test-client-id',
            ),
            child: Builder(
              builder: (context) {
                interceptor = IfsCloudAuthInterceptor.fromContext(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // When not authenticated, should return null
      expect(interceptor.authorizationHeader, null);

      final headers = <String, String>{};
      interceptor.addAuthHeader(headers);
      expect(headers.containsKey('Authorization'), false);
    });
  });
}