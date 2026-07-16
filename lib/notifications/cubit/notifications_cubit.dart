import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:submission_approval_app/api/api_exception.dart';
import 'package:submission_approval_app/api/models/app_notification.dart';
import 'package:submission_approval_app/api/repositories/notification_repository.dart';

part 'notifications_state.dart';

/// Wraps `/notifications/*`. Created once at the app shell level (not
/// per-page) so the unread badge and the notifications list share one
/// source of truth.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({required NotificationRepository notificationRepository})
    : _repo = notificationRepository,
      super(const NotificationsState());

  final NotificationRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    try {
      final page = await _repo.list();
      emit(
        state.copyWith(
          status: NotificationsStatus.success,
          notifications: page.notifications,
          unreadCount: page.unreadCount,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: NotificationsStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> markRead(String id) async {
    await _repo.markRead(id);
    await load();
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    await load();
  }
}
