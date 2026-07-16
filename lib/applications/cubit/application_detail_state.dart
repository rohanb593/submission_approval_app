part of 'application_detail_cubit.dart';

enum ApplicationDetailStatus { loading, success, failure }

class ApplicationDetailState extends Equatable {
  const ApplicationDetailState({
    this.status = ApplicationDetailStatus.loading,
    this.detail,
    this.errorMessage,
    this.isActing = false,
    this.actionError,
  });

  final ApplicationDetailStatus status;
  final ApplicationDetail? detail;
  final String? errorMessage;
  final bool isActing;
  final String? actionError;

  @override
  List<Object?> get props => [
    status,
    detail,
    errorMessage,
    isActing,
    actionError,
  ];
}
