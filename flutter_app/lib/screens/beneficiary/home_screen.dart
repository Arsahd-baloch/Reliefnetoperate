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
import 'package:reliefnet_app/widgets/shimmer_card.dart';
import 'package:reliefnet_app/widgets/empty_state.dart';

class BeneficiaryHomeScreen extends ConsumerWidget {
  const BeneficiaryHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    if (user == null) return const SizedBox.shrink();

    final tasksAsync = ref.watch(myTasksProvider(user.id));
    final notifications = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: tasksAsync.when(
        loading: () => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _GreetingHeader(user: user)),
            const SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: ShimmerList(count: 3, itemHeight: 100),
              ),
            ),
          ],
        ),
        error: (err, _) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _GreetingHeader(user: user)),
            SliverToBoxAdapter(
              child: _ErrorRetryCard(
                onRetry: () => ref.invalidate(myTasksProvider(user.id)),
              ),
            ),
          ],
        ),
        data: (tasks) {
          final activeTasks = tasks
              .where((t) =>
                  t.status == TaskStatus.open ||
                  t.status == TaskStatus.claimed ||
                  t.status == TaskStatus.assigned ||
                  t.status == TaskStatus.inProgress)
              .toList();
          final completedTasks = tasks
              .where((t) =>
                  t.status == TaskStatus.paid ||
                  t.status == TaskStatus.coordinatorVerified)
              .toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myTasksProvider(user.id)),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _GreetingHeader(user: user),
                ),
                SliverToBoxAdapter(
                  child: _StatsRow(
                    active: activeTasks.length,
                    completed: completedTasks.length,
                    total: tasks.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 4)),
                const SliverToBoxAdapter(
                  child: _QuickActionGrid(),
                ),
                if (activeTasks.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _ActiveRequestsSection(
                      tasks: activeTasks.take(3).toList(),
                    ),
                  ),
                if (notifications.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _NotificationsSection(
                      notifications: notifications.take(2).toList(),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: _PreparednessTipsSection(),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Greeting Header ──────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  final dynamic user;

  const _GreetingHeader({required this.user});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _firstName {
    final name = (user?.name as String?) ?? 'Friend';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 56, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting,',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _firstName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'DisasterAid Relief Network',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                ctx.push('/beneficiary/emergency-request');
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.errorColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sos_outlined, color: Colors.white, size: 22),
                    SizedBox(height: 2),
                    Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int active;
  final int completed;
  final int total;

  const _StatsRow({
    required this.active,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _StatChip(
              label: 'Active',
              value: active,
              color: AppTheme.statusActive,
              icon: Icons.pending_actions_outlined,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatChip(
              label: 'Completed',
              value: completed,
              color: AppTheme.infoColor,
              icon: Icons.check_circle_outline,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatChip(
              label: 'Total',
              value: total,
              color: AppTheme.primaryColor,
              icon: Icons.list_alt_outlined,
            ),
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
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Action Grid ─────────────────────────────────────────────────────────

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  label: 'Request Help',
                  icon: Icons.add_circle_outline,
                  color: AppTheme.accentColor,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/beneficiary/create-task');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionCard(
                  label: 'Emergency SOS',
                  icon: Icons.sos_outlined,
                  color: AppTheme.errorColor,
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    context.push('/beneficiary/emergency-request');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  label: 'Aid Board',
                  icon: Icons.volunteer_activism_outlined,
                  color: AppTheme.urgencyHigh,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.go('/beneficiary/inkind');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionCard(
                  label: 'My Requests',
                  icon: Icons.list_alt_outlined,
                  color: AppTheme.primaryColor,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.go('/beneficiary/tasks');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Active Requests Section ───────────────────────────────────────────────────

class _ActiveRequestsSection extends StatelessWidget {
  final List<TaskModel> tasks;

  const _ActiveRequestsSection({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Active Requests',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go('/beneficiary/tasks'),
                child: const Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tasks.map((task) => _ActiveTaskCard(task: task)),
        ],
      ),
    );
  }
}

class _ActiveTaskCard extends StatelessWidget {
  final TaskModel task;

  const _ActiveTaskCard({required this.task});

  (String, Color) _statusInfo() {
    return switch (task.status) {
      TaskStatus.open => ('Waiting', AppTheme.statusPending),
      TaskStatus.claimed => ('Volunteer Found', AppTheme.statusActive),
      TaskStatus.assigned => ('Assigned', AppTheme.statusActive),
      TaskStatus.inProgress => ('In Progress', AppTheme.statusInProgress),
      _ => ('Pending', AppTheme.statusPending),
    };
  }

  Color _urgencyColor() {
    return switch (task.urgency) {
      TaskUrgency.critical => AppTheme.urgencyCritical,
      TaskUrgency.high => AppTheme.urgencyHigh,
      TaskUrgency.medium => AppTheme.urgencyMedium,
      TaskUrgency.low => AppTheme.urgencyLow,
      _ => AppTheme.textDisabled,
    };
  }

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = _statusInfo();
    final urgencyColor = _urgencyColor();

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/beneficiary/task/${task.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: urgencyColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                      if (task.claimedByName != null) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.person_outline,
                          size: 11,
                          color: AppTheme.textDisabled,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            task.claimedByName!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                size: 18, color: AppTheme.textDisabled),
          ],
        ),
      ),
    );
  }
}

