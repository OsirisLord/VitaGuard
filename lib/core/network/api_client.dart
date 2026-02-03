import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

/// HTTP client with retry logic, error handling, and auth token management.
class ApiClient {
  final http.Client client;
  String? _accessToken;

  ApiClient({required this.client});

  /// Sets the access token for authenticated requests.
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  /// Common headers for all requests.
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  /// Performs a GET request.
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    return _executeWithRetry(() => client.get(uri, headers: _headers));
  }

  /// Performs a POST request.
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(endpoint);
    return _executeWithRetry(
      () => client.post(
        uri,
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      ),
    );
  }

  /// Performs a PUT request.
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(endpoint);
    return _executeWithRetry(
      () => client.put(
        uri,
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      ),
    );
  }

  /// Performs a PATCH request.
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(endpoint);
    return _executeWithRetry(
      () => client.patch(
        uri,
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      ),
    );
  }

  /// Performs a DELETE request.
  Future<Map<String, dynamic>> delete(String endpoint) async {
    final uri = _buildUri(endpoint);
    return _executeWithRetry(() => client.delete(uri, headers: _headers));
  }

  /// Uploads a file with multipart request.
  Future<Map<String, dynamic>> uploadFile(
    String endpoint, {
    required String filePath,
    required String fieldName,
    Map<String, String>? additionalFields,
  }) async {
    final uri = _buildUri(endpoint);
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(_headers);
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    if (additionalFields != null) {
      request.fields.addAll(additionalFields);
    }

    final streamedResponse = await request.send().timeout(
          AppConstants.connectionTimeout,
          onTimeout: () => throw const NetworkException(
            message: 'Request timed out',
            code: 'TIMEOUT',
          ),
        );

    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  /// Builds the full URI for an endpoint.
  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final baseUri = Uri.parse(ApiEndpoints.baseUrl);
    return Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.port,
      path: '${baseUri.path}$endpoint',
      queryParameters: queryParams,
    );
  }

  /// Executes a request with retry logic.
  Future<Map<String, dynamic>> _executeWithRetry(
    Future<http.Response> Function() request,
  ) async {
    int attempts = 0;
    Duration delay = const Duration(seconds: 1);

    while (attempts < AppConstants.maxRetries) {
      try {
        final response = await request().timeout(
          AppConstants.connectionTimeout,
          onTimeout: () => throw const NetworkException(
            message: 'Request timed out',
            code: 'TIMEOUT',
          ),
        );

        return _handleResponse(response);
      } on SocketException {
        attempts++;
        if (attempts >= AppConstants.maxRetries) {
          throw const NetworkException(
            message: 'No internet connection',
            code: 'NO_INTERNET',
          );
        }
        await Future<void>.delayed(delay);
        delay *= 2; // Exponential backoff
      } on NetworkException {
        attempts++;
        if (attempts >= AppConstants.maxRetries) {
          rethrow;
        }
        await Future<void>.delayed(delay);
        delay *= 2;
      }
    }

    throw const NetworkException(
      message: 'Request failed after retries',
      code: 'MAX_RETRIES_EXCEEDED',
    );
  }

  /// Handles the HTTP response and throws appropriate exceptions.
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty
        ? json.decode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message =
        body['message'] as String? ?? 'An error occurred';
    final code = body['code'] as String?;

    switch (response.statusCode) {
      case 400:
        throw ValidationException(
          message: message,
          code: code ?? 'BAD_REQUEST',
          fieldErrors: _parseFieldErrors(body),
        );
      case 401:
        throw AuthException(
          message: message,
          code: code ?? 'UNAUTHORIZED',
        );
      case 403:
        throw const PermissionException(
          message: 'You are not authorized to perform this action',
        );
      case 404:
        throw ServerException(
          message: message,
          code: code ?? 'NOT_FOUND',
          statusCode: 404,
        );
      case 422:
        throw ValidationException(
          message: message,
          code: code ?? 'VALIDATION_ERROR',
          fieldErrors: _parseFieldErrors(body),
        );
      case 429:
        throw const ServerException(
          message: 'Too many requests. Please try again later.',
          code: 'RATE_LIMITED',
          statusCode: 429,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        throw ServerException(
          message: 'Server error. Please try again later.',
          code: 'SERVER_ERROR',
          statusCode: response.statusCode,
        );
      default:
        throw ServerException(
          message: message,
          code: code ?? 'UNKNOWN_ERROR',
          statusCode: response.statusCode,
        );
    }
  }

  /// Parses field errors from validation response.
  Map<String, List<String>>? _parseFieldErrors(Map<String, dynamic> body) {
    final errors = body['errors'];
    if (errors == null) return null;

    if (errors is Map<String, dynamic>) {
      return errors.map((key, value) {
        if (value is List) {
          return MapEntry(key, value.cast<String>());
        }
        return MapEntry(key, [value.toString()]);
      });
    }

    return null;
  }
}
