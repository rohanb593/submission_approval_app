import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:submission_approval_app/api/api_exception.dart';
import 'package:submission_approval_app/api/models/application.dart';
import 'package:submission_approval_app/api/models/application_status.dart';
import 'package:submission_approval_app/api/repositories/application_repository.dart';

part 'application_form_state.dart';

/// Backs both the "new application" and "edit draft" forms: `POST
/// /applications` when editingId is null, `PUT /applications/{id}`
/// otherwise. Only a DRAFT application's owner may edit it — the backend
/// enforces that; a validation/forbidden error surfaces the same way here.
class ApplicationFormCubit extends Cubit<ApplicationFormState> {
  ApplicationFormCubit({
    required ApplicationRepository applicationRepository,
    String? this._editingId,
  }) : _repo = applicationRepository,
       super(const ApplicationFormState());

  final ApplicationRepository _repo;
  final String? _editingId;

  Future<void> submit({
    required String title,
    required ApplicationCategory category,
    required String description,
    double? amount,
  }) async {
    emit(const ApplicationFormState(status: ApplicationFormStatus.submitting));
    try {
      final id = _editingId;
      final app = id == null
          ? await _repo.create(
              title: title,
              category: category,
              description: description,
              amount: amount,
            )
          : await _repo.updateDraft(
              id,
              title: title,
              category: category,
              description: description,
              amount: amount,
            );
      emit(
        ApplicationFormState(
          status: ApplicationFormStatus.success,
          result: app,
        ),
      );
    } on ApiException catch (e) {
      emit(
        ApplicationFormState(
          status: ApplicationFormStatus.failure,
          errorMessage: e.fields.isEmpty ? e.message : null,
          fieldErrors: e.fields,
        ),
      );
    }
  }
}
