import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tickets_provider.dart';
import '../../providers/staff_provider.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/priority_chip.dart';
import '../../widgets/comment_bubble.dart';
import 'package:intl/intl.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailScreen> createState() =>
      _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _commentCtrl = TextEditingController();
  bool _isInternal = false;
  bool _postingComment = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    setState(() => _postingComment = true);
    try {
      await TicketService.addComment(
          widget.ticketId, _commentCtrl.text.trim(), _isInternal);
      _commentCtrl.clear();
      ref.invalidate(commentsProvider(widget.ticketId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _postingComment = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await TicketService.updateTicket(widget.ticketId, {'status': newStatus});
      ref.invalidate(ticketDetailProvider(widget.ticketId));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _updateAssignee(String assigneeId) async {
    try {
      await TicketService.updateTicket(
          widget.ticketId, {'assigneeId': assigneeId});
      ref.invalidate(ticketDetailProvider(widget.ticketId));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isStaff = authState is AuthAuthenticated && authState.user.isStaff;
    final isAdmin = authState is AuthAuthenticated && authState.user.isAdmin;
    final currentUserId =
        authState is AuthAuthenticated ? authState.user.id : '';

    final ticketAsync = ref.watch(ticketDetailProvider(widget.ticketId));
    final commentsAsync = ref.watch(commentsProvider(widget.ticketId));
    final activityAsync = ref.watch(activityProvider(widget.ticketId));
    final staffAsync = ref.watch(staffProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: ticketAsync.when(
          loading: () => const Text('Ticket'),
          error: (_, __) => const Text('Ticket'),
          data: (t) => Text('#${t.id.substring(0, 6).toUpperCase()}',
              style: const TextStyle(fontSize: 16)),
        ),
        actions: [
          if (isAdmin)
            ticketAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (t) => PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'delete') {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete Ticket'),
                        content: const Text(
                            'Are you sure you want to delete this ticket?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete',
                                  style:
                                      TextStyle(color: Color(0xFFDC2626)))),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await TicketService.deleteTicket(widget.ticketId);
                      if (mounted) context.pop();
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'delete', child: Text('Delete Ticket')),
                ],
              ),
            ),
        ],
      ),
      body: ticketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (ticket) => Column(
          children: [
            // Header info
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticket.subject,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      StatusChip(status: ticket.status),
                      PriorityChip(priority: ticket.priority),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          ticket.category
                              .replaceAll('-', ' ')
                              .split(' ')
                              .map((w) => w.isEmpty
                                  ? w
                                  : w[0].toUpperCase() + w.substring(1))
                              .join(' '),
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF475569)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(ticket.description,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF475569))),
                  const SizedBox(height: 12),
                  // Meta row
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text('By ${ticket.submittedByName}',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                          DateFormat('MMM d, yyyy')
                              .format(ticket.createdAt.toLocal()),
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                  if (isStaff) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Status picker
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Status',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B))),
                              const SizedBox(height: 4),
                              DropdownButton<String>(
                                value: ticket.status,
                                isDense: true,
                                underline: const SizedBox(),
                                items: kTicketStatuses
                                    .map((s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(_cap(s),
                                            style: const TextStyle(
                                                fontSize: 13))))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null && v != ticket.status) {
                                    _updateStatus(v);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        // Assignee picker
                        Expanded(
                          child: staffAsync.when(
                            loading: () => const SizedBox(),
                            error: (_, __) => const SizedBox(),
                            data: (staff) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Assignee',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B))),
                                const SizedBox(height: 4),
                                DropdownButton<String>(
                                  value: ticket.assigneeId,
                                  isDense: true,
                                  underline: const SizedBox(),
                                  hint: const Text('Unassigned',
                                      style: TextStyle(fontSize: 13)),
                                  items: staff
                                      .map((s) => DropdownMenuItem(
                                          value: s.id,
                                          child: Text(s.name,
                                              style: const TextStyle(
                                                  fontSize: 13))))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null &&
                                        v != ticket.assigneeId) {
                                      _updateAssignee(v);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabCtrl,
              indicatorColor: const Color(0xFF059669),
              labelColor: const Color(0xFF059669),
              unselectedLabelColor: const Color(0xFF94A3B8),
              tabs: const [
                Tab(text: 'Comments'),
                Tab(text: 'Activity'),
              ],
            ),

            // Tab body
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  // Comments
                  Column(
                    children: [
                      Expanded(
                        child: commentsAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('$e')),
                          data: (comments) => comments.isEmpty
                              ? const Center(
                                  child: Text('No comments yet',
                                      style: TextStyle(
                                          color: Color(0xFF94A3B8))))
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: comments.length,
                                  itemBuilder: (ctx, i) => CommentBubble(
                                    comment: comments[i],
                                    isOwn:
                                        comments[i].authorId == currentUserId,
                                  ),
                                ),
                        ),
                      ),
                      // Comment input
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            if (isStaff)
                              Row(
                                children: [
                                  Switch(
                                    value: _isInternal,
                                    onChanged: (v) =>
                                        setState(() => _isInternal = v),
                                    activeColor: const Color(0xFF059669),
                                  ),
                                  const Text('Internal note',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF64748B))),
                                ],
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _commentCtrl,
                                    decoration: const InputDecoration(
                                      hintText: 'Write a comment...',
                                      isDense: true,
                                    ),
                                    maxLines: null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: _postingComment
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : const Icon(Icons.send,
                                          color: Color(0xFF059669)),
                                  onPressed:
                                      _postingComment ? null : _postComment,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Activity log
                  activityAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('$e')),
                    data: (activities) => activities.isEmpty
                        ? const Center(
                            child: Text('No activity yet',
                                style:
                                    TextStyle(color: Color(0xFF94A3B8))))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: activities.length,
                            itemBuilder: (ctx, i) {
                              final a = activities[i];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFECFDF5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                          Icons.history,
                                          size: 14,
                                          color: Color(0xFF059669)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF1E293B)),
                                              children: [
                                                TextSpan(
                                                    text: a.userName,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                TextSpan(
                                                    text: ' ${a.action}'),
                                              ],
                                            ),
                                          ),
                                          if (a.oldValue != null &&
                                              a.newValue != null)
                                            Text(
                                              '${a.oldValue} → ${a.newValue}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B)),
                                            ),
                                          Text(
                                            DateFormat('MMM d, h:mm a').format(
                                                a.createdAt.toLocal()),
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF94A3B8)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).replaceAll('-', ' ');
}
