import 'package:flutter/material.dart';
import 'dart:async';

import 'ifscloud_auth_config.dart';
import 'ifscloud_auth_service.dart';
import 'ifscloud_auth_result.dart';
import 'ifscloud_auth_exception.dart';

/// Authentication state for the provider
enum IfsCloudAuthState {
  /// User is not authenticated
  unauthenticated,
  /// Authentication is in progress
  authenticating,
  /// User is authenticated
  authenticated,
  /// Token refresh is in progress
  refreshing,
  /// Authentication error occurred
  error,
}

/// Provider widget that manages IFS Cloud authentication state
class IfsCloudAuthProvider extends StatefulWidget {
  /// The authentication configuration
  final IfsCloudAuthConfig config;
  
  /// The child widget to render
  final Widget child;
  
  /// Optional callback when authentication state changes
  final void Function(IfsCloudAuthState state, IfsCloudAuthResult? result)? onAuthStateChanged;
  
  /// Optional callback when authentication errors occur
  final void Function(IfsCloudAuthException error)? onAuthError;
  
  /// Optional callback when user needs to be redirected to login
  final VoidCallback? onRequireLogin;
  
  /// Whether to automatically handle token refresh on 401 responses
  final bool autoHandleTokenRefresh;
  
  /// Duration before token expiry to trigger automatic refresh
  final Duration tokenRefreshThreshold;

  const IfsCloudAuthProvider({
    super.key,
    required this.config,
    required this.child,
    this.onAuthStateChanged,
    this.onAuthError,
    this.onRequireLogin,
    this.autoHandleTokenRefresh = true,
    this.tokenRefreshThreshold = const Duration(minutes: 5),
  });

  @override
  State<IfsCloudAuthProvider> createState() => _IfsCloudAuthProviderState();
  
  /// Get the authentication provider from the widget tree
  static IfsCloudAuthProviderState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_IfsCloudAuthInheritedWidget>()?.state;
  }
  
  /// Get the authentication provider from the widget tree (required)
  static IfsCloudAuthProviderState maybeOf(BuildContext context) {
    final state = of(context);
    if (state == null) {
      throw FlutterError(
        'IfsCloudAuthProvider.of() called with a context that does not contain an IfsCloudAuthProvider.\n'
        'No IfsCloudAuthProvider ancestor could be found starting from the context that was passed to '
        'IfsCloudAuthProvider.of(). This usually happens when the context provided is from a widget that '
        'is not a descendant of an IfsCloudAuthProvider widget.'
      );
    }
    return state;
  }
}

class _IfsCloudAuthProviderState extends State<IfsCloudAuthProvider> implements IfsCloudAuthProviderState {
  late final IfsCloudAuthService _authService;
  
  IfsCloudAuthState _state = IfsCloudAuthState.unauthenticated;
  IfsCloudAuthResult? _authResult;
  IfsCloudAuthException? _lastError;
  Timer? _tokenRefreshTimer;

  @override
  void initState() {
    super.initState();
    _authService = IfsCloudAuthService(widget.config);
    _scheduleTokenRefreshCheck();
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _IfsCloudAuthInheritedWidget(
      state: this,
      child: widget.child,
    );
  }

  void _setState(IfsCloudAuthState newState) {
    if (_state != newState) {
      setState(() {
        _state = newState;
      });
      widget.onAuthStateChanged?.call(_state, _authResult);
    }
  }

  void _setError(IfsCloudAuthException error) {
    setState(() {
      _lastError = error;
      _state = IfsCloudAuthState.error;
    });
    widget.onAuthError?.call(error);
  }

