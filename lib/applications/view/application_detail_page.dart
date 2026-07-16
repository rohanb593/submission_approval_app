import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:submission_approval_app/api/models/app_role.dart';
import 'package:submission_approval_app/api/models/application.dart';
import 'package:submission_approval_app/api/models/application_status.dart';
import 'package:submission_approval_app/app/app_dependencies.dart';
import 'package:submission_approval_app/applications/cubit/application_detail_cubit.dart';
import 'package:submission_approval_app/applications/view/application_form_page.dart';

/// Shared by every role: a requester sees their own draft/submitted
/// application with edit/submit actions, a reviewer sees the review actions,
/// and an admin sees every action regardless of status (the backend's admin
/// override — see `workflow.adminOverrides`). Pops with `true` if any action
/// changed the application, so the list page knows to refresh.
class ApplicationDetailPage extends StatelessWidget {
  const ApplicationDetailPage({required this.applicationId, super.key});

  final String applicationId;

  static Route<bool> route(String applicationId) {
    return MaterialPageRoute<bool>(
      builder: (_) => ApplicationDetailPage(applicationId: applicationId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApplicationDetailCubit(
        applicationRepository: context
            .read<AppDependencies>()
            .applicationRepository,
        applicationId: applicationId,
      )..load(),
      child: const _ApplicationDetailView(),
    );
  }
}

class _ApplicationDetailView extends StatelessWidget {
  const _ApplicationDetailView();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final cubit = context.read<ApplicationDetailCubit>();
        Navigator.of(
          context,
        ).pop(cubit.state.detail != null && result != false);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Application')),
        body: BlocConsumer<ApplicationDetailCubit, ApplicationDetailState>(
          listener: (context, state) {
            if (state.actionError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionError!)),
              );
            }
          },
          builder: (context, state) {
            if (state.status == ApplicationDetailStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == ApplicationDetailStatus.failure) {
              return Center(
                child: Text(state.errorMessage ?? 'Failed to load'),
              );
            }
            final detail = state.detail!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _DetailHeader(application: detail.application),
                const SizedBox(height: 24),
                _ActionRow(
                  application: detail.application,
                  isActing: state.isActing,
                ),
                const SizedBox(height: 24),
                Text(
                  'Audit trail',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final entry in detail.auditLog.reversed)
                  _AuditTile(entry: entry),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.application});

  final Application application;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          application.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Chip(label: Text(application.status.label)),
        const SizedBox(height: 12),
        Text('Category: ${application.category.name}'),
        if (application.amount != null)
          Text('Amount: \$${application.amount!.toStringAsFixed(2)}'),
        const SizedBox(height: 12),
        Text(application.description),
      ],
    );
  }
}

class _AuditTile extends StatelessWidget {
  const _AuditTile({required this.entry});

  final AuditEntry entry;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat.yMMMd().add_jm().format(
      entry.createdAt.toLocal(),
    );
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.history),
      title: Text('${entry.fromStatus} → ${entry.toStatus}'),
      subtitle: Text(
        [
          '${entry.actorEmail} · $formatted',
          if (entry.comment != null && entry.comment!.isNotEmpty)
            entry.comment!,
        ].join('\n'),
      ),
      isThreeLine: entry.comment != null && entry.comment!.isNotEmpty,
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.application, required this.isActing});

  final Application application;
  final bool isActing;

  Future<String?> _promptComment(
    BuildContext context, {
    required String title,
    required bool required,
  }) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Comment'),
            validator: required
                ? (v) => (v == null || v.trim().isEmpty)
                      ? 'Comment is required'
                      : null
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ApplicationDetailCubit>();
    final currentUser = context
        .read<AppDependencies>()
        .authRepository
        .currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    final isOwner = application.ownerId == currentUser.id;
    final buttons = <Widget>[];

    void addEditSubmit() {
      buttons
        ..add(
          OutlinedButton.icon(
            onPressed: isActing
                ? null
                : () => unawaited(
                    Navigator.of(context)
                        .push<bool>(
                          ApplicationFormPage.route(existing: application),
                        )
                        .then((changed) {
                          if (changed == true) cubit.load();
                        }),
                  ),
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        )
        ..add(
          FilledButton.icon(
            onPressed: isActing ? null : cubit.submit,
            icon: const Icon(Icons.send),
            label: const Text('Submit'),
          ),
        );
    }

    void addStartReview() {
      buttons.add(
        FilledButton(
          onPressed: isActing ? null : cubit.startReview,
          child: const Text('Start review'),
        ),
      );
    }

    void addReviewDecisions() {
      buttons
        ..add(
          FilledButton(
            onPressed: isActing ? null : cubit.approve,
            child: const Text('Approve'),
          ),
        )
        ..add(
          OutlinedButton(
            onPressed: isActing
                ? null
                : () async {
                    final comment = await _promptComment(
                      context,
                      title: 'Reject',
                      required: true,
                    );
                    if (comment != null) {
                      unawaited(cubit.reject(comment: comment));
                    }
                  },
            child: const Text('Reject'),
          ),
        )
        ..add(
          OutlinedButton(
            onPressed: isActing
                ? null
                : () async {
                    final comment = await _promptComment(
                      context,
                      title: 'Return for changes',
                      required: true,
                    );
                    if (comment != null) {
                      unawaited(cubit.returnForChanges(comment: comment));
                    }
                  },
            child: const Text('Return for changes'),
          ),
        );
    }

    switch (currentUser.role) {
      case AppRole.requester:
        if (isOwner && application.status == ApplicationStatus.draft) {
          addEditSubmit();
        }
      case AppRole.reviewer:
        if (application.status == ApplicationStatus.submitted) {
          addStartReview();
        } else if (application.status == ApplicationStatus.underReview) {
          addReviewDecisions();
        }
      case AppRole.admin:
        // Admins can perform any action from any status (see
        // workflow.adminOverrides), so every action is always offered.
        addStartReview();
        addReviewDecisions();
        if (isOwner && application.status == ApplicationStatus.draft) {
          addEditSubmit();
        }
    }

    if (buttons.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 8, children: buttons);
  }
}
