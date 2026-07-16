import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:submission_approval_app/notifications/cubit/notifications_cubit.dart';
import 'package:submission_approval_app/notifications/view/notifications_page.dart';

/// App-bar action: bell icon with an unread-count badge, for use across
/// every role's home shell.
class NotificationsBell extends StatelessWidget {
  const NotificationsBell({super.key});

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.select<NotificationsCubit, int>(
      (cubit) => cubit.state.unreadCount,
    );
    return IconButton(
      tooltip: 'Notifications',
      onPressed: () => Navigator.of(context).push(NotificationsPage.route()),
      icon: Badge(
        label: Text('$unreadCount'),
        isLabelVisible: unreadCount > 0,
        child: const Icon(Icons.notifications),
      ),
    );
  }
}
