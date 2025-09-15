import 'package:flutter/material.dart';

import 'ifscloud_auth_provider.dart';

/// Navigation helper for authentication flows
class IfsCloudAuthNavigator {
  /// Navigate to login screen when authentication is required
  static void requireLogin(
    BuildContext context, {
    String? loginRoute,
    Widget? loginPage,
    bool clearStack = false,
  }) {
    if (loginRoute != null) {
      if (clearStack) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          loginRoute,
          (route) => false,
        );
      } else {
        Navigator.of(context).pushNamed(loginRoute);
      }
    } else if (loginPage != null) {
      if (clearStack) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => loginPage),
          (route) => false,
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => loginPage),
        );
      }
    } else {
      throw ArgumentError('Either loginRoute or loginPage must be provided');
    }
  }
  
  /// Navigate to main app after successful authentication
  static void navigateToApp(
    BuildContext context, {
    String? homeRoute,
    Widget? homePage,
    bool clearStack = true,
  }) {
    if (homeRoute != null) {
      if (clearStack) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          homeRoute,
          (route) => false,
        );
      } else {
        Navigator.of(context).pushNamed(homeRoute);
      }
    } else if (homePage != null) {
      if (clearStack) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => homePage),
          (route) => false,
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => homePage),
        );
      }
    } else {
      throw ArgumentError('Either homeRoute or homePage must be provided');
    }
  }
}

/// Widget that shows different content based on authentication state
class IfsCloudAuthStateBuilder extends StatelessWidget {
  /// Widget to show when user is authenticated
  final Widget Function(BuildContext context, IfsCloudAuthResult authResult) authenticated;
  
  /// Widget to show when user is not authenticated
  final Widget Function(BuildContext context) unauthenticated;
  
  /// Widget to show when authentication is in progress
  final Widget Function(BuildContext context)? loading;
  
  /// Widget to show when an error occurred
  final Widget Function(BuildContext context, IfsCloudAuthException error)? error;

  const IfsCloudAuthStateBuilder({
    super.key,
    required this.authenticated,
    required this.unauthenticated,
    this.loading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = IfsCloudAuthProvider.maybeOf(context);
    
    switch (authProvider.state) {
      case IfsCloudAuthState.authenticated:
        if (authProvider.authResult != null) {
          return authenticated(context, authProvider.authResult!);
        }
        return unauthenticated(context);
        
      case IfsCloudAuthState.authenticating:
      case IfsCloudAuthState.refreshing:
        return loading?.call(context) ?? 
               const Center(child: CircularProgressIndicator());
        
      case IfsCloudAuthState.error:
        if (authProvider.lastError != null && error != null) {
          return error!(context, authProvider.lastError!);
        }
        return unauthenticated(context);
        
      case IfsCloudAuthState.unauthenticated:
      default:
        return unauthenticated(context);
    }
  }
}