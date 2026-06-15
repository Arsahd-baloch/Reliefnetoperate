import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reliefnet_app/screens/coordinator/coordinator_tasks_screen.dart';
import 'package:reliefnet_app/features/tasks/domain/task_model.dart';
import 'package:reliefnet_app/widgets/empty_state.dart';
import 'package:reliefnet_app/widgets/error_view.dart';
import 'package:reliefnet_app/widgets/shimmer_card.dart';
import 'package:reliefnet_app/widgets/status_chip.dart';

class CoordinatorSubmittedTasksScreen extends ConsumerWidget {
  const CoordinatorSubmittedTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(coordinatorTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Inbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(coordinatorTasksProvider),
          ),
        ],
      ),
      body: tasksAsync.when(
        loading: () => const ShimmerList(count: 5, itemHeight: 120),
        error: (err, _) => ErrorView(
          message: 'Could not load submissions.',
          onRetry: () => ref.invalidate(coordinatorTasksProvider),
        ),
        data: (tasks) {
          final submitted = tasks.where((t) => t.status == TaskStatus.submitted).toList();

          if (submitted.isEmpty) {
            return const EmptyState(
              icon: Icons.fact_check_outlined,
              title: 'Clean slate!',
              subtitle: 'All delivery submissions have been reviewed.',
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.touch_app_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer),
                    const SizedBox(width: 8),
                    Text(
                      'Tap a submission to verify or flag it',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${submitted.length} pending',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => ref.invalidate(coordinatorTasksProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: submitted.length,
                    itemBuilder: (context, index) {
                      final task = submitted[index];
                      final cs = Theme.of(context).colorScheme;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.push('/coordinator/review/${task.id}'),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    StatusChip(status: task.status),
                                    const Spacer(),
                                    Text(
                                      'Review →',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: cs.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  task.title,
                                  style: const TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.person_outline,
                                        size: 13, color: cs.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Volunteer: ${task.claimedByName ?? 'Unknown'}',
                                      style: TextStyle(
                                          fontSize: 12, color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
