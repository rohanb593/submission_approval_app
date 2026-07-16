/// Mirrors `workflow.Role` in the backend (`backend/internal/workflow/state_machine.go`).
enum AppRole {
  requester,
  reviewer,
  admin;

  static AppRole fromJson(String value) => switch (value) {
    'requester' => AppRole.requester,
    'reviewer' => AppRole.reviewer,
    'admin' => AppRole.admin,
    _ => throw ArgumentError('Unknown role: $value'),
  };

  String toJson() => name;
}
