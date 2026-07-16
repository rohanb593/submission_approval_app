/// Mirrors `workflow.Status` in `backend/internal/workflow/state_machine.go`.
enum ApplicationStatus {
  draft,
  submitted,
  underReview,
  approved,
  rejected;

  static ApplicationStatus fromJson(String value) => switch (value) {
    'DRAFT' => ApplicationStatus.draft,
    'SUBMITTED' => ApplicationStatus.submitted,
    'UNDER_REVIEW' => ApplicationStatus.underReview,
    'APPROVED' => ApplicationStatus.approved,
    'REJECTED' => ApplicationStatus.rejected,
    _ => throw ArgumentError('Unknown status: $value'),
  };

  String toJson() => switch (this) {
    ApplicationStatus.draft => 'DRAFT',
    ApplicationStatus.submitted => 'SUBMITTED',
    ApplicationStatus.underReview => 'UNDER_REVIEW',
    ApplicationStatus.approved => 'APPROVED',
    ApplicationStatus.rejected => 'REJECTED',
  };

  String get label => switch (this) {
    ApplicationStatus.draft => 'Draft',
    ApplicationStatus.submitted => 'Submitted',
    ApplicationStatus.underReview => 'Under review',
    ApplicationStatus.approved => 'Approved',
    ApplicationStatus.rejected => 'Rejected',
  };
}

/// Mirrors the `category` check constraint on `models.Application`.
enum ApplicationCategory {
  travel,
  equipment,
  training,
  other;

  static ApplicationCategory fromJson(String value) => switch (value) {
    'travel' => ApplicationCategory.travel,
    'equipment' => ApplicationCategory.equipment,
    'training' => ApplicationCategory.training,
    'other' => ApplicationCategory.other,
    _ => throw ArgumentError('Unknown category: $value'),
  };

  String toJson() => name;
}
