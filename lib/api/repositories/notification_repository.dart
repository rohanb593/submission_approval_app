import 'package:submission_approval_app/api/api_client.dart';
import 'package:submission_approval_app/api/models/app_notification.dart';

/// Wraps `/notifications/*` — see `backend/internal/httpapi/notification_handlers.go`.
class NotificationRepository {
  NotificationRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<NotificationPage> list() async {
    final json = await _apiClient.get('/notifications') as Map<String, dynamic>;
    return NotificationPage.fromJson(json);
  }

  Future<void> markRead(String id) =>
      _apiClient.post('/notifications/$id/read');

  Future<void> markAllRead() => _apiClient.post('/notifications/read-all');
}
