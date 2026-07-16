import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:submission_approval_app/activity/activity.dart';
import 'package:submission_approval_app/admin_users/admin_users.dart';
import 'package:submission_approval_app/api/models/app_role.dart';
import 'package:submission_approval_app/api/models/app_user.dart';
import 'package:submission_approval_app/app/app_dependencies.dart';
import 'package:submission_approval_app/applications/applications.dart';
import 'package:submission_approval_app/notifications/notifications.dart';

class _Destination {
  const _Destination(this.title, this.icon, this.page);
  final String title;
  final IconData icon;
  final Widget page;
}

/// The signed-in app shell: an app bar (title, notification bell, sign out)
/// plus a bottom nav bar whose destinations depend on the user's role.
/// `/applications` is already scoped server-side by role, so the same
/// [ApplicationsListPage] serves as the requester dashboard and the
/// reviewer/admin queue alike.
class HomeShell extends StatefulWidget {
  const HomeShell({required this.user, super.key});

  final AppUser user;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  late final List<_Destination> _destinations = switch (widget.user.role) {
    AppRole.requester => const [
      _Destination('Applications', Icons.assignment, ApplicationsListPage()),
    ],
    AppRole.reviewer => const [
      _Destination('Review queue', Icons.rate_review, ApplicationsListPage()),
    ],
    AppRole.admin => const [
      _Destination('Applications', Icons.assignment, ApplicationsListPage()),
      _Destination('Users', Icons.people, AdminUsersPage()),
      _Destination('Activity', Icons.history, ActivityPage()),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = NotificationsCubit(
          notificationRepository: context
              .read<AppDependencies>()
              .notificationRepository,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_destinations[_index].title),
          actions: [
            const NotificationsBell(),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  unawaited(
                    context.read<AppDependencies>().authRepository.logout(),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Text('Sign out (${widget.user.email})'),
                ),
              ],
            ),
          ],
        ),
        body: IndexedStack(
          index: _index,
          children: [for (final d in _destinations) d.page],
        ),
        bottomNavigationBar: _destinations.length > 1
            ? NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                destinations: [
                  for (final d in _destinations)
                    NavigationDestination(icon: Icon(d.icon), label: d.title),
                ],
              )
            : null,
      ),
    );
  }
}
