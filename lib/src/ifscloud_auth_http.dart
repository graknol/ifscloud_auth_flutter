import 'package:flutter/material.dart';
import 'dart:io';

import 'ifscloud_auth_provider.dart';

/// HTTP interceptor that automatically handles 401 responses by triggering token refresh
class IfsCloudAuthInterceptor {
  final IfsCloudAuthProviderState _authProvider;
  
  const IfsCloudAuthInterceptor(this._authProvider);
  
  /// Factory constructor to create interceptor from context
  factory IfsCloudAuthInterceptor.fromContext(BuildContext context) {
    final provider = IfsCloudAuthProvider.maybeOf(context);
    return IfsCloudAuthInterceptor(provider);
  }
  
  /// Handle HTTP response and check for 401 errors
  Future<void> handleResponse(HttpClientResponse response) async {
    if (response.statusCode == 401) {
      await _authProvider.handleHttpError(401);
    }
  }
  
  /// Get current access token for authorization header
  String? get authorizationHeader {
    final token = _authProvider.accessToken;
    return token != null ? 'Bearer $token' : null;
  }
  
  /// Add authorization header to request headers
  void addAuthHeader(Map<String, String> headers) {
    final authHeader = authorizationHeader;
    if (authHeader != null) {
      headers['Authorization'] = authHeader;
    }
  }
}

/// Utility class for common HTTP operations with automatic authentication
class IfsCloudAuthHttpClient {
  final IfsCloudAuthProviderState _authProvider;
  final HttpClient _httpClient;
  
  IfsCloudAuthHttpClient(this._authProvider) : _httpClient = HttpClient();
  
  /// Factory constructor to create client from context
  factory IfsCloudAuthHttpClient.fromContext(BuildContext context) {
    final provider = IfsCloudAuthProvider.maybeOf(context);
    return IfsCloudAuthHttpClient(provider);
  }
  
  /// Make an authenticated HTTP request
  Future<HttpClientResponse> request(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    String? body,
  }) async {
    // Ensure user is authenticated
    if (!_authProvider.isAuthenticated) {
      throw Exception('User not authenticated');
    }
    
    final request = await _httpClient.openUrl(method, uri);
    
    // Add authentication header
    final token = _authProvider.accessToken;
    if (token != null) {
      request.headers.add('Authorization', 'Bearer $token');
    }
    
    // Add custom headers
    headers?.forEach((key, value) {
      request.headers.add(key, value);
    });
    
    // Add body if provided
    if (body != null) {
      request.write(body);
    }
    
    final response = await request.close();
    
    // Handle 401 responses
    if (response.statusCode == 401) {
      await _authProvider.handleHttpError(401);
      
      // If user is still authenticated after handling 401, retry the request
      if (_authProvider.isAuthenticated && _authProvider.accessToken != token) {
        return request(method, uri, headers: headers, body: body);
      }
    }
    
    return response;
  }
  
  /// Make a GET request
  Future<HttpClientResponse> get(Uri uri, {Map<String, String>? headers}) {
    return request('GET', uri, headers: headers);
  }
  
  /// Make a POST request  
  Future<HttpClientResponse> post(Uri uri, {Map<String, String>? headers, String? body}) {
    return request('POST', uri, headers: headers, body: body);
  }
  
  /// Make a PUT request
  Future<HttpClientResponse> put(Uri uri, {Map<String, String>? headers, String? body}) {
    return request('PUT', uri, headers: headers, body: body);
  }
  
  /// Make a DELETE request
  Future<HttpClientResponse> delete(Uri uri, {Map<String, String>? headers}) {
    return request('DELETE', uri, headers: headers);
  }
  
  /// Close the HTTP client
  void close() {
    _httpClient.close();
  }
}