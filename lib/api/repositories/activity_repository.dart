import 'package:submission_approval_app/api/api_client.dart';
import 'package:submission_approval_app/api/models/activity_entry.dart';

/// Wraps the admin-only `/activity` endpoint — see
/// `backend/internal/httpapi/activity_handlers.go`.
class ActivityRepository {
  ActivityRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<List<ActivityEntry>> list() async {
    final json = await _apiClient.get('/activity') as List<dynamic>;
    return json
        .cast<Map<String, dynamic>>()
        .map(ActivityEntry.fromJson)
        .toList();
  }
}
