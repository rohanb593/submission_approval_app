import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:submission_approval_app/admin_users/cubit/admin_users_cubit.dart';
import 'package:submission_approval_app/api/models/app_role.dart';
import 'package:submission_approval_app/app/app_dependencies.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = AdminUsersCubit(
          userRepository: context.read<AppDependencies>().userRepository,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: const _AdminUsersView(),
    );
  }
}

class _AdminUsersView extends StatelessWidget {
  const _AdminUsersView();

  Future<void> _showCreateDialog(BuildContext context) async {
    final cubit = context.read<AdminUsersCubit>();
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    var role = AppRole.requester;
    String? error;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('New user'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Email is required'
                      : null,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) => (v == null || v.length < 8)
                      ? 'At least 8 characters'
                      : null,
                ),
                DropdownButtonFormField<AppRole>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: [
                    for (final r in AppRole.values)
                      DropdownMenuItem(value: r, child: Text(r.name)),
                  ],
                  onChanged: (value) => setState(() => role = value!),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(dialogContext).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final result = await cubit.create(
                  email: emailController.text.trim(),
                  password: passwordController.text,
                  role: role,
                );
                if (result == null) {
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                } else {
                  setState(() => error = result);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context
        .read<AppDependencies>()
        .authRepository
        .currentUser
        ?.id;

    return Scaffold(
      body: BlocBuilder<AdminUsersCubit, AdminUsersState>(
        builder: (context, state) {
          if (state.status == AdminUsersStatus.loading && state.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == AdminUsersStatus.failure) {
            return Center(
              child: Text(state.errorMessage ?? 'Failed to load users'),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<AdminUsersCubit>().load(),
            child: ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                final isSelf = user.id == currentUserId;
                return ListTile(
                  title: Text(user.email),
                  subtitle: isSelf ? const Text('You') : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<AppRole>(
                        value: user.role,
                        underline: const SizedBox.shrink(),
                        onChanged: isSelf
                            ? null
                            : (role) {
                                if (role != null) {
                                  unawaited(
                                    context.read<AdminUsersCubit>().updateRole(
                                      user.id,
                                      role,
                                    ),
                                  );
                                }
                              },
                        items: [
                          for (final r in AppRole.values)
                            DropdownMenuItem(value: r, child: Text(r.name)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: isSelf
                            ? null
                            : () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete user?'),
                                    content: Text(
                                      'Remove ${user.email}? '
                                      'This cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true && context.mounted) {
                                  final error = await context
                                      .read<AdminUsersCubit>()
                                      .delete(user.id);
                                  if (error != null && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(error)),
                                    );
                                  }
                                }
                              },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('New user'),
      ),
    );
  }
}
