part of 'applications_list_cubit.dart';

enum ApplicationsListStatus { initial, loading, success, failure }

const _unset = Object();

class ApplicationsListState extends Equatable {
  const ApplicationsListState({
    this.status = ApplicationsListStatus.initial,
    this.applications = const [],
    this.counts = const {},
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
    this.statusFilter,
    this.search = '',
    this.errorMessage,
  });

  final ApplicationsListStatus status;
  final List<Application> applications;
  final Map<String, int> counts;
  final int total;
  final int page;
  final int pageSize;
  final ApplicationStatus? statusFilter;
  final String search;
  final String? errorMessage;

  int get pageCount => total == 0 ? 1 : ((total + pageSize - 1) ~/ pageSize);

  ApplicationsListState copyWith({
    ApplicationsListStatus? status,
    List<Application>? applications,
    Map<String, int>? counts,
    int? total,
    int? page,
    int? pageSize,
    Object? statusFilter = _unset,
    String? search,
    Object? errorMessage = _unset,
  }) {
    return ApplicationsListState(
      status: status ?? this.status,
      applications: applications ?? this.applications,
      counts: counts ?? this.counts,
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      statusFilter: identical(statusFilter, _unset)
          ? this.statusFilter
          : statusFilter as ApplicationStatus?,
      search: search ?? this.search,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    applications,
    counts,
    total,
    page,
    pageSize,
    statusFilter,
    search,
    errorMessage,
  ];
}
