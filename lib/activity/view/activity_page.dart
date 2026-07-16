import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:submission_approval_app/activity/cubit/activity_cubit.dart';
import 'package:submission_approval_app/app/app_dependencies.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActivityCubit(
        activityRepository: context.read<AppDependencies>().activityRepository,
      )..load(),
      child: const _ActivityView(),
    );
  }
}

class _ActivityView extends StatelessWidget {
  const _ActivityView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ActivityCubit, ActivityState>(
        builder: (context, state) {
          if (state.status == ActivityStatus.loading && state.entries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ActivityStatus.failure) {
            return Center(child: Text(state.errorMessage ?? 'Failed to load'));
          }
          return RefreshIndicator(
            onRefresh: () => context.read<ActivityCubit>().load(),
            child: ListView.builder(
              itemCount: state.entries.length,
              itemBuilder: (context, index) {
                final e = state.entries[index];
                final formatted = DateFormat.yMMMd().add_jms().format(
                  e.createdAt.toLocal(),
                );
                return ListTile(
                  title: Text('${e.method} ${e.path}'),
                  subtitle: Text(
                    '${e.actorEmail} (${e.actorRole}) · $formatted',
                  ),
                  trailing: Text(
                    '${e.statusCode}',
                    style: TextStyle(
                      color: e.statusCode >= 400
                          ? Theme.of(context).colorScheme.error
                          : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