// ── Notifications Section ─────────────────────────────────────────────────────

class _NotificationsSection extends StatelessWidget {
  final List<AppNotification> notifications;

  const _NotificationsSection({required this.notifications});

  IconData _notifIcon(String type) {
    return switch (type.toUpperCase()) {
      'TASK_CLAIMED' => Icons.person_add_outlined,
      'TASK_COMPLETED' => Icons.check_circle_outline,
      'TASK_VERIFIED' => Icons.verified_outlined,
      'PAYMENT' => Icons.payments_outlined,
      'EMERGENCY' => Icons.warning_amber_outlined,
      _ => Icons.notifications_outlined,
    };
  }

  Color _notifColor(String type) {
    return switch (type.toUpperCase()) {
      'TASK_CLAIMED' => AppTheme.statusActive,
      'TASK_COMPLETED' => AppTheme.successColor,
      'TASK_VERIFIED' => AppTheme.infoColor,
      'PAYMENT' => AppTheme.accentColor,
      'EMERGENCY' => AppTheme.errorColor,
      _ => AppTheme.primaryColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Recent Updates',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/beneficiary/notifications'),
                child: const Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...notifications.map(
            (n) => _NotificationTile(
              notification: n,
              icon: _notifIcon(n.type),
              iconColor: _notifColor(n.type),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final IconData icon;
  final Color iconColor;

  const _NotificationTile({
    required this.notification,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeago.format(notification.timestamp, allowFromNow: true),
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Preparedness Tips Section ─────────────────────────────────────────────────

class _PreparednessTipsSection extends StatelessWidget {
  const _PreparednessTipsSection();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Disaster Preparedness Tips',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 10),
          _TipCard(
            icon: Icons.water_drop_outlined,
            iconColor: AppTheme.infoColor,
            title: 'Store Emergency Water',
            body:
                'Keep at least 1 gallon of water per person per day for 3 days in sealed containers.',
          ),
          SizedBox(height: 8),
          _TipCard(
            icon: Icons.contacts_outlined,
            iconColor: AppTheme.accentColor,
            title: 'Save Contacts Offline',
            body:
                'Keep emergency contacts written down or saved offline in case networks go down.',
          ),
          SizedBox(height: 8),
          _TipCard(
            icon: Icons.location_on_outlined,
            iconColor: AppTheme.urgencyHigh,
            title: 'Know Your Relief Center',
            body:
                'Learn the location of your nearest government or NGO relief distribution center.',
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  const _TipCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error Retry Card ──────────────────────────────────────────────────────────

class _ErrorRetryCard extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorRetryCard({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            const Icon(Icons.wifi_off_outlined,
                color: AppTheme.errorColor, size: 36),
            const SizedBox(height: 10),
            const Text(
              'Could not load your data',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Check your connection and try again.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                onRetry();
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State (no tasks yet) ────────────────────────────────────────────────

// ignore: unused_element
class _NoTasksYet extends StatelessWidget {
  const _NoTasksYet();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.assignment_outlined,
      title: 'No requests yet',
      subtitle: 'Tap "New Request" to ask for help.',
    );
  }
}
