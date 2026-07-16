import 'package:submission_approval_app/api/models/application_status.dart';

/// Mirrors `applicationResponse` in `backend/internal/httpapi/application_handlers.go`.
class Application {
  const Application({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.category,
    required this.description,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) => Application(
    id: json['id'] as String,
    ownerId: json['owner_id'] as String,
    title: json['title'] as String,
    category: ApplicationCategory.fromJson(json['category'] as String),
    description: json['description'] as String,
    amount: (json['amount'] as num?)?.toDouble(),
    status: ApplicationStatus.fromJson(json['status'] as String),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  final String id;
  final String ownerId;
  final String title;
  final ApplicationCategory category;
  final String description;
  final double? amount;
  final ApplicationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// Mirrors `auditEntryResponse`.
class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.actorId,
    required this.actorEmail,
    required this.fromStatus,
    required this.toStatus,
    required this.comment,
    required this.createdAt,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> json) => AuditEntry(
    id: json['id'] as String,
    actorId: json['actor_id'] as String,
    actorEmail: json['actor_email'] as String,
    fromStatus: json['from_status'] as String,
    toStatus: json['to_status'] as String,
    comment: json['comment'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  final String id;
  final String actorId;
  final String actorEmail;
  final String fromStatus;
  final String toStatus;
  final String? comment;
  final DateTime createdAt;
}

/// Mirrors `applicationDetailResponse`: one application plus its full audit
/// trail, returned by `GET /applications/{id}`.
class ApplicationDetail {
  const ApplicationDetail({required this.application, required this.auditLog});

  factory ApplicationDetail.fromJson(Map<String, dynamic> json) =>
      ApplicationDetail(
        application: Application.fromJson(json),
        auditLog: (json['audit_log'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(AuditEntry.fromJson)
            .toList(),
      );

  final Application application;
  final List<AuditEntry> auditLog;
}

/// Mirrors `applicationListResponse`: one page of applications plus the
/// total match count and a status->count breakdown (for dashboard stat
/// cards) that ignores the current filter.
class ApplicationPage {
  const ApplicationPage({
    required this.applications,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.counts,
  });

  factory ApplicationPage.fromJson(Map<String, dynamic> json) =>
      ApplicationPage(
        applications: (json['applications'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(Application.fromJson)
            .toList(),
        total: json['total'] as int,
        page: json['page'] as int,
        pageSize: json['page_size'] as int,
        counts: (json['counts'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, v as int),
        ),
      );

  final List<Application> applications;
  final int total;
  final int page;
  final int pageSize;
  final Map<String, int> counts;
}
