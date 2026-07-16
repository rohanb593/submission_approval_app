/// Mirrors `notificationResponse` in `backend/internal/httpapi/notification_handlers.go`.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.applicationId,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        applicationId: json['application_id'] as String,
        message: json['message'] as String,
        read: json['read'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  final String id;
  final String applicationId;
  final String message;
  final bool read;
  final DateTime createdAt;
}

/// Mirrors `notificationListResponse`.
class NotificationPage {
  const NotificationPage({
    required this.notifications,
    required this.unreadCount,
  });

  factory NotificationPage.fromJson(Map<String, dynamic> json) =>
      NotificationPage(
        notifications: (json['notifications'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(AppNotification.fromJson)
            .toList(),
        unreadCount: json['unread_count'] as int,
      );

  final List<AppNotification> notifications;
  final int unreadCount;
}
