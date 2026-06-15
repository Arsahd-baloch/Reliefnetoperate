import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/features/auth/presentation/auth_provider.dart';
import 'package:reliefnet_app/features/tasks/domain/task_model.dart';
import 'package:reliefnet_app/providers/beneficiary_task_provider.dart';
import 'package:reliefnet_app/providers/notification_provider.dart';
import 'package:reliefnet_app/widgets/empty_state.dart';
import 'package:reliefnet_app/widgets/error_view.dart';
import 'package:reliefnet_app/widgets/shimmer_card.dart';

class MyTasksScreen extends ConsumerStatefulWidget {
  const MyTasksScreen({super.key});

  @override
  ConsumerState<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends ConsumerState<MyTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = ['All', 'Active', 'Completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TaskModel> _filter(List<TaskModel> tasks, int tabIndex) {
    switch (tabIndex) {
      case 1:
        return tasks
            .where((t) =>
                t.status == TaskStatus.open ||
                t.status == TaskStatus.claimed ||
                t.status == TaskStatus.assigned ||
                t.status == TaskStatus.inProgress)
            .toList();
      case 2:
        return tasks
            .where((t) =>
                t.status == TaskStatus.paid ||
                t.status == TaskStatus.coordinatorVerified ||
                t.status == TaskStatus.submitted)
            .toList();
      default:
        return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider).user?.id;
    if (userId == null) return const SizedBox.shrink();

    final tasksAsync = ref.watch(myTasksProvider(userId));
    final notifications = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        actions: [
          IconButton(
            tooltip: notifications.isEmpty
                ? 'Notifications'
                : '${notifications.length} unread notifications',
            icon: Badge(
              isLabelVisible: notifications.isNotEmpty,
              label: Text(notifications.length.toString()),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => context.push('/beneficiary/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.invalidate(myTasksProvider(userId));
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: tasksAsync.when(
        loading: () => const ShimmerList(count: 3, itemHeight: 150),
        error: (err, _) => ErrorView(
          message: 'Could not load your requests. Please try again.',
          onRetry: () => ref.invalidate(myTasksProvider(userId)),
        ),
        data: (tasks) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myTasksProvider(userId)),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _SummaryCard(tasks: tasks),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    child: Container(
                      color: AppTheme.backgroundColor,
                      child: TabBar(
                        controller: _tabController,
                        tabs: _tabs.map((t) => Tab(text: t)).toList(),
                        labelColor: AppTheme.primaryColor,
                        unselectedLabelColor: AppTheme.textSecondary,
                        indicatorColor: AppTheme.primaryColor,
                        indicatorWeight: 2.5,
                        labelStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                        unselectedLabelStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                        onTap: (_) => setState(() {}),
                      ),
                    ),
                  ),
                ),
                _buildTaskList(tasks),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'my_tasks_emergency_fab',
            onPressed: () {
              HapticFeedback.heavyImpact();
              context.push('/beneficiary/emergency-request');
            },
            icon: const Icon(Icons.sos_outlined),
            label: const Text('Emergency'),
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'my_tasks_new_request_fab',
            onPressed: () => context.push('/beneficiary/create-task'),
            icon: const Icon(Icons.add),
            label: const Text('New Request'),
            elevation: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<TaskModel> tasks) {
    final filtered = _filter(tasks, _tabController.index);

    if (filtered.isEmpty) {
      final emptyMsg = switch (_tabController.index) {
        1 => ('No active requests', 'All your requests have been fulfilled.'),
        2 => ('No completed requests', 'Completed tasks will appear here.'),
        _ => ('No requests yet', 'Tap "New Request" to ask for help.'),
      };

      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.assignment_outlined,
          title: emptyMsg.$1,
          subtitle: emptyMsg.$2,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _TaskCard(task: filtered[index]),
          childCount: filtered.length,
        ),
      ),
    );
  }
}

// ── Summary Card ──

class _SummaryCard extends StatelessWidget {
  final List<TaskModel> tasks;

