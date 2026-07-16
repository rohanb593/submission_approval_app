import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:submission_approval_app/api/models/app_user.dart';
import 'package:submission_approval_app/app/app_dependencies.dart';
import 'package:submission_approval_app/app/view/home_shell.dart';
import 'package:submission_approval_app/auth/auth.dart';

/// Restores any persisted session on startup, then shows [LoginPage] or
/// [HomeShell] depending on whether one exists — and reacts immediately to
/// login/logout afterwards via [AppDependencies.tokenStorage]'s listenable.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<void> _restoreFuture = context
      .read<AppDependencies>()
      .authRepository
      .restoreSession();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _restoreFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final tokenStorage = context.read<AppDependencies>().tokenStorage;
        return ValueListenableBuilder<AppUser?>(
          valueListenable: tokenStorage.user,
          builder: (context, user, _) {
            return user == null ? const LoginPage() : HomeShell(user: user);
          },
        );
      },
    );
  }
}
