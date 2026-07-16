import 'package:submission_approval_app/api/api_client.dart';
import 'package:submission_approval_app/api/models/application.dart';
import 'package:submission_approval_app/api/models/application_status.dart';

/// Wraps `/applications/*` — see `backend/internal/httpapi/application_handlers.go`
/// and the transition rules in `backend/internal/workflow/state_machine.go`.
class ApplicationRepository {
  ApplicationRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<Application> create({
    required String title,
    required ApplicationCategory category,
    required String description,
    double? amount,
  }) async {
    final json =
        await _apiClient.post(
              '/applications',
              body: {
                'title': title,
                'category': category.toJson(),
                'description': description,
                'amount': amount,
              },
            )
            as Map<String, dynamic>;
    return Application.fromJson(json);
  }

  Future<ApplicationPage> list({
    ApplicationStatus? status,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final json =
        await _apiClient.get(
              '/applications',
              query: {
                if (status != null) 'status': status.toJson(),
                if (search != null && search.isNotEmpty) 'search': search,
                'page': '$page',
                'page_size': '$pageSize',
              },
            )
            as Map<String, dynamic>;
    return ApplicationPage.fromJson(json);
  }

  Future<ApplicationDetail> get(String id) async {
    final json =
        await _apiClient.get('/applications/$id') as Map<String, dynamic>;
    return ApplicationDetail.fromJson(json);
  }

  Future<Application> updateDraft(
    String id, {
    required String title,
    required ApplicationCategory category,
    required String description,
    double? amount,
  }) async {
    final json =
        await _apiClient.put(
              '/applications/$id',
              body: {
                'title': title,
                'category': category.toJson(),
                'description': description,
                'amount': amount,
              },
            )
            as Map<String, dynamic>;
    return Application.fromJson(json);
  }

  Future<Application> submit(String id) => _transition(id, 'submit');

  Future<Application> startReview(String id) => _transition(id, 'start-review');

  Future<Application> approve(String id, {String comment = ''}) =>
      _transition(id, 'approve', comment: comment);

  Future<Application> reject(String id, {required String comment}) =>
      _transition(id, 'reject', comment: comment);

  Future<Application> returnForChanges(String id, {required String comment}) =>
      _transition(id, 'return', comment: comment);

  Future<Application> _transition(
    String id,
    String action, {
    String comment = '',
  }) async {
    final json =
        await _apiClient.post(
              '/applications/$id/$action',
              body: {'comment': comment},
            )
            as Map<String, dynamic>;
    return Application.fromJson(json);
  }
}
