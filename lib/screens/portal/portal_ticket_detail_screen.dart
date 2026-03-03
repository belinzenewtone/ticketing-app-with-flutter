import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tickets_provider.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/priority_chip.dart';
import '../../widgets/comment_bubble.dart';

class PortalTicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const PortalTicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<PortalTicketDetailScreen> createState() =>
      _PortalTicketDetailScreenState();
}

class _PortalTicketDetailScreenState
    extends ConsumerState<PortalTicketDetailScreen> {
  final _commentCtrl = TextEditingController();
  bool _postingComment = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    setState(() => _postingComment = true);
    try {
      await TicketService.addComment(
          widget.ticketId, _commentCtrl.text.trim(), false);
      _commentCtrl.clear();
      ref.invalidate(commentsProvider(widget.ticketId));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _postingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUserId =
        authState is AuthAuthenticated ? authState.user.id : '';

    final ticketAsync = ref.watch(ticketDetailProvider(widget.ticketId));
    final commentsAsync = ref.watch(commentsProvider(widget.ticketId));

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Ticket Details'),
      ),
      body: ticketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (ticket) => Column(
          children: [
            // Header
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
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(ticket.description,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF475569))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                          'Submitted ${DateFormat('MMM d, yyyy').format(ticket.createdAt.toLocal())}',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B))),
                      if (ticket.assigneeName != null) ...[
                        const SizedBox(width: 16),
                        const Icon(Icons.support_agent,
                            size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(ticket.assigneeName!,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Comments header
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Row(
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 6),
                  Text('Conversation',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B))),
                ],
              ),
            ),
            const Divider(height: 1),
            // Comments
            Expanded(
              child: commentsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (comments) => comments.isEmpty
                    ? const Center(
                        child: Text('No messages yet',
                            style:
                                TextStyle(color: Color(0xFF94A3B8))))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: comments.length,
                        itemBuilder: (ctx, i) => CommentBubble(
                          comment: comments[i],
                          isOwn: comments[i].authorId == currentUserId,
                        ),
                      ),
              ),
            ),
            // Input
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Reply to IT team...',
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
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send,
                            color: Color(0xFF059669)),
                    onPressed: _postingComment ? null : _postComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
