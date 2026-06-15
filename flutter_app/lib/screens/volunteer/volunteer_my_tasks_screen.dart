import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/features/tasks/domain/task_model.dart';
import 'package:reliefnet_app/providers/volunteer_impact_provider.dart';
import 'package:reliefnet_app/widgets/empty_state.dart';
import 'package:reliefnet_app/widgets/shimmer_card.dart';

class VolunteerMyTasksScreen extends ConsumerStatefulWidget {
  const VolunteerMyTasksScreen({super.key});

  @override
  ConsumerState<VolunteerMyTasksScreen> createState() =>
      _VolunteerMyTasksScreenState();
}

class _VolunteerMyTasksScreenState
    extends ConsumerState<VolunteerMyTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TaskModel> _active(List<TaskModel> tasks) => tasks
      .where((t) =>
          t.status == TaskStatus.claimed ||
          t.status == TaskStatus.assigned ||
          t.status == TaskStatus.inProgress ||
          t.status == TaskStatus.submitted)
      .toList();

  List<TaskModel> _completed(List<TaskModel> tasks) => tasks
      .where((t) =>
          t.status == TaskStatus.coordinatorVerified ||
          t.status == TaskStatus.paid ||
          t.status == TaskStatus.cancelled ||
          t.status == TaskStatus.flagged)
      .toList();

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(volunteerTasksHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.invalidate(volunteerTasksHistoryProvider);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.65),
          indicatorColor: Colors.white,
          indicatorWeight: 2.5,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      body: historyAsync.when(
        loading: () => const ShimmerList(count: 4, itemHeight: 120),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppTheme.textDisabled),
              const SizedBox(height: 12),
              const Text('Could not load tasks',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(volunteerTasksHistoryProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (tasks) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(volunteerTasksHistoryProvider),
          child: TabBarView(
            controller: _tabController,
            children: [
              _TaskList(
                tasks: _active(tasks),
                emptyTitle: 'No active tasks',
                emptySubtitle:
                    'Claim a task from Discover to start helping.',
                emptyIcon: Icons.assignment_outlined,
                showActions: true,
              ),
              _TaskList(
                tasks: _completed(tasks),
                emptyTitle: 'No completed tasks',
                emptySubtitle: 'Completed tasks will show here.',
                emptyIcon: Icons.history,
                showActions: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<TaskModel> tasks;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;
  final bool showActions;

  const _TaskList({
    required this.tasks,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyIcon,
    required this.showActions,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Builder(
        builder: (context) => EmptyState(
          icon: emptyIcon,
          title: emptyTitle,
          subtitle: emptySubtitle,
          ctaLabel: showActions ? 'Discover Tasks' : null,
          onCta: showActions ? () => context.go('/volunteer/tasks') : null,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: tasks.length,
      itemBuilder: (context, i) => _VolunteerTaskCard(
        task: tasks[i],
        showActions: showActions,
      ),
    );
  }
}

class _VolunteerTaskCard extends StatelessWidget {
  final TaskModel task;
  final bool showActions;

  const _VolunteerTaskCard({required this.task, required this.showActions});

  (String, Color, IconData) _statusMeta() {
    return switch (task.status) {
      TaskStatus.claimed =>
        ('Claimed', AppTheme.statusActive, Icons.handshake_outlined),
      TaskStatus.assigned =>
        ('Assigned', AppTheme.statusActive, Icons.assignment_ind_outlined),
      TaskStatus.inProgress =>
        ('In Progress', AppTheme.statusInProgress, Icons.directions_run),
      TaskStatus.submitted =>
        ('Proof Submitted', AppTheme.infoColor, Icons.upload_file),
      TaskStatus.coordinatorVerified =>
        ('Verified ✓', AppTheme.successColor, Icons.verified_outlined),
      TaskStatus.paid =>
        ('Completed', AppTheme.successColor, Icons.check_circle_outline),
      TaskStatus.cancelled =>
        ('Cancelled', AppTheme.statusFailed, Icons.cancel_outlined),
      TaskStatus.flagged =>
        ('Flagged', AppTheme.errorColor, Icons.flag_outlined),
      _ => ('Unknown', AppTheme.statusNeutral, Icons.help_outline),
    };
  }

  Color _urgencyColor() => switch (task.urgency) {
        TaskUrgency.critical => AppTheme.urgencyCritical,
        TaskUrgency.high => AppTheme.urgencyHigh,
        TaskUrgency.medium => AppTheme.urgencyMedium,
        _ => AppTheme.urgencyLow,
      };

  String _categoryEmoji() => switch (task.category?.toUpperCase()) {
        'FOOD' => '🍞',
        'MEDICAL' => '💊',
        'SHELTER' => '🏠',
        'WATER' => '💧',
        'RESCUE' => '🆘',
        _ => '📦',
      };

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor, statusIcon) = _statusMeta();
    final urgencyColor = _urgencyColor();
    final timeStr = task.createdAt != null
        ? timeago.format(DateTime.tryParse(task.createdAt!) ?? DateTime.now())
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/volunteer/task/${task.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Urgency top bar
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: urgencyColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_categoryEmoji(),
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right,
                          size: 18, color: AppTheme.textDisabled),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Status + time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon,
                                size: 12, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.schedule,
                          size: 11, color: AppTheme.textDisabled),
                      const SizedBox(width: 3),
                      Text(
                        timeStr,
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textDisabled),
                      ),
                    ],
                  ),

                  // Location
                  if (task.locationText != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: AppTheme.textDisabled),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            task.locationText!,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Action buttons for active tasks
                  if (showActions &&
                      (task.status == TaskStatus.inProgress ||
                          task.status == TaskStatus.claimed)) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                context.push('/chat/${task.id}?title=${Uri.encodeComponent(task.title)}'),
                            icon: const Icon(Icons.chat_outlined, size: 16),
                            label: const Text('Chat',
                                style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              side: const BorderSide(
                                  color: AppTheme.primaryColor),
                              foregroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () =>
                                context.push('/volunteer/proof/${task.id}'),
                            icon: const Icon(Icons.upload_outlined, size: 16),
                            label: const Text('Upload Proof',
                                style: TextStyle(fontSize: 12)),
                            style: FilledButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              backgroundColor: AppTheme.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (showActions &&
                      task.status == TaskStatus.submitted) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.infoColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                                AppTheme.infoColor.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.hourglass_top_outlined,
                              size: 14, color: AppTheme.infoColor),
                          SizedBox(width: 6),
                          Text(
                            'Awaiting coordinator review',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.infoColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
