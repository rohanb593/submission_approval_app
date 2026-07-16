import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:submission_approval_app/api/api_exception.dart';
import 'package:submission_approval_app/api/token_storage.dart';

/// Thin JSON/HTTP wrapper around the Go backend
/// (`backend/internal/httpapi/router.go`): attaches the bearer token from
/// [TokenStorage] to every request and translates the backend's
/// `{"error": {...}}` envelope into an [ApiException]. Holds no business
/// logic — that lives in the per-feature repositories that call it.
class ApiClient {
  ApiClient({
    required this._baseUrl,
    required this._tokenStorage,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final TokenStorage _tokenStorage;
  final http.Client _httpClient;

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, {Object? body}) =>
      _send('POST', path, body: body);

  Future<dynamic> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl$path',
    ).replace(queryParameters: query?.isEmpty ?? true ? null : query);

    final token = _tokenStorage.currentToken;
    final request = http.Request(method, uri)
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'application/json';
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    if (body != null) {
      request.body = jsonEncode(body);
    }

    final streamed = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamed);
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    final raw = response.body;
    final decoded = raw.isEmpty ? null : jsonDecode(raw);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final error = decoded is Map<String, dynamic>
        ? decoded['error'] as Map<String, dynamic>?
        : null;
    final rawFields = error?['fields'] as Map<String, dynamic>?;

    throw ApiException(
      statusCode: response.statusCode,
      message: error?['message'] as String? ?? 'Something went wrong',
      fields: rawFields?.map((k, v) => MapEntry(k, v as String)) ?? const {},
    );
  }
}
