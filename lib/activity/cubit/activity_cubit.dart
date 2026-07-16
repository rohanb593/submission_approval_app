import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:submission_approval_app/api/api_exception.dart';
import 'package:submission_approval_app/api/models/activity_entry.dart';
import 'package:submission_approval_app/api/repositories/activity_repository.dart';

part 'activity_state.dart';

/// Wraps the admin-only `/activity` endpoint: the most recent authenticated
/// HTTP requests, newest first (see `backend/internal/httpapi/activity_handlers.go`).
class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit({required ActivityRepository activityRepository})
    : _repo = activityRepository,
      super(const ActivityState());

  final ActivityRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: ActivityStatus.loading));
    try {
      final entries = await _repo.list();
      emit(state.copyWith(status: ActivityStatus.success, entries: entries));
    } on ApiException catch (e) {
      emit(
        state.copyWith(status: ActivityStatus.failure, errorMessage: e.message),
      );
    }
  }
}
