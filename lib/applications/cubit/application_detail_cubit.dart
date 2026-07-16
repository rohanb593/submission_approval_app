import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:submission_approval_app/api/api_exception.dart';
import 'package:submission_approval_app/api/models/application.dart';
import 'package:submission_approval_app/api/repositories/application_repository.dart';

part 'application_detail_state.dart';

/// Loads one application plus its audit trail and performs the workflow
/// transitions on it (see `backend/internal/workflow/state_machine.go` for
/// which actions are legal from which status/role — the backend is the
/// source of truth; this cubit just surfaces whatever it rejects).
class ApplicationDetailCubit extends Cubit<ApplicationDetailState> {
  ApplicationDetailCubit({
    required ApplicationRepository applicationRepository,
    required String applicationId,
  }) : _repo = applicationRepository,
       _id = applicationId,
       super(const ApplicationDetailState());

  final ApplicationRepository _repo;
  final String _id;

  Future<void> load() async {
    emit(const ApplicationDetailState());
    try {
      final detail = await _repo.get(_id);
      emit(
        ApplicationDetailState(
          status: ApplicationDetailStatus.success,
          detail: detail,
        ),
      );
    } on ApiException catch (e) {
      emit(
        ApplicationDetailState(
          status: ApplicationDetailStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<bool> submit() => _act(() => _repo.submit(_id));

  Future<bool> startReview() => _act(() => _repo.startReview(_id));

  Future<bool> approve({String comment = ''}) =>
      _act(() => _repo.approve(_id, comment: comment));

  Future<bool> reject({required String comment}) =>
      _act(() => _repo.reject(_id, comment: comment));

  Future<bool> returnForChanges({required String comment}) =>
      _act(() => _repo.returnForChanges(_id, comment: comment));

  Future<bool> _act(Future<Application> Function() action) async {
    final current = state.detail;
    emit(
      ApplicationDetailState(
        status: ApplicationDetailStatus.success,
        detail: current,
        isActing: true,
      ),
    );
    try {
      await action();
      await load();
      return true;
    } on ApiException catch (e) {
      emit(
        ApplicationDetailState(
          status: ApplicationDetailStatus.success,
          detail: current,
          actionError: e.message,
        ),
      );
      return false;
    }
  }
}
