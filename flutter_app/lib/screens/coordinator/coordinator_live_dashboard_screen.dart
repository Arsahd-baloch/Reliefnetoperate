import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/providers/coordinator_intelligence_provider.dart';
import 'package:reliefnet_app/utils/safe_parser.dart';

class CoordinatorLiveDashboardScreen extends ConsumerWidget {
  const CoordinatorLiveDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intelAsync = ref.watch(coordinatorIntelligenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Field Awareness'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(coordinatorIntelligenceProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: intelAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.textSecondary),
              const SizedBox(height: 12),
              Text('Could not load field data', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(coordinatorIntelligenceProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (intel) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Key Metrics ──
              _buildMetricsRow(intel),
              const SizedBox(height: 24),

              // ── Operation Health ──
              _sectionLabel('Operation Health', Icons.monitor_heart_outlined),
              const SizedBox(height: 12),
              _buildHealthCard(intel),
              const SizedBox(height: 24),

              // ── Stuck / At-Risk Tasks ──
              _sectionLabel('At-Risk Operations', Icons.warning_amber_outlined, color: AppTheme.warningColor),
              const SizedBox(height: 12),
              if (intel.stuckTasks.isEmpty)
                _buildAllGoodCard()
              else
                ...intel.stuckTasks.map((t) => _StuckTaskTile(task: t)),

              const SizedBox(height: 24),

              // ── Volunteer Reliability ──
              _sectionLabel('Volunteer Reliability', Icons.workspace_premium_outlined),
              const SizedBox(height: 12),
              if (intel.topVolunteers.isEmpty)
                const Card(child: ListTile(title: Text('No volunteer data available yet.')))
              else
                ...intel.topVolunteers.asMap().entries.map((e) => _ReliabilityTile(rank: e.key + 1, volunteer: e.value)),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsRow(OperationalIntelligence intel) {
    final verified = intel.verificationStats['verified'] ?? 0;
    final flagged = intel.verificationStats['flagged'] ?? 0;
    final total = verified + flagged;
    final successRate = total == 0 ? 100 : ((verified / total) * 100).round();
    final stuckCount = intel.stuckTasks.length;

    return Column(
      children: [
        Row(
          children: [
            _MetricCard(
              label: 'Verified',
              value: verified.toString(),
              icon: Icons.check_circle_outline,
              color: AppTheme.successColor,
            ),
            const SizedBox(width: 10),
            _MetricCard(
              label: 'Flagged',
              value: flagged.toString(),
              icon: Icons.flag_outlined,
              color: AppTheme.errorColor,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _MetricCard(
              label: 'Success Rate',
              value: '$successRate%',
              icon: Icons.auto_graph_outlined,
              color: successRate >= 80 ? AppTheme.successColor : AppTheme.warningColor,
            ),
            const SizedBox(width: 10),
            _MetricCard(
              label: 'At-Risk Tasks',
              value: stuckCount.toString(),
              icon: Icons.warning_amber_outlined,
              color: stuckCount > 0 ? AppTheme.warningColor : AppTheme.successColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthCard(OperationalIntelligence intel) {
    final verified = intel.verificationStats['verified'] ?? 0;
    final flagged = intel.verificationStats['flagged'] ?? 0;
    final total = verified + flagged;
    final fraudRate = total == 0 ? 0.0 : (flagged / total) * 100;

    final (healthLabel, healthColor, healthIcon) = fraudRate < 5
        ? ('Excellent', AppTheme.successColor, Icons.sentiment_very_satisfied_outlined)
        : fraudRate < 20
            ? ('Moderate', AppTheme.warningColor, Icons.sentiment_neutral_outlined)
            : ('Needs Attention', AppTheme.errorColor, Icons.sentiment_very_dissatisfied_outlined);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: healthColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: healthColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(healthIcon, color: healthColor, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(healthLabel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: healthColor)),
                  Text('${fraudRate.toStringAsFixed(1)}% fraud/flag rate', style: TextStyle(fontSize: 12, color: healthColor.withValues(alpha: 0.7))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total == 0 ? 1.0 : verified / total,
              backgroundColor: AppTheme.errorColor.withValues(alpha: 0.2),
              color: healthColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$verified verified', style: TextStyle(fontSize: 11, color: healthColor, fontWeight: FontWeight.w600)),
              Text('$flagged flagged', style: const TextStyle(fontSize: 11, color: AppTheme.errorColor, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllGoodCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: AppTheme.successColor, size: 24),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('All Clear', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.successColor)),
              Text('No at-risk operations detected.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String title, IconData icon, {Color color = AppTheme.primaryColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
                Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StuckTaskTile extends StatelessWidget {
  final dynamic task;
  const _StuckTaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_amber_outlined, color: AppTheme.warningColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SafeParser.toStringSafe(task['title'], defaultValue: 'Untitled Task'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  const Text('In progress for over 24 hours', style: TextStyle(fontSize: 11, color: AppTheme.warningColor)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ReliabilityTile extends StatelessWidget {
  final int rank;
  final dynamic volunteer;

  const _ReliabilityTile({required this.rank, required this.volunteer});

  @override
  Widget build(BuildContext context) {
    final name = SafeParser.toStringSafe(volunteer['name'], defaultValue: 'Unknown');
    final totalTasks = SafeParser.paramInt(volunteer['total_tasks']);
    final flags = SafeParser.paramInt(volunteer['flags']);
    final reliabilityPct = (100 - (flags * 20)).clamp(0, 100);
    final color = reliabilityPct >= 80 ? AppTheme.successColor
        : reliabilityPct >= 60 ? AppTheme.warningColor
        : AppTheme.errorColor;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: rank <= 3 ? AppTheme.warningColor.withValues(alpha: 0.15) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('#$rank', style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: rank <= 3 ? AppTheme.warningColor : AppTheme.textSecondary,
                )),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: Text(initial, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('$totalTasks tasks performed', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text('$reliabilityPct%', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
