import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:submission_approval_app/api/models/application.dart';
import 'package:submission_approval_app/api/models/application_status.dart';
import 'package:submission_approval_app/app/app_dependencies.dart';
import 'package:submission_approval_app/applications/cubit/application_form_cubit.dart';

/// Creates a new draft, or edits an existing one when [existing] is passed
/// (only legal while it's still DRAFT — the backend rejects otherwise).
/// Pops with `true` when a create/edit succeeds, so the caller knows to
/// refresh its list.
class ApplicationFormPage extends StatelessWidget {
  const ApplicationFormPage({this.existing, super.key});

  final Application? existing;

  static Route<bool> route({Application? existing}) {
    return MaterialPageRoute<bool>(
      builder: (_) => ApplicationFormPage(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApplicationFormCubit(
        applicationRepository: context
            .read<AppDependencies>()
            .applicationRepository,
        editingId: existing?.id,
      ),
      child: ApplicationFormView(existing: existing),
    );
  }
}

class ApplicationFormView extends StatefulWidget {
  const ApplicationFormView({this.existing, super.key});

  final Application? existing;

  @override
  State<ApplicationFormView> createState() => _ApplicationFormViewState();
}

class _ApplicationFormViewState extends State<ApplicationFormView> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.existing?.title,
  );
  late final _descriptionController = TextEditingController(
    text: widget.existing?.description,
  );
  late final _amountController = TextEditingController(
    text: widget.existing?.amount?.toString(),
  );
  late ApplicationCategory _category =
      widget.existing?.category ?? ApplicationCategory.other;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    unawaited(
      context.read<ApplicationFormCubit>().submit(
        title: _titleController.text.trim(),
        category: _category,
        description: _descriptionController.text.trim(),
        amount: _amountController.text.trim().isEmpty
            ? null
            : double.tryParse(_amountController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit application' : 'New application'),
      ),
      body: BlocConsumer<ApplicationFormCubit, ApplicationFormState>(
        listener: (context, state) {
          if (state.status == ApplicationFormStatus.success) {
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      errorText: state.fieldErrors['title'],
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Title is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ApplicationCategory>(
                    initialValue: _category,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      errorText: state.fieldErrors['category'],
                    ),
                    items: [
                      for (final category in ApplicationCategory.values)
                        DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        ),
                    ],
                    onChanged: (value) => setState(() => _category = value!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount (optional)',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      return double.tryParse(v.trim()) == null
                          ? 'Enter a valid number'
                          : null;
                    },
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: state.status == ApplicationFormStatus.submitting
                        ? null
                        : () => _submit(context),
                    child: state.status == ApplicationFormStatus.submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEditing ? 'Save' : 'Create draft'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
