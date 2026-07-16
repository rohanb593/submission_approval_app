part of 'activity_cubit.dart';

enum ActivityStatus { initial, loading, success, failure }

class ActivityState extends Equatable {
  const ActivityState({
    this.status = ActivityStatus.initial,
    this.entries = const [],
    this.errorMessage,
  });

  final ActivityStatus status;
  final List<ActivityEntry> entries;
  final String? errorMessage;

  ActivityState copyWith({
    ActivityStatus? status,
    List<ActivityEntry>? entries,
    String? errorMessage,
  }) {
    return ActivityState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, entries, errorMessage];
}
