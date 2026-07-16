/// Thrown by `ApiClient` for any non-2xx response. Mirrors the backend's
/// `{"error": {"message": ..., "fields": ...}}` envelope (see
/// `backend/internal/httpapi/respond.go`): [fields] is only populated for
/// 400 validation errors, keyed by form field name.
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.fields = const {},
  });

  final int statusCode;
  final String message;
  final Map<String, String> fields;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode, $message)';
}
