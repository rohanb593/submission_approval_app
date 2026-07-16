import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:submission_approval_app/app/app_dependencies.dart';
import 'package:submission_approval_app/app/config/app_config.dart';
import 'package:submission_approval_app/app/view/auth_gate.dart';
import 'package:submission_approval_app/l10n/l10n.dart';

class App extends StatefulWidget {
  const App({required this.config, super.key});

  final AppConfig config;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppDependencies _dependencies = AppDependencies(widget.config);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _dependencies,
      child: MaterialApp(
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          useMaterial3: true,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AuthGate(),
      ),
    );
  }
}
