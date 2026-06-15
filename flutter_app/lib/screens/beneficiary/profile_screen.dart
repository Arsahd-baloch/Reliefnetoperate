import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/features/auth/presentation/auth_provider.dart';
import 'package:reliefnet_app/features/tasks/domain/task_model.dart';
import 'package:reliefnet_app/providers/beneficiary_task_provider.dart';
import 'package:reliefnet_app/widgets/shimmer_card.dart';

class BeneficiaryProfileScreen extends ConsumerWidget {
  const BeneficiaryProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    if (user == null) return const SizedBox.shrink();

    final tasksAsync = ref.watch(myTasksProvider(user.id));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: tasksAsync.when(
        loading: () => const ShimmerList(count: 5, itemHeight: 100),
        error: (_, __) => _ProfileBody(user: user, tasks: const []),
        data: (tasks) => _ProfileBody(user: user, tasks: tasks),
      ),
    );
  }
}

// ── Main Profile Body ─────────────────────────────────────────────────────────

class _ProfileBody extends StatelessWidget {
  final dynamic user;
  final List<TaskModel> tasks;

  const _ProfileBody({required this.user, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final name = (user?.name as String?) ?? 'User';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    final fulfilled = tasks
        .where((t) =>
            t.status == TaskStatus.paid ||
            t.status == TaskStatus.coordinatorVerified)
        .length;
    final inProgress = tasks
        .where((t) =>
            t.status == TaskStatus.claimed ||
            t.status == TaskStatus.assigned ||
            t.status == TaskStatus.inProgress)
        .length;
    final cancelled =
        tasks.where((t) => t.status == TaskStatus.cancelled).length;
    final total = tasks.length;

    // Category breakdown
    const categories = ['FOOD', 'MEDICAL', 'SHELTER', 'WATER', 'RESCUE', 'OTHER'];
    final categoryMap = <String, int>{};
    for (final cat in categories) {
      final count = tasks
          .where((t) => (t.category?.toUpperCase() ?? 'OTHER') == cat)
          .length;
      if (count > 0) categoryMap[cat] = count;
    }
    final maxCategory = categoryMap.isEmpty
        ? 1
        : categoryMap.values.reduce((a, b) => a > b ? a : b);

    final recentTasks = tasks.reversed.take(3).toList();

    return CustomScrollView(
      slivers: [
        // ── Header ──
        SliverToBoxAdapter(
          child: _ProfileHeader(name: name, initial: initial),
        ),

        // ── Lifetime Impact Stats ──
        const SliverToBoxAdapter(
          child: _SectionTitle(title: 'Lifetime Impact'),
        ),
        SliverToBoxAdapter(
          child: _ImpactStatsGrid(
            total: total,
            fulfilled: fulfilled,
            inProgress: inProgress,
            cancelled: cancelled,
          ),
        ),

        // ── Category Breakdown ──
        if (categoryMap.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: _SectionTitle(title: 'Requests by Category'),
          ),
          SliverToBoxAdapter(
            child: _CategoryBreakdown(
              categoryMap: categoryMap,
              maxCount: maxCategory,
            ),
          ),
        ],

        // ── Recent Requests ──
        if (recentTasks.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: _SectionTitle(title: 'Recent Requests'),
          ),
          SliverToBoxAdapter(
            child: _RecentRequestsList(tasks: recentTasks),
          ),
        ],

        // ── Footer ──
        const SliverToBoxAdapter(
          child: _AppInfoFooter(),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ── Profile Header ─────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String initial;

  const _ProfileHeader({required this.name, required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 56, 16, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Beneficiary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: Colors.white54, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Member since June 2026',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_outlined,
                  color: Colors.white70, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}

// ── Impact Stats Grid ─────────────────────────────────────────────────────────

class _ImpactStatsGrid extends StatelessWidget {
  final int total;
  final int fulfilled;
  final int inProgress;
  final int cancelled;

  const _ImpactStatsGrid({
    required this.total,
    required this.fulfilled,
    required this.inProgress,
    required this.cancelled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
        children: [
          _ImpactStatCard(
            label: 'Total Requests',
            value: total,
            icon: Icons.list_alt_outlined,
            color: AppTheme.primaryColor,
          ),
          _ImpactStatCard(
            label: 'Fulfilled',
            value: fulfilled,
            icon: Icons.check_circle_outline,
            color: AppTheme.successColor,
          ),
          _ImpactStatCard(
            label: 'In Progress',
            value: inProgress,
            icon: Icons.pending_actions_outlined,
            color: AppTheme.statusInProgress,
          ),
          _ImpactStatCard(
            label: 'Cancelled',
            value: cancelled,
            icon: Icons.cancel_outlined,
            color: AppTheme.errorColor,
          ),
        ],
      ),
    );
  }
}

class _ImpactStatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _ImpactStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Breakdown ────────────────────────────────────────────────────────

class _CategoryBreakdown extends StatelessWidget {
  final Map<String, int> categoryMap;
  final int maxCount;

  const _CategoryBreakdown({
    required this.categoryMap,
    required this.maxCount,
  });

  (IconData, Color) _catMeta(String cat) {
    return switch (cat) {
      'FOOD' => (Icons.fastfood_outlined, AppTheme.urgencyHigh),
      'MEDICAL' => (Icons.medical_services_outlined, AppTheme.errorColor),
      'SHELTER' => (Icons.home_outlined, AppTheme.infoColor),
      'WATER' => (Icons.water_drop_outlined, AppTheme.accentColor),
      'RESCUE' => (Icons.sos_outlined, AppTheme.urgencyCritical),
      _ => (Icons.inventory_2_outlined, AppTheme.primaryColor),
    };
  }

  @override
  Widget build(BuildContext context) {
    final sorted = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: sorted.map((entry) {
          final (icon, color) = _catMeta(entry.key);
          final ratio = maxCount == 0 ? 0.0 : entry.value / maxCount;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _catLabel(entry.key),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            entry.value.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 5,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _catLabel(String cat) {
    return switch (cat) {
      'FOOD' => 'Food',
      'MEDICAL' => 'Medical',
      'SHELTER' => 'Shelter',
      'WATER' => 'Water',
      'RESCUE' => 'Rescue',
      _ => 'Other',
    };
  }
}

// ── Recent Requests List ──────────────────────────────────────────────────────

class _RecentRequestsList extends StatelessWidget {
  final List<TaskModel> tasks;

  const _RecentRequestsList({required this.tasks});

  (String, Color) _statusMeta(TaskStatus status) {
    return switch (status) {
      TaskStatus.open => ('Open', AppTheme.statusPending),
      TaskStatus.claimed => ('Claimed', AppTheme.statusActive),
      TaskStatus.assigned => ('Assigned', AppTheme.statusActive),
      TaskStatus.inProgress => ('In Progress', AppTheme.statusInProgress),
      TaskStatus.submitted => ('Submitted', AppTheme.infoColor),
      TaskStatus.coordinatorVerified => ('Verified', AppTheme.successColor),
      TaskStatus.paid => ('Completed', AppTheme.successColor),
      TaskStatus.cancelled => ('Cancelled', AppTheme.errorColor),
      _ => ('Unknown', AppTheme.textDisabled),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: tasks.asMap().entries.map((entry) {
          final idx = entry.key;
          final task = entry.value;
          final (statusLabel, statusColor) = _statusMeta(task.status);
          final isLast = idx == tasks.length - 1;

          String timeAgo() {
            if (task.createdAt == null) return '';
            final dt = DateTime.tryParse(task.createdAt!);
            if (dt == null) return '';
            return timeago.format(dt);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          Text(
                            timeAgo(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textDisabled,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 14,
                  endIndent: 14,
                  color: Colors.grey.shade100,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── App Info Footer ───────────────────────────────────────────────────────────

class _AppInfoFooter extends StatelessWidget {
  const _AppInfoFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_outline,
                        color: AppTheme.errorColor, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'DisasterAid.pk',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Version 2.1.0',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textDisabled,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Connecting communities in times of need',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
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
