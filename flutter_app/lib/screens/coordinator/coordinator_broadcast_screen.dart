import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reliefnet_app/providers/coordinator_intelligence_provider.dart';
import 'package:reliefnet_app/screens/coordinator/coordinator_tasks_screen.dart';

class CoordinatorBroadcastScreen extends ConsumerStatefulWidget {
  const CoordinatorBroadcastScreen({super.key});

  @override
  ConsumerState<CoordinatorBroadcastScreen> createState() =>
      _CoordinatorBroadcastScreenState();
}

class _CoordinatorBroadcastScreenState
    extends ConsumerState<CoordinatorBroadcastScreen> {
  final _messageController = TextEditingController();

  String _scope = 'TASK';
  String _urgency = 'MEDIUM';

  int? _targetId;

  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendBroadcast() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _targetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields'),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Broadcast'),
        content: Text(
          'Send this $_urgency urgency alert to all volunteers linked to this $_scope?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _sending = true);

    try {
      await ref.read(intelligenceActionProvider.notifier).broadcast(
            scope: _scope,
            targetId: _targetId.toString(),
            message: message,
            urgency: _urgency,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Broadcast sent successfully'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send alert: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(coordinatorTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast Alert'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// INFO BANNER
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.campaign, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Broadcast alerts are delivered in real-time to volunteers and operational teams.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// TARGET SECTION
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      color: Colors.black.withValues(alpha: 0.04),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// SCOPE
                    Text(
                      'Broadcast Scope',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      initialValue: _scope,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'TASK', child: Text('Task')),
                        DropdownMenuItem(value: 'CAMPAIGN', child: Text('Campaign')),
                        DropdownMenuItem(value: 'NGO', child: Text('NGO')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _scope = v;
                            _targetId = null;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    /// TARGET
                    Text(
                      'Target ${_scope[0] + _scope.substring(1).toLowerCase()}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                    ),

                    const SizedBox(height: 10),

                    tasksAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: LinearProgressIndicator(),
                      ),
                      error: (_, __) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Failed to load targets',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      data: (tasks) => DropdownButtonFormField<int>(
                        initialValue: _targetId,
                        hint: const Text('Select target'),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                        ),
                        items: tasks.map((t) {
                          return DropdownMenuItem<int>(
                            value: t.id,
                            child: SizedBox(
                              width: 220,
                              child: Text(
                                '${t.title} (#${t.id})',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() => _targetId = v);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// MESSAGE SECTION
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      color: Colors.black.withValues(alpha: 0.04),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// URGENCY
                    Text(
                      'Urgency Level',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: ['LOW', 'MEDIUM', 'HIGH'].map((level) {
                        final selected = _urgency == level;

                        return ChoiceChip(
                          label: Text(
                            level,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: selected,
                          selectedColor: level == 'HIGH'
                              ? Colors.red
                              : level == 'MEDIUM'
                                  ? Colors.orange
                                  : Colors.green,
                          backgroundColor: Colors.grey.shade200,
                          side: BorderSide(
                            color: selected
                                ? Colors.transparent
                                : Colors.grey.shade400,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (_) {
                            setState(() => _urgency = level);
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    /// MESSAGE
                    Text(
                      'Alert Message',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: _messageController,
                      minLines: 4,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Enter operational alert message...',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'This message will be delivered immediately.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// SEND BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _sending ? null : _sendBroadcast,
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _sending ? 'Sending Alert...' : 'Dispatch Alert',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
