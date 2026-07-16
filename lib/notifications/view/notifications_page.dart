import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:submission_approval_app/notifications/cubit/notifications_cubit.dart';

/// Reads from the app-shell-level [NotificationsCubit] (see the
/// NotificationsBell app-bar action) rather than creating its own, so the
/// unread badge and this list always agree.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const NotificationsPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all read',
            onPressed: () => context.read<NotificationsCubit>().markAllRead(),
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.status == NotificationsStatus.loading &&
              state.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }
          return RefreshIndicator(
            onRefresh: () => context.read<NotificationsCubit>().load(),
            child: ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final n = state.notifications[index];
                return ListTile(
                  leading: Icon(
                    n.read
                        ? Icons.notifications_none
                        : Icons.notifications_active,
                  ),
                  title: Text(n.message),
                  subtitle: Text(
                    DateFormat.yMMMd().add_jm().format(n.createdAt.toLocal()),
                  ),
                  onTap: n.read
                      ? null
                      : () => context.read<NotificationsCubit>().markRead(n.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
