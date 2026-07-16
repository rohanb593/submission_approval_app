import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:submission_approval_app/api/api_exception.dart';
import 'package:submission_approval_app/api/models/application.dart';
import 'package:submission_approval_app/api/models/application_status.dart';
import 'package:submission_approval_app/api/repositories/application_repository.dart';

part 'applications_list_state.dart';

/// Drives `GET /applications`, which is already scoped server-side: a
/// requester only ever gets their own applications back, a reviewer/admin
/// gets everyone's (see `backend/internal/applications/service.go` `List`).
/// That means this one cubit/page backs the requester dashboard, the
/// reviewer queue, and the admin view alike — only the available actions on
/// the detail page differ by role.
class ApplicationsListCubit extends Cubit<ApplicationsListState> {
  ApplicationsListCubit({required ApplicationRepository applicationRepository})
    : _repo = applicationRepository,
      super(const ApplicationsListState());

  final ApplicationRepository _repo;

  Future<void> load() => _fetch(page: 1);

  Future<void> refresh() => _fetch(page: state.page);

  Future<void> setStatusFilter(ApplicationStatus? status) =>
      _fetch(page: 1, statusFilter: status);

  Future<void> setSearch(String search) => _fetch(page: 1, search: search);

  Future<void> setPage(int page) => _fetch(page: page);

  Future<void> _fetch({
    required int page,
    Object? statusFilter = _unset,
    String? search,
  }) async {
    emit(state.copyWith(status: ApplicationsListStatus.loading));
    try {
      final effectiveStatus = identical(statusFilter, _unset)
          ? state.statusFilter
          : statusFilter as ApplicationStatus?;
      final effectiveSearch = search ?? state.search;
      final result = await _repo.list(
        status: effectiveStatus,
        search: effectiveSearch,
        page: page,
        pageSize: state.pageSize,
      );
      emit(
        state.copyWith(
          status: ApplicationsListStatus.success,
          applications: result.applications,
          counts: result.counts,
          total: result.total,
          page: result.page,
          statusFilter: effectiveStatus,
          search: effectiveSearch,
          errorMessage: null,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: ApplicationsListStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }
}
