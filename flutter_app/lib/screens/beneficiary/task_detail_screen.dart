import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/features/tasks/domain/task_model.dart';
import 'package:reliefnet_app/providers/beneficiary_task_provider.dart';
import 'package:reliefnet_app/providers/feedback_provider.dart';
import 'package:reliefnet_app/widgets/error_view.dart';
import 'package:reliefnet_app/widgets/task_status_timeline.dart';

class BeneficiaryTaskDetailScreen extends ConsumerWidget {
  final int taskId;

  const BeneficiaryTaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(beneficiaryTaskDetailProvider(taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.invalidate(beneficiaryTaskDetailProvider(taskId));
            },
          ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading request details...',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
        error: (err, _) => ErrorView(
          message: 'Could not load request details. Check your connection.',
          onRetry: () => ref.invalidate(beneficiaryTaskDetailProvider(taskId)),
        ),
        data: (task) => _TaskDetailView(task: task),
      ),
    );
  }
}

class _TaskDetailView extends ConsumerWidget {
  final TaskModel task;

  const _TaskDetailView({required this.task});

  String _timeAgo() {
    if (task.createdAt == null) return '';
    final dt = DateTime.tryParse(task.createdAt!);
    if (dt == null) return '';
    return timeago.format(dt);
  }

  bool _canChat() =>
      task.status != TaskStatus.open &&
      task.status != TaskStatus.cancelled &&
      task.status != TaskStatus.unknown;

