import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reliefnet_app/providers/coordinator_intelligence_provider.dart';
import 'package:reliefnet_app/widgets/error_view.dart';
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/utils/safe_parser.dart';

class CoordinatorIntelligenceDashboard extends ConsumerWidget {
  const CoordinatorIntelligenceDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intelAsync = ref.watch(coordinatorIntelligenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Intelligence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () => context.push('/coordinator/map'),
            tooltip: 'Field Map',
          ),
          IconButton(
            icon: const Icon(Icons.sos_rounded, color: Colors.red),
            onPressed: () => _showEmergencyDialog(context, ref),
            tooltip: 'Emergency Escalation',
          ),
          IconButton(
            icon: const Icon(Icons.policy_outlined, color: Color(0xFF9B59B6)),
            onPressed: () => context.push('/coordinator/signals'),
            tooltip: 'Fraud Signals',
          ),
        ],
      ),
      body: intelAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorView(
            message: 'Failed to load intelligence',
            onRetry: () => ref.invalidate(coordinatorIntelligenceProvider)),
        data: (intel) => RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(coordinatorIntelligenceProvider),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummarySection(context, intel),
                const SizedBox(height: 24),
                _buildStuckTasksList(context, intel.stuckTasks),
                const SizedBox(height: 24),
                _buildVolunteerPerformance(context, intel.topVolunteers),
                const SizedBox(height: 24),
                _buildNgoPerformance(context, intel.ngoPerformance),
                const SizedBox(height: 24),
                _ActionCard(
                  icon: Icons.campaign_outlined,
                  title: 'Broadcast Alert',
                  subtitle: 'Send real-time alerts to volunteers',
                  onTap: () => context.push('/coordinator/broadcast'),
                  accentColor: const Color(0xFF3B82F6),
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.bolt_outlined,
                  title: 'Live Awareness',
                  subtitle: 'Real-time operational field state',
                  onTap: () => context.push('/coordinator/live'),
                  accentColor: const Color(0xFF10B981),
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.history_edu,
                  title: 'Escalation History',
                  subtitle: 'Review issues sent to Admin',
                  onTap: () => context.push('/coordinator/escalations'),
                  accentColor: const Color(0xFF9B59B6),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmtStatus(String status) => status
      .split('_')
      .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');

  void _showEmergencyDialog(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();
    String severity = 'HIGH';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.red),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Emergency Escalation',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This alerts all platform admins immediately. '
                    'Use only for major failures or regional disasters.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonController,
                    textInputAction: TextInputAction.done,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Situation Report',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: severity,
                    decoration: const InputDecoration(
                      labelText: 'Severity',
                      border: OutlineInputBorder(),
                    ),
                    items: ['HIGH', 'CRITICAL']
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => severity = v);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              icon: const Icon(Icons.campaign, color: Colors.white),
              label: const FittedBox(
                child: Text(
                  'Broadcast Emergency',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onPressed: () async {
                final reason = reasonController.text.trim();

                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter situation details'),
                    ),
                  );
                  return;
                }

                ref.read(intelligenceActionProvider.notifier).emergencyEscalate(
                      targetEntity: 'operational_scope',
                      targetId: 0,
                      reason: reason,
                      severity: severity,
                    );

                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Emergency alert broadcasted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(
      BuildContext context, OperationalIntelligence intel) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Verified',
            value: intel.verificationStats['verified'].toString(),
            color: Colors.green,
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Flagged',
            value: intel.verificationStats['flagged'].toString(),
            color: Colors.orange,
            icon: Icons.flag_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildStuckTasksList(BuildContext context, List<dynamic> tasks) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text('Stuck Tasks (>24h)',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (tasks.isNotEmpty)
                  Tag(label: '${tasks.length}', color: Colors.red),
              ],
            ),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No stuck tasks detected.',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              )
            else
              ...tasks.take(3).map((t) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t['title'] ?? 'Untitled',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: Text('Status: ${_fmtStatus(t['status'] ?? 'Unknown')}',
                        style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, size: 16),
                    onTap: () => context.push('/coordinator/task/${t['id']}'),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteerPerformance(
      BuildContext context, List<dynamic> volunteers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Volunteer Reliability',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...volunteers.take(5).map((v) {
          final totalTasks = SafeParser.paramInt(v['total_tasks']);
          final flags = SafeParser.paramInt(v['flags']);

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              dense: true,
              title: Text(
                  SafeParser.toStringSafe(v['name'], defaultValue: 'Unknown'),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Total Tasks: $totalTasks'),
              trailing: flags > 0
                  ? Tag(label: '$flags Flags', color: Colors.orange)
                  : const Tag(label: 'Reliable', color: Colors.green),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNgoPerformance(BuildContext context, List<dynamic> ngos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NGO Execution Speed',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...ngos.take(5).map((n) {
          final totalTasks = SafeParser.paramInt(n['total_tasks']);
          final avgHours = SafeParser.toDouble(n['avg_completion_hours']);

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              dense: true,
              title: Text(
                  SafeParser.toStringSafe(n['org_name'],
                      defaultValue: 'Unknown NGO'),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Tasks: $totalTasks'),
              trailing: Text('${avgHours.truncate()}h avg',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor)),
            ),
          );
        }),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class Tag extends StatelessWidget {
  final String label;
  final Color color;
  const Tag({super.key, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? accentColor;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Theme.of(context).colorScheme.primary;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.15)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: color.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
