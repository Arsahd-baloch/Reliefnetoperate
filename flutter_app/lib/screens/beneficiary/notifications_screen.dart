import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reliefnet_app/providers/notification_provider.dart';
import 'package:reliefnet_app/widgets/empty_state.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(notificationProvider.notifier).clear(),
              child: const Text('Clear All'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_outlined,
              title: 'No notifications',
              subtitle: 'We\'ll notify you when your requests are updated.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: _getColor(item.type, context),
                      child: Icon(_getIcon(item.type), color: Colors.white, size: 20),
                    ),
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(item.message),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('MMM d, HH:mm').format(item.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (item.type.startsWith('INKIND_')) {
                        context.push('/beneficiary/inkind/${item.taskId}');
                      } else {
                        context.push('/beneficiary/task/${item.taskId}');
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'TASK_CLAIMED':
        return Icons.volunteer_activism;
      case 'DELIVERY_SUBMITTED':
        return Icons.local_shipping;
      case 'TASK_STATUS_UPDATE':
        return Icons.update;
      case 'INKIND_REQUESTED':
        return Icons.favorite_border;
      case 'INKIND_ACCEPTED':
        return Icons.check_circle_outline;
      case 'INKIND_REJECTED':
        return Icons.highlight_off;
      case 'INKIND_COMPLETED':
        return Icons.done_all;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor(String type, BuildContext context) {
    switch (type) {
      case 'TASK_CLAIMED':
        return Colors.blue;
      case 'DELIVERY_SUBMITTED':
        return Colors.green;
      case 'TASK_STATUS_UPDATE':
        return Colors.orange;
      case 'INKIND_REQUESTED':
        return Colors.purple;
      case 'INKIND_ACCEPTED':
        return Colors.green;
      case 'INKIND_REJECTED':
        return Colors.red;
      case 'INKIND_COMPLETED':
        return Colors.teal;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