  void _scheduleTokenRefreshCheck() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_authResult != null && 
          _authResult!.willExpireWithin(widget.tokenRefreshThreshold) &&
          _state == IfsCloudAuthState.authenticated &&
          widget.autoHandleTokenRefresh) {
        _refreshTokenSilently();
      }
    });
  }

  Future<void> _refreshTokenSilently() async {
    if (_authResult?.refreshToken == null) {
      // No refresh token available, require re-authentication
      await logout();
      widget.onRequireLogin?.call();
      return;
    }

    try {
      _setState(IfsCloudAuthState.refreshing);
      final newResult = await _authService.refreshToken(_authResult!.refreshToken!);
      setState(() {
        _authResult = newResult;
        _lastError = null;
      });
      _setState(IfsCloudAuthState.authenticated);
    } on IfsCloudAuthTokenRefreshException catch (e) {
      // Token refresh failed, require re-authentication
      _setError(e);
      await logout();
      widget.onRequireLogin?.call();
    }
  }

  @override
  IfsCloudAuthState get state => _state;

  @override
  IfsCloudAuthResult? get authResult => _authResult;

  @override
  IfsCloudAuthException? get lastError => _lastError;

  @override
  bool get isAuthenticated => _state == IfsCloudAuthState.authenticated && _authResult != null;

  @override
  bool get isLoading => _state == IfsCloudAuthState.authenticating || _state == IfsCloudAuthState.refreshing;

  @override
  String? get accessToken => _authResult?.accessToken;

  @override
  Future<void> authenticate() async {
    try {
      _setState(IfsCloudAuthState.authenticating);
      final result = await _authService.authenticate();
      setState(() {
        _authResult = result;
        _lastError = null;
      });
      _setState(IfsCloudAuthState.authenticated);
    } on IfsCloudAuthUserCancelledException catch (e) {
      _setError(e);
      _setState(IfsCloudAuthState.unauthenticated);
    } on IfsCloudAuthException catch (e) {
      _setError(e);
    }
  }

  @override
  Future<void> refreshToken() async {
    if (_authResult?.refreshToken == null) {
      throw const IfsCloudAuthTokenRefreshException('No refresh token available');
    }

    try {
      _setState(IfsCloudAuthState.refreshing);
      final result = await _authService.refreshToken(_authResult!.refreshToken!);
      setState(() {
        _authResult = result;
        _lastError = null;
      });
      _setState(IfsCloudAuthState.authenticated);
    } on IfsCloudAuthTokenRefreshException catch (e) {
      _setError(e);
      await logout();
      widget.onRequireLogin?.call();
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      if (_authResult?.idToken != null) {
        await _authService.logout(idTokenHint: _authResult!.idToken);
      }
    } catch (e) {
      // Continue with logout even if remote logout fails
    } finally {
      setState(() {
        _authResult = null;
        _lastError = null;
      });
      _setState(IfsCloudAuthState.unauthenticated);
    }
  }

  @override
  Future<void> handleHttpError(int statusCode) async {
    if (statusCode == 401 && widget.autoHandleTokenRefresh) {
      if (_authResult?.refreshToken != null) {
        try {
          await refreshToken();
        } catch (e) {
          // Token refresh failed, user will be redirected to login
        }
      } else {
        // No refresh token, require re-authentication
        await logout();
        widget.onRequireLogin?.call();
      }
    }
  }
}

/// Interface for the authentication provider state
abstract class IfsCloudAuthProviderState {
  /// Current authentication state
  IfsCloudAuthState get state;
  
  /// Current authentication result (if authenticated)
  IfsCloudAuthResult? get authResult;
  
  /// Last error that occurred
  IfsCloudAuthException? get lastError;
  
  /// Whether the user is currently authenticated
  bool get isAuthenticated;
  
  /// Whether an authentication operation is in progress
  bool get isLoading;
  
  /// Current access token (if authenticated)
  String? get accessToken;
  
  /// Perform authentication
  Future<void> authenticate();
  
  /// Refresh the current token
  Future<void> refreshToken();
  
  /// Logout the current user
  Future<void> logout();
  
  /// Handle HTTP error responses (especially 401)
  Future<void> handleHttpError(int statusCode);
}

/// Inherited widget to provide authentication state down the widget tree
class _IfsCloudAuthInheritedWidget extends InheritedWidget {
  final IfsCloudAuthProviderState state;

  const _IfsCloudAuthInheritedWidget({
    required this.state,
    required super.child,
  });

  @override
  bool updateShouldNotify(_IfsCloudAuthInheritedWidget oldWidget) {
    return state.state != oldWidget.state.state ||
           state.authResult != oldWidget.state.authResult ||
           state.lastError != oldWidget.state.lastError;
  }
}