///API Client (Base)
///
/// Base class that provides common HTTP functionality.
/// All API services will extend class.
library;

import 'package:http/http.dart' as http;
import '../utils/constants.dart';

/// Base API Client
///
/// Provides shared HTTP client and helper methods.
/// Individual API services (goals, tracking, focus) extend this.
class ApiClient {
  final String baseUrl;
  final http.Client client;

  /// Constructor
  ApiClient({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? AppConstants.baseUrl,
        client = client ?? http.Client();

  // ============================================
  // Shared Helper Methods
  // ============================================

  /// Get common headers for all requests
  Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Handle HTTP errors
  ///
  /// Throws ApiException if status code indicates an error
  void handleError(http.Response response) {
    if (response.statusCode >= 400) {
      throw ApiException(
          statusCode: response.statusCode,
          message: 'API Error: ${response.body}');
    }
  }

  /// Build URI for API endpoints
  ///
  /// Helper method to construct URIs with consistent base URL.
  /// ALL API services can use this method.
  ///
  /// Parameters:
  ///   endpoint: Base endpoint (e.g., '/goals', '/tracking', 'focus')
  ///   path: Optional path to append (e.g., '/123' or '/today/list')
  ///   queryParams: Optional query parameters
  ///
  /// Returns: Compete URI for the request
  ///
  ///   buildUri('/goals')                     → http://localhost:8000/goals
  ///   buildUri('/goals', path: '/123')       → http://localhost:8000/goals/123
  ///   buildUri('/goals', queryParams: {...}) → http://localhost:8000/goals?skip=0
  Uri buildUri(
    String endpoint, {
    String path = '',
    Map<String, String>? queryParams,
  }) {
    final fullPath = '$baseUrl$endpoint$path';
    final uri = Uri.parse(fullPath);

    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }

    return uri;
  }

  /// Dispose resources
  void dispose() {
    client.close();
  }
}

/// API Exception
///
/// Throw when an API request fails
class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException({this.statusCode, required this.message});

  @override
  String toString() => 'ApiExceptio: $message (Status: $statusCode)';
}
