import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reliefnet_app/core/api/api_client.dart';
import 'package:reliefnet_app/core/api/api_constants.dart';
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/features/tasks/domain/task_model.dart';
import 'package:reliefnet_app/features/tasks/presentation/tasks_provider.dart';
import 'package:reliefnet_app/providers/beneficiary_task_provider.dart';
import 'package:reliefnet_app/providers/coordinator_intelligence_provider.dart';
import 'package:reliefnet_app/screens/coordinator/coordinator_tasks_screen.dart';
import 'package:reliefnet_app/widgets/error_view.dart';
import 'package:reliefnet_app/widgets/status_chip.dart';
import 'package:reliefnet_app/widgets/task_status_timeline.dart';

// Provider for the verify-delivery action
final _verifyActionProvider = StateNotifierProvider<_VerifyNotifier, AsyncValue<void>>(
  (ref) => _VerifyNotifier(ref.read(apiClientProvider), ref),
);

class _VerifyNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiClient _client;
  final Ref _ref;

  _VerifyNotifier(this._client, this._ref) : super(const AsyncValue.data(null));

  Future<bool> verify(int deliveryId, int taskId, {required bool approve, String? notes}) async {
    state = const AsyncValue.loading();
    try {
      await _client.post(ApiConstants.verifyDelivery(deliveryId), data: {
        'verified': approve,
        'outcome': approve ? 'VERIFY' : 'FLAG',
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
      _ref.invalidate(taskDetailProvider(taskId));
      _ref.invalidate(taskDeliveryDetailsProvider(taskId));
      _ref.invalidate(coordinatorTasksProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

class CoordinatorTaskDetailScreen extends ConsumerWidget {
  final int taskId;

  const CoordinatorTaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailProvider(taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(taskDetailProvider(taskId));
              ref.invalidate(taskDeliveryDetailsProvider(taskId));
            },
          ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorView(
          message: 'Could not load task details.',
          onRetry: () => ref.invalidate(taskDetailProvider(taskId)),
        ),
        data: (task) => _CoordinatorTaskView(task: task),
      ),
    );
  }
}

class _CoordinatorTaskView extends ConsumerWidget {
  final TaskModel task;
  const _CoordinatorTaskView({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryAsync = ref.watch(taskDeliveryDetailsProvider(task.id));
    final verifyState = ref.watch(_verifyActionProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header card ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor.withValues(alpha: 0.08), AppTheme.primaryColor.withValues(alpha: 0.02)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      if (task.ngoName != null)
                        Row(
                          children: [
                            const Icon(Icons.business_outlined, size: 13, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(task.ngoName!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          ],
                        ),
                      if (task.campaignTitle != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.campaign_outlined, size: 13, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(task.campaignTitle!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                StatusChip(status: task.status),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Field Progress Timeline ──
          const _SectionHeader(title: 'Field Progress', icon: Icons.timeline_outlined),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TaskStatusTimeline(currentStatus: task.status),
            ),
          ),

          const SizedBox(height: 20),

          // ── Volunteer info ──
          if (task.claimedByName != null) ...[
            const _SectionHeader(title: 'Field Volunteer', icon: Icons.person_outline),
            const SizedBox(height: 10),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    task.claimedByName!.isNotEmpty ? task.claimedByName![0].toUpperCase() : '?',
                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(task.claimedByName!, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Field Agent', style: TextStyle(fontSize: 12)),
                trailing: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => context.push('/chat/${task.id}?title=${Uri.encodeComponent(task.title)}'),
                  color: AppTheme.primaryColor,
                  tooltip: 'Message volunteer',
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Delivery Proof + VERIFY/FLAG actions ──
          deliveryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
            data: (deliveries) {
              if (deliveries.isEmpty) return const SizedBox.shrink();
              final latest = deliveries.first;
              final deliveryId = latest['id'] as int?;
              final isSubmitted = task.status == TaskStatus.submitted;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(title: 'Delivery Proof', icon: Icons.fact_check_outlined),
                  const SizedBox(height: 10),

                  // Proof images (all storage_keys)
                  Builder(builder: (ctx) {
                    final keys = latest['storage_keys'];
                    final imageUrls = (keys is List && keys.isNotEmpty)
                        ? keys.whereType<String>().toList()
                        : <String>[];
                    if (imageUrls.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrls.length > 1) ...[
                          Text(
                            '${imageUrls.length} photos submitted',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: imageUrls.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (_, i) => GestureDetector(
                                onTap: () => _showImageFullscreen(context, imageUrls[i]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        imageUrls[i],
                                        width: 240,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 240,
                                          height: 200,
                                          color: Colors.grey.shade100,
                                          child: const Center(child: Icon(Icons.broken_image_outlined, size: 36, color: Colors.grey)),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 6,
                                        right: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                          child: Text('${i + 1}/${imageUrls.length}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ] else
                          GestureDetector(
                            onTap: () => _showImageFullscreen(context, imageUrls.first),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    imageUrls.first,
                                    height: 220,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 180,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Center(child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.zoom_in, size: 12, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Tap to expand', style: TextStyle(color: Colors.white, fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }),

                  // GPS proof location
                  Builder(builder: (ctx) {
                    final lat = latest['latitude'];
                    final lon = latest['longitude'];
                    if (lat == null || lon == null) return const SizedBox.shrink();
                    final latD = double.tryParse(lat.toString());
                    final lonD = double.tryParse(lon.toString());
                    if (latD == null || lonD == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.gps_fixed, size: 16, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Proof GPS Location',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.green.shade800),
                                  ),
                                  Text(
                                    '${latD.toStringAsFixed(5)}, ${lonD.toStringAsFixed(5)}',
                                    style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.verified_outlined, size: 16, color: Colors.green.shade600),
                          ],
                        ),
                      ),
                    );
                  }),

                  if (latest['notes'] != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Volunteer Notes', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                          const SizedBox(height: 4),
                          Text(latest['notes'], style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Submitted: ${_formatDate(latest['submitted_at'])}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),

                  // ── VERIFY / FLAG action buttons ──
                  if (isSubmitted && deliveryId != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.infoColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.pending_actions, size: 18, color: AppTheme.infoColor),
                              SizedBox(width: 8),
                              Text('Coordinator Action Required', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.infoColor, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text('Review the proof above and verify or flag this delivery.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: verifyState.isLoading
                                      ? null
                                      : () => _showFlagDialog(context, ref, deliveryId, task.id),
                                  icon: const Icon(Icons.flag_outlined, size: 18),
                                  label: const Text('Flag Issue'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.errorColor,
                                    side: const BorderSide(color: AppTheme.errorColor),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: FilledButton.icon(
                                  onPressed: verifyState.isLoading
                                      ? null
                                      : () => _confirmVerify(context, ref, deliveryId, task.id),
                                  icon: verifyState.isLoading
                                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Icon(Icons.verified_outlined, size: 18),
                                  label: const Text('Verify & Approve'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppTheme.successColor,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              );
            },
          ),

          // ── Operational Details ──
          const _SectionHeader(title: 'Operational Context', icon: Icons.info_outline),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  if (task.beneficiaryName != null)
                    _DetailRow(icon: Icons.person_outline, label: 'Beneficiary', value: task.beneficiaryName!),
                  _DetailRow(
                    icon: Icons.priority_high_outlined,
                    label: 'Urgency',
                    value: task.urgency.value[0] + task.urgency.value.substring(1).toLowerCase(),
                    valueColor: _urgencyColor(task.urgency.value),
                  ),
                  _DetailRow(
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: (task.category?.isNotEmpty == true) ? task.category! : 'General',
                  ),
                  if (task.familySize > 0)
                    _DetailRow(icon: Icons.groups_outlined, label: 'Family Size', value: '${task.familySize} persons'),
                  if (task.budgetPkr > 0)
                    _DetailRow(icon: Icons.payments_outlined, label: 'Budget', value: 'Rs ${NumberFormat('#,##0').format(task.budgetPkr)}'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Location ──
          const _SectionHeader(title: 'Field Location', icon: Icons.location_on_outlined),
          const SizedBox(height: 10),
          if (task.locationText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.place_outlined, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(child: Text(task.locationText!, style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
          if (task.latitude != null && task.longitude != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gps_fixed, size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    '${task.latitude?.toStringAsFixed(5)}, ${task.longitude?.toStringAsFixed(5)}',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_off_outlined, size: 16, color: AppTheme.textSecondary),
                  SizedBox(width: 8),
                  Text('GPS coordinates not recorded', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),

          const SizedBox(height: 28),

          // ── Flagged escalation notice ──
          if (task.status == TaskStatus.flagged)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.gavel, color: AppTheme.errorColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Under Admin Review', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.errorColor)),
                        Text('Escalated for high-level fraud investigation.', style: TextStyle(fontSize: 12, color: AppTheme.errorColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── Escalate to Admin ──
          if (task.status != TaskStatus.paid && task.status != TaskStatus.coordinatorVerified) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showEscalateDialog(context, ref, task),
                icon: const Icon(Icons.arrow_upward, size: 18),
                label: const Text('Escalate to Admin'),
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorColor, side: const BorderSide(color: AppTheme.errorColor)),
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Color _urgencyColor(String u) {
    switch (u) {
      case 'CRITICAL': return AppTheme.urgencyCritical;
      case 'HIGH': return AppTheme.urgencyHigh;
      case 'MEDIUM': return AppTheme.urgencyMedium;
      default: return AppTheme.urgencyLow;
    }
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return 'unknown';
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return raw.toString();
    return DateFormat('MMM d, HH:mm').format(dt.toLocal());
  }

  void _showImageFullscreen(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: InteractiveViewer(
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Future<void> _confirmVerify(BuildContext context, WidgetRef ref, int deliveryId, int taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify Delivery'),
        content: const Text('Mark this delivery as verified? This will release payment to the volunteer and notify the beneficiary.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.successColor),
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    HapticFeedback.heavyImpact();
    final notifier = ref.read(_verifyActionProvider.notifier);
    final ok = await notifier.verify(deliveryId, taskId, approve: true);

    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery verified! Volunteer has been notified.'), backgroundColor: AppTheme.successColor),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification failed. Please try again.'), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  void _showFlagDialog(BuildContext context, WidgetRef ref, int deliveryId, int taskId) {
    final notesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Flag Delivery Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Describe what is wrong with this delivery proof.', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 14),
            TextFormField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Reason', hintText: 'e.g. Wrong location, photo does not match...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              final ok = await ref.read(_verifyActionProvider.notifier).verify(
                deliveryId, taskId,
                approve: false,
                notes: notesCtrl.text.trim(),
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? 'Delivery flagged for review.' : 'Action failed. Please try again.'),
                  backgroundColor: ok ? AppTheme.warningColor : AppTheme.errorColor,
                ),
              );
              if (ok) context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, foregroundColor: Colors.white),
            child: const Text('Submit Flag'),
          ),
        ],
      ),
    );
  }

  void _showEscalateDialog(BuildContext context, WidgetRef ref, TaskModel task) {
    final reasonController = TextEditingController();
    String severity = 'MEDIUM';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Admin Escalation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Provide reason for escalating this task to central administration.', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Reason'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: severity,
                items: ['LOW', 'MEDIUM', 'HIGH'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => severity = v!),
                decoration: const InputDecoration(labelText: 'Severity'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                ref.read(intelligenceActionProvider.notifier).escalate(
                  entity: 'tasks',
                  id: task.id,
                  reason: reasonController.text.trim(),
                  severity: severity,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escalation sent to admin.')));
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryColor),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryColor),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          SizedBox(
            width: 88,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
