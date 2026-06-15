import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/features/auth/presentation/auth_provider.dart';
import 'package:reliefnet_app/providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int taskId;
  final String? taskTitle;
  final int? inkindRequestId;

  const ChatScreen({
    super.key,
    required this.taskId,
    this.taskTitle,
    this.inkindRequestId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  ChatRoom? _room;
  bool _initializingRoom = true;
  String? _chatError;
  bool _showScrollFab = false;

  @override
  void initState() {
    super.initState();
    _ensureRoom();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final atBottom = !_scrollController.hasClients ||
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 150;
    if (atBottom != !_showScrollFab) {
      setState(() => _showScrollFab = !atBottom);
    }
  }

  Future<void> _ensureRoom() async {
    final repo = ref.read(chatRepoProvider);
    if (widget.inkindRequestId != null) {
      try {
        final room = await repo.ensureInKindRoom(widget.inkindRequestId!);
        if (mounted) setState(() { _room = room; _initializingRoom = false; });
      } catch (e) {
        if (mounted) setState(() { _chatError = e.toString(); _initializingRoom = false; });
      }
      return;
    }
    if (widget.taskId == 0) {
      if (mounted) setState(() { _chatError = 'Invalid task'; _initializingRoom = false; });
      return;
    }
    try {
      final room = await repo.ensureRoom(widget.taskId);
      if (mounted) setState(() { _room = room; _initializingRoom = false; });
    } catch (e) {
      if (mounted) setState(() { _chatError = e.toString(); _initializingRoom = false; });
    }
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (animate) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty || _room == null) return;
    HapticFeedback.lightImpact();
    ref.read(chatProvider(_room!.id).notifier).sendMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  void _notifyTyping(String value) {
    if (_room == null) return;
    ref.read(chatProvider(_room!.id).notifier).notifyTyping(value.isNotEmpty);
  }

  void _showParticipants() {
    if (_room == null) return;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Participants',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              if (_room!.creatorName != null)
                _ParticipantTile(
                  name: _room!.creatorName!,
                  role: 'Beneficiary',
                  icon: Icons.person_outline,
                  color: AppTheme.accentColor,
                ),
              if (_room!.claimerName != null)
                _ParticipantTile(
                  name: _room!.claimerName!,
                  role: 'Volunteer',
                  icon: Icons.volunteer_activism_outlined,
                  color: AppTheme.primaryColor,
                ),
              if (_room!.coordinatorName != null)
                _ParticipantTile(
                  name: _room!.coordinatorName!,
                  role: 'Coordinator',
                  icon: Icons.admin_panel_settings_outlined,
                  color: AppTheme.statusInProgress,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    return switch (status.toUpperCase()) {
      'IN_PROGRESS' => 'In Progress',
      'COORDINATOR_VERIFIED' => 'Verified',
      _ => status
          .split('_')
          .map((w) =>
              w.isEmpty ? '' : w[0] + w.substring(1).toLowerCase())
          .join(' '),
    };
  }

  Color _statusColor(String status) {
    return switch (status.toUpperCase()) {
      'OPEN' => AppTheme.statusPending,
      'CLAIMED' || 'IN_PROGRESS' || 'ASSIGNED' => AppTheme.statusActive,
      'SUBMITTED' => AppTheme.infoColor,
      'COORDINATOR_VERIFIED' || 'PAID' => AppTheme.successColor,
      _ => AppTheme.statusNeutral,
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(authProvider).user?.id ?? -1;
    final title = widget.taskTitle ?? _room?.taskTitle ?? 'Chat';

    if (_initializingRoom) {
      return Scaffold(
        appBar: AppBar(title: Text(title, style: const TextStyle(fontSize: 15))),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connecting to chat...',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    if (_room == null) {
      return Scaffold(
        appBar: AppBar(title: Text(title, style: const TextStyle(fontSize: 15))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline,
                      size: 40, color: AppTheme.errorColor),
                ),
                const SizedBox(height: 20),
                const Text('Could not open chat',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Text(
                  _chatError ?? 'An unexpected error occurred.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _initializingRoom = true;
                      _chatError = null;
                    });
                    _ensureRoom();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final chatState = ref.watch(chatProvider(_room!.id));

    ref.listen<ChatState>(chatProvider(_room!.id), (prev, next) {
      if (next.messages.length != (prev?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    final statusLabel = _statusLabel(_room!.taskStatus);
    final statusColor = _statusColor(_room!.taskStatus);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: GestureDetector(
          onTap: _showParticipants,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _room!.taskTitle.isNotEmpty
                        ? _room!.taskTitle[0].toUpperCase()
                        : 'C',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _room!.taskTitle,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: chatState.isConnected
                                ? const Color(0xFF4ADE80)
                                : Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          chatState.isConnected ? statusLabel : 'Connecting...',
                          style: TextStyle(
                              fontSize: 11,
                              color: chatState.isConnected
                                  ? Colors.white70
                                  : Colors.orange.shade200),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white70),
            onPressed: _showParticipants,
            tooltip: 'Participants',
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline banner
          if (!chatState.isConnected)
            Material(
              color: Colors.orange.shade50,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off, size: 14, color: Colors.deepOrange),
                    SizedBox(width: 8),
                    Text(
                      'Reconnecting…  Messages may be delayed.',
                      style:
                          TextStyle(fontSize: 12, color: Colors.deepOrange),
                    ),
                  ],
                ),
              ),
            ),

          // Messages
          Expanded(
            child: Stack(
              children: [
                chatState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : chatState.messages.isEmpty
                        ? _EmptyChat(
                            claimerName: _room!.claimerName,
                            creatorName: _room!.creatorName,
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(
                                12, 12, 12, 8),
                            itemCount: chatState.messages.length,
                            itemBuilder: (context, index) {
                              final msg = chatState.messages[index];
                              final isMe = msg.senderId == currentUserId;
                              final showDateSep = index == 0 ||
                                  !_isSameDay(
                                    chatState.messages[index - 1]
                                        .createdAt,
                                    msg.createdAt,
                                  );
                              final showAvatar = !isMe &&
                                  (index == chatState.messages.length - 1 ||
                                      chatState.messages[index + 1]
                                              .senderId !=
                                          msg.senderId);
                              final showSenderName = !isMe &&
                                  (index == 0 ||
                                      chatState.messages[index - 1]
                                              .senderId !=
                                          msg.senderId);

                              return Column(
                                children: [
                                  if (showDateSep)
                                    _DateSeparator(date: msg.createdAt),
                                  _MessageBubble(
                                    message: msg,
                                    isMe: isMe,
                                    showAvatar: showAvatar,
                                    showSenderName: showSenderName,
                                  ),
                                ],
                              );
                            },
                          ),

                // Scroll-to-bottom FAB
                if (_showScrollFab)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: FloatingActionButton.small(
                      heroTag: 'scroll_bottom_fab',
                      onPressed: _scrollToBottom,
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
              ],
            ),
          ),

          // Typing indicator
          if (chatState.isTyping && chatState.typingUserName != null)
            Container(
              color: const Color(0xFFF5F5F5),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  _TypingIndicator(),
                  const SizedBox(width: 8),
                  Text(
                    '${chatState.typingUserName} is typing…',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

          // Input bar
          _InputBar(
            controller: _textController,
            onSend: _sendMessage,
            onTyping: _notifyTyping,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Subwidgets ──────────────────────────────────────────────────────────────

class _ParticipantTile extends StatelessWidget {
  final String name;
  final String role;
  final IconData icon;
  final Color color;

  const _ParticipantTile({
    required this.name,
    required this.role,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(name,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppTheme.textPrimary)),
      subtitle: Text(role,
          style: const TextStyle(
              fontSize: 12, color: AppTheme.textSecondary)),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  final String? claimerName;
  final String? creatorName;

  const _EmptyChat({this.claimerName, this.creatorName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline,
                  size: 36, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 16),
            const Text(
              'No messages yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              claimerName != null && creatorName != null
                  ? 'Say hello to $creatorName!'
                  : 'Be the first to send a message.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;

  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    final isYesterday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1;

    final label = isToday
        ? 'Today'
        : isYesterday
            ? 'Yesterday'
            : DateFormat('d MMM yyyy').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
              child: Divider(color: Colors.grey.shade300, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
              child: Divider(color: Colors.grey.shade300, height: 1)),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showAvatar;
  final bool showSenderName;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.showSenderName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: showSenderName ? 8 : 2,
        bottom: 2,
        left: isMe ? 48 : 0,
        right: isMe ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            SizedBox(
              width: 32,
              child: showAvatar
                  ? CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          AppTheme.primaryColor.withValues(alpha: 0.15),
                      child: Text(
                        message.senderName.isNotEmpty
                            ? message.senderName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (showSenderName && !isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      message.senderName,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth:
                        MediaQuery.of(context).size.width * 0.70,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppTheme.primaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isMe ? Colors.white : AppTheme.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('HH:mm').format(message.createdAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: isMe
                                  ? Colors.white.withValues(alpha: 0.65)
                                  : AppTheme.textDisabled,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.done_all,
                              size: 12,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (i) => Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor
                  .withValues(alpha: i == 1 ? _anim.value : 0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final void Function(String) onTyping;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.onTyping,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, 8 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                onChanged: onTyping,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: TextStyle(
                      color: AppTheme.textDisabled, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: child,
              ),
              child: value.text.trim().isNotEmpty
                  ? GestureDetector(
                      key: const ValueKey('send'),
                      onTap: onSend,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                      ),
                    )
                  : const SizedBox(
                      key: ValueKey('empty'), width: 44, height: 44),
            ),
          ),
        ],
      ),
    );
  }
}