  void _handleCancel(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text(
            'Are you sure you want to cancel this request? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep it')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(taskActionProvider.notifier).cancel(task.id);
            },
            child:
                const Text('Cancel Request', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _urgencyColor() => switch (task.urgency) {
        TaskUrgency.critical => AppTheme.urgencyCritical,
        TaskUrgency.high => AppTheme.urgencyHigh,
        TaskUrgency.medium => AppTheme.urgencyMedium,
        TaskUrgency.low => AppTheme.urgencyLow,
        _ => AppTheme.statusNeutral,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryAsync = ref.watch(taskDeliveryDetailsProvider(task.id));
    final urgencyColor = _urgencyColor();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Urgency header strip
          Container(
            height: 4,
            color: urgencyColor,
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.schedule,
                                  size: 12, color: AppTheme.textDisabled),
                              const SizedBox(width: 4),
                              Text(
                                'Requested ${_timeAgo()}',
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.textDisabled),
                              ),
                              if (task.category != null) ...[
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    task.category!,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primaryColor),
                                  ),
                                ),
                              ],
                              if (task.urgency == TaskUrgency.critical ||
                                  task.urgency == TaskUrgency.high) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: urgencyColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    task.urgency.name.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: urgencyColor),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Action buttons (only when open)
                if (task.status == TaskStatus.open) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.push('/beneficiary/task/${task.id}/edit'),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.errorColor),
                          onPressed: () => _handleCancel(context, ref),
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Progress timeline
                const _SectionHeader(
                  icon: Icons.track_changes_outlined,
                  title: 'Progress Tracking',
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TaskStatusTimeline(currentStatus: task.status),
                  ),
                ),

                // Volunteer Info
                if (task.claimedByName != null) ...[
                  const SizedBox(height: 20),
                  const _SectionHeader(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'Assigned Volunteer',
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor:
                                AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: Text(
                              task.claimedByName!.isNotEmpty
                                  ? task.claimedByName![0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.claimedByName!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14),
                                ),
                                const Text(
                                  'Working on your request',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          if (_canChat())
                            FilledButton.icon(
                              onPressed: () => context.push(
                                  '/chat/${task.id}?title=${Uri.encodeComponent(task.title)}'),
                              icon: const Icon(Icons.chat_bubble_outline,
                                  size: 16),
                              label: const Text('Chat'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                textStyle: const TextStyle(fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Description
                if (task.description != null) ...[
                  const SizedBox(height: 20),
                  const _SectionHeader(
                    icon: Icons.description_outlined,
                    title: 'Request Details',
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.category != null) ...[
                            _DetailRow(
                                label: 'Category', value: task.category!),
                            const SizedBox(height: 8),
                          ],
                          if (task.familySize > 0) ...[
                            _DetailRow(
                                label: 'Family Size',
                                value: '${task.familySize} people'),
                            const SizedBox(height: 8),
                          ],
                          const Text(
                            'Description',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            style: const TextStyle(
                                fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Items Needed
                if (task.itemsNeeded.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _SectionHeader(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Items Needed',
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: task.itemsNeeded
                            .map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                          '${item.item} (qty: ${item.quantity})'),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],

                // Delivery Proof
                const SizedBox(height: 20),
                deliveryAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (deliveries) {
                    if (deliveries.isEmpty) return const SizedBox.shrink();
                    final latest = deliveries.first;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader(
                          icon: Icons.verified_user_outlined,
                          title: 'Execution Proof',
                        ),
                        const SizedBox(height: 10),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Builder(builder: (_) {
                                  final keys = latest['storage_keys'];
                                  final proofUrl = (keys is List && keys.isNotEmpty)
                                      ? keys.first as String?
                                      : null;
                                  if (proofUrl == null) return const SizedBox.shrink();
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      proofUrl,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 120,
                                        color: Colors.grey.shade100,
                                        child: const Icon(
                                            Icons.broken_image_outlined,
                                            size: 40,
                                            color: AppTheme.textDisabled),
                                      ),
                                    ),
                                  );
                                }),
                                if (latest['notes'] != null) ...[
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Volunteer Notes',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(latest['notes']),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 12, color: AppTheme.textDisabled),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Submitted: ${DateFormat('MMM d, HH:mm').format(DateTime.parse(latest['submitted_at']))}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textDisabled),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Feedback
                deliveryAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (deliveries) {
                    if (deliveries.isEmpty) return const SizedBox.shrink();
                    return _FeedbackSection(
                        task: task, delivery: deliveries.first);
                  },
                ),

                // Location
                const SizedBox(height: 20),
                const _SectionHeader(
                  icon: Icons.location_on_outlined,
                  title: 'Delivery Location',
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.locationText != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.pin_drop_outlined,
                                  size: 16, color: AppTheme.primaryColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  task.locationText!,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        if (task.latitude != null &&
                            task.longitude != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor
                                  .withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.gps_fixed,
                                    size: 13, color: AppTheme.primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  '${task.latitude!.toStringAsFixed(5)}, ${task.longitude!.toStringAsFixed(5)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else
                          const Text(
                            'GPS coordinates not available',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textDisabled),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ──

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 15, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary),
        ),
        Text(value,
            style:
                const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
      ],
    );
  }
}

// ── Feedback Section ──

class _FeedbackSection extends ConsumerStatefulWidget {
  final TaskModel task;
  final dynamic delivery;

  const _FeedbackSection({required this.task, required this.delivery});

  @override
  ConsumerState<_FeedbackSection> createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends ConsumerState<_FeedbackSection> {
  int _rating = 5;
  String _status = 'RECEIVED';
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_status == 'NOT_RECEIVED' && _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the issue'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    HapticFeedback.lightImpact();
    ref.read(beneficiaryFeedbackProvider.notifier).submit(
          deliveryId: widget.delivery['id'],
          taskId: widget.task.id,
          status: _status,
          rating: _status == 'NOT_RECEIVED' ? null : _rating,
          comment: _commentController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final feedbackState = ref.watch(beneficiaryFeedbackProvider);
    final hasFeedback = widget.delivery['confirmation_status'] != null;

    if (hasFeedback) {
      final status = widget.delivery['confirmation_status'] as String?;
      final rating = widget.delivery['beneficiary_rating'];
      final comment = widget.delivery['beneficiary_comment'] as String?;
      final isGood = status == 'RECEIVED';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const _SectionHeader(
            icon: Icons.check_circle_outlined,
            title: 'Your Confirmation',
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isGood ? Icons.check_circle : Icons.warning_amber,
                        color: isGood ? AppTheme.successColor : AppTheme.warningColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isGood ? 'Aid Received' : 'Issue Reported: $status',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isGood ? AppTheme.successColor : AppTheme.warningColor,
                        ),
                      ),
                    ],
                  ),
                  if (rating != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < (rating as num).toInt()
                              ? Icons.star
                              : Icons.star_border,
                          size: 18,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                  if (comment != null && comment.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '"$comment"',
                      style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    if (!['SUBMITTED', 'COORDINATOR_VERIFIED', 'PAID']
        .contains(widget.task.status.value)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const _SectionHeader(
          icon: Icons.rate_review_outlined,
          title: 'Confirm Aid Receipt',
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Have you received the requested aid?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ReceiptChip(
                      label: 'Yes, Received',
                      icon: Icons.check_circle_outline,
                      selected: _status == 'RECEIVED',
                      color: AppTheme.successColor,
                      onTap: () => setState(() => _status = 'RECEIVED'),
                    ),
                    _ReceiptChip(
                      label: 'Partial',
                      icon: Icons.adjust_outlined,
                      selected: _status == 'PARTIAL',
                      color: AppTheme.warningColor,
                      onTap: () => setState(() => _status = 'PARTIAL'),
                    ),
                    _ReceiptChip(
                      label: 'Not Received',
                      icon: Icons.cancel_outlined,
                      selected: _status == 'NOT_RECEIVED',
                      color: AppTheme.errorColor,
                      onTap: () => setState(() => _status = 'NOT_RECEIVED'),
                    ),
                  ],
                ),
                if (_status != 'NOT_RECEIVED') ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Rate the volunteer:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      5,
                      (i) => GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _rating = i + 1);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            i < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                TextFormField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: _status == 'NOT_RECEIVED'
                        ? 'Describe the issue *'
                        : 'Comments (optional)',
                    prefixIcon:
                        const Icon(Icons.comment_outlined, size: 18),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: feedbackState.isLoading ? null : _submit,
                    child: feedbackState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Submit Confirmation'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ReceiptChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ReceiptChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: selected ? color : Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? color : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
