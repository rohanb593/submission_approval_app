import 'package:submission_approval_app/api/models/app_role.dart';

/// Covers both `userResponse` (from `/auth/login*`, no `created_at`) and
/// `userAdminResponse` (from `/admin/users`, includes `created_at`) in
/// `backend/internal/httpapi/*_handlers.go` — [createdAt] is null for the
/// former.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.role,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    email: json['email'] as String,
    role: AppRole.fromJson(json['role'] as String),
    createdAt: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at'] as String),
  );

  final String id;
  final String email;
  final AppRole role;
  final DateTime? createdAt;
}
