import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/{{name.snakeCase()}}_bloc.dart';

class {{name.pascalCase()}}Page extends StatelessWidget {
  const {{name.pascalCase()}}Page({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (_) => {{name.pascalCase()}}Bloc()..add(const {{name.pascalCase()}}Requested()),
        child: const {{name.pascalCase()}}Page(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('{{name.pascalCase()}}')),
      body: BlocBuilder<{{name.pascalCase()}}Bloc, {{name.pascalCase()}}State>(
        builder: (context, state) {
          return switch (state.status) {
            {{name.pascalCase()}}Status.initial ||
            {{name.pascalCase()}}Status.loading =>
              const Center(child: CircularProgressIndicator()),
            {{name.pascalCase()}}Status.failure => Center(
              child: Text(state.errorMessage ?? 'Something went wrong'),
            ),
            {{name.pascalCase()}}Status.success => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
