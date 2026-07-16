part of 'application_form_cubit.dart';

enum ApplicationFormStatus { initial, submitting, success, failure }

class ApplicationFormState extends Equatable {
  const ApplicationFormState({
    this.status = ApplicationFormStatus.initial,
    this.errorMessage,
    this.fieldErrors = const {},
    this.result,
  });

  final ApplicationFormStatus status;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final Application? result;

  @override
  List<Object?> get props => [status, errorMessage, fieldErrors, result];
}
