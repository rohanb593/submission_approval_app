import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:submission_approval_app/api/models/app_role.dart';
import 'package:submission_approval_app/api/models/application.dart';
import 'package:submission_approval_app/api/models/application_status.dart';
import 'package:submission_approval_app/app/app_dependencies.dart';
import 'package:submission_approval_app/applications/cubit/applications_list_cubit.dart';
import 'package:submission_approval_app/applications/view/application_detail_page.dart';
import 'package:submission_approval_app/applications/view/application_form_page.dart';

class ApplicationsListPage extends StatelessWidget {
  const ApplicationsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ApplicationsListCubit(
          applicationRepository: context
              .read<AppDependencies>()
              .applicationRepository,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: const ApplicationsListView(),
    );
  }
}

class ApplicationsListView extends StatefulWidget {
  const ApplicationsListView({super.key});

  @override
  State<ApplicationsListView> createState() => _ApplicationsListViewState();
}

class _ApplicationsListViewState extends State<ApplicationsListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRequester =
        context.read<AppDependencies>().authRepository.currentUser?.role ==
        AppRole.requester;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<ApplicationsListCubit>().refresh(),
          child: BlocBuilder<ApplicationsListCubit, ApplicationsListState>(
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _CountsRow(counts: state.counts)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search title or description',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (value) => context
                            .read<ApplicationsListCubit>()
                            .setSearch(value),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _StatusFilterRow(selected: state.statusFilter),
                  ),
                  if (state.status == ApplicationsListStatus.loading &&
                      state.applications.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.status == ApplicationsListStatus.failure)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(state.errorMessage ?? 'Failed to load'),
                      ),
                    )
                  else if (state.applications.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: Text('No applications')),
                    )
                  else
                    SliverList.builder(
                      itemCount: state.applications.length,
                      itemBuilder: (context, index) => _ApplicationTile(
                        application: state.applications[index],
                      ),
                    ),
                  if (state.pageCount > 1)
                    SliverToBoxAdapter(child: _PaginationRow(state: state)),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: isRequester
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.of(
                  context,
                ).push<bool>(ApplicationFormPage.route());
                if (created == true && context.mounted) {
                  unawaited(context.read<ApplicationsListCubit>().refresh());
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('New'),
            )
          : null,
    );
  }
}

class _CountsRow extends StatelessWidget {
  const _CountsRow({required this.counts});

  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final status in ApplicationStatus.values)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(
                          '${counts[status.toJson()] ?? 0}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(status.label),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusFilterRow extends StatelessWidget {
  const _StatusFilterRow({required this.selected});

  final ApplicationStatus? selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) =>
                  context.read<ApplicationsListCubit>().setStatusFilter(null),
            ),
            for (final status in ApplicationStatus.values)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text(status.label),
                  selected: selected == status,
                  onSelected: (_) => context
                      .read<ApplicationsListCubit>()
                      .setStatusFilter(status),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaginationRow extends StatelessWidget {
  const _PaginationRow({required this.state});

  final ApplicationsListState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: state.page > 1
                ? () => context.read<ApplicationsListCubit>().setPage(
                    state.page - 1,
                  )
                : null,
          ),
          Text('Page ${state.page} of ${state.pageCount}'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: state.page < state.pageCount
                ? () => context.read<ApplicationsListCubit>().setPage(
                    state.page + 1,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  const _ApplicationTile({required this.application});

  final Application application;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(application.title),
      subtitle: Text(
        '${application.category.name} · ${application.status.label}',
      ),
      trailing: application.amount == null
          ? null
          : Text('\$${application.amount!.toStringAsFixed(2)}'),
      onTap: () async {
        final refreshedList = await Navigator.of(
          context,
        ).push<bool>(ApplicationDetailPage.route(application.id));
        if (refreshedList == true && context.mounted) {
          unawaited(context.read<ApplicationsListCubit>().refresh());
        }
      },
    );
  }
}
