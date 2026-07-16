/// Mirrors `activityResponse` in `backend/internal/httpapi/activity_handlers.go`
/// — one authenticated HTTP request, for the admin-only activity audit view.
class ActivityEntry {
  const ActivityEntry({
    required this.id,
    required this.actorId,
    required this.actorEmail,
    required this.actorRole,
    required this.method,
    required this.path,
    required this.statusCode,
    required this.durationMs,
    required this.browser,
    required this.ipAddress,
    required this.userAgent,
    required this.referer,
    required this.contentLength,
    required this.createdAt,
  });

  factory ActivityEntry.fromJson(Map<String, dynamic> json) => ActivityEntry(
    id: json['id'] as String,
    actorId: json['actor_id'] as String,
    actorEmail: json['actor_email'] as String,
    actorRole: json['actor_role'] as String,
    method: json['method'] as String,
    path: json['path'] as String,
    statusCode: json['status_code'] as int,
    durationMs: json['duration_ms'] as int,
    browser: json['browser'] as String,
    ipAddress: json['ip_address'] as String,
    userAgent: json['user_agent'] as String,
    referer: json['referer'] as String,
    contentLength: json['content_length'] as int,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  final String id;
  final String actorId;
  final String actorEmail;
  final String actorRole;
  final String method;
  final String path;
  final int statusCode;
  final int durationMs;
  final String browser;
  final String ipAddress;
  final String userAgent;
  final String referer;
  final int contentLength;
  final DateTime createdAt;
}
