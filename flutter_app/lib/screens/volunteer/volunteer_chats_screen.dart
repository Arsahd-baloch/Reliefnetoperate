import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/providers/chat_provider.dart';
import 'package:reliefnet_app/widgets/empty_state.dart';
import 'package:reliefnet_app/widgets/shimmer_card.dart';

class VolunteerChatsScreen extends ConsumerWidget {
  const VolunteerChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(myRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.invalidate(myRoomsProvider);
            },
          ),
        ],
      ),
      body: roomsAsync.when(
        loading: () => const ShimmerList(count: 5, itemHeight: 76),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_outlined,
                  size: 48, color: AppTheme.textDisabled),
              const SizedBox(height: 12),
              const Text('Could not load messages',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text(err.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(myRoomsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (rooms) {
          if (rooms.isEmpty) {
            return const EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No conversations yet',
              subtitle:
                  'Claim a task to start a conversation with the beneficiary and coordinator.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myRoomsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: rooms.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                indent: 72,
                endIndent: 16,
              ),
              itemBuilder: (context, index) =>
                  _ChatRoomTile(room: rooms[index]),
            ),
          );
        },
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoom room;

  const _ChatRoomTile({required this.room});

  Color _statusColor() {
    return switch (room.taskStatus.toUpperCase()) {
      'OPEN' => AppTheme.statusPending,
      'CLAIMED' || 'IN_PROGRESS' || 'ASSIGNED' => AppTheme.statusActive,
      'SUBMITTED' => AppTheme.infoColor,
      'COORDINATOR_VERIFIED' || 'PAID' => AppTheme.successColor,
      'CANCELLED' => AppTheme.statusFailed,
      _ => AppTheme.statusNeutral,
    };
  }

  String _statusLabel() {
    return switch (room.taskStatus.toUpperCase()) {
      'IN_PROGRESS' => 'In Progress',
      'COORDINATOR_VERIFIED' => 'Verified',
      _ => room.taskStatus
              .split('_')
              .map((w) =>
                  w.isEmpty ? '' : w[0] + w.substring(1).toLowerCase())
              .join(' '),
    };
  }

  String _timeLabel() {
    final dt = room.lastMessageAt ??
        (room.createdAt != null ? DateTime.tryParse(room.createdAt!) : null);
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return DateFormat('HH:mm').format(dt);
    if (diff.inDays < 7) return DateFormat('EEE').format(dt);
    return DateFormat('d MMM').format(dt);
  }

  String _avatarInitial() {
    if (room.isInKindRoom) return '📦';
    return room.taskTitle.isNotEmpty ? room.taskTitle[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final hasUnread = room.messageCount > 0;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        if (room.taskId != null) {
          context.push(
            '/chat/${room.taskId}',
            extra: {'roomId': room.id, 'title': room.taskTitle},
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color:
                            AppTheme.primaryColor.withValues(alpha: 0.15)),
                  ),
                  child: Center(
                    child: room.isInKindRoom
                        ? const Text('📦',
                            style: TextStyle(fontSize: 22))
                        : Text(
                            _avatarInitial(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                  ),
                ),
                // Status dot
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.taskTitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _timeLabel(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textDisabled,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.lastMessage ?? 'Tap to view conversation',
                          style: TextStyle(
                            fontSize: 12,
                            color: room.lastMessage != null
                                ? AppTheme.textSecondary
                                : AppTheme.textDisabled,
                            fontStyle: room.lastMessage == null
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _statusLabel(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                      if (room.claimerName != null) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.person_outline,
                            size: 11, color: AppTheme.textDisabled),
                        const SizedBox(width: 2),
                        Text(
                          room.claimerName!,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textDisabled),
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