  const _SummaryCard({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final total = tasks.length;
    final active = tasks
        .where((t) =>
            t.status == TaskStatus.open ||
            t.status == TaskStatus.claimed ||
            t.status == TaskStatus.assigned ||
            t.status == TaskStatus.inProgress)
        .length;
    final completed = tasks
        .where((t) =>
            t.status == TaskStatus.paid ||
            t.status == TaskStatus.coordinatorVerified)
        .length;
    final pending = tasks
        .where((t) =>
            t.status == TaskStatus.submitted)
        .length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_ind_outlined,
                  color: Colors.white70, size: 16),
              SizedBox(width: 6),
              Text(
                'Relief Requests Overview',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(label: 'Total', value: total, color: Colors.white),
              const SizedBox(width: 8),
              _StatChip(
                  label: 'Active',
                  value: active,
                  color: Colors.greenAccent.shade400),
              const SizedBox(width: 8),
              _StatChip(
                  label: 'Done',
                  value: completed,
                  color: Colors.lightBlueAccent.shade200),
              if (pending > 0) ...[
                const SizedBox(width: 8),
                _StatChip(
                    label: 'Pending',
                    value: pending,
                    color: Colors.amberAccent.shade200),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color),
          ),
          Text(label,
              style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Tab bar sliver delegate ──

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabBarDelegate({required this.child});

  @override
  double get minExtent => 48.0;
  @override
  double get maxExtent => 48.0;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

// ── Task Card ──

class _TaskCard extends StatelessWidget {
  final TaskModel task;

  const _TaskCard({required this.task});

  (String, Color, IconData) _statusMeta() {
    return switch (task.status) {
      TaskStatus.open => ('Waiting', AppTheme.statusPending, Icons.hourglass_top),
      TaskStatus.claimed => ('Volunteer Found', AppTheme.statusActive, Icons.person_add),
      TaskStatus.assigned => ('Assigned', AppTheme.statusActive, Icons.assignment_ind),
      TaskStatus.inProgress => ('In Progress', AppTheme.statusInProgress, Icons.directions_run),
      TaskStatus.submitted => ('Proof Submitted', AppTheme.infoColor, Icons.upload_file),
      TaskStatus.coordinatorVerified => ('Verified', AppTheme.successColor, Icons.verified_outlined),
      TaskStatus.paid => ('Completed', AppTheme.successColor, Icons.check_circle),
      TaskStatus.cancelled => ('Cancelled', AppTheme.statusFailed, Icons.cancel_outlined),
      _ => ('Unknown', AppTheme.statusNeutral, Icons.help_outline),
    };
  }

  Color _urgencyColor() {
    return switch (task.urgency) {
      TaskUrgency.critical => AppTheme.urgencyCritical,
      TaskUrgency.high => AppTheme.urgencyHigh,
      TaskUrgency.medium => AppTheme.urgencyMedium,
      TaskUrgency.low => AppTheme.urgencyLow,
      _ => AppTheme.statusNeutral,
    };
  }

  String _categoryEmoji() {
    return switch (task.category?.toUpperCase()) {
      'FOOD' => '🍞',
      'MEDICAL' => '💊',
      'SHELTER' => '🏠',
      'WATER' => '💧',
      'RESCUE' => '🆘',
      _ => '📦',
    };
  }

  String _timeAgo() {
    if (task.createdAt == null) return '';
    final dt = DateTime.tryParse(task.createdAt!);
    if (dt == null) return '';
    return timeago.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor, statusIcon) = _statusMeta();
    final urgencyColor = _urgencyColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/beneficiary/task/${task.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Urgency accent line
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
                  // Title row
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
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right,
                          size: 18, color: AppTheme.textDisabled),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Status + time row
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
                            Icon(statusIcon, size: 12, color: statusColor),
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
                      if (task.urgency == TaskUrgency.critical ||
                          task.urgency == TaskUrgency.high) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: urgencyColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.urgency.name.toUpperCase(),
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: urgencyColor),
                          ),
                        ),
                      ],
                      const Spacer(),
                      const Icon(Icons.schedule,
                          size: 11, color: AppTheme.textDisabled),
                      const SizedBox(width: 3),
                      Text(
                        _timeAgo(),
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
                                fontSize: 11, color: AppTheme.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Volunteer assigned
                  if (task.claimedByName != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 13, color: AppTheme.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          task.claimedByName!,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        const Text('is helping',
                            style: TextStyle(
                                fontSize: 11, color: AppTheme.textSecondary)),
                      ],
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
