import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';
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
  final _scrollCtrl = ScrollController();
  bool _postingComment = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    _scrollCtrl.dispose();
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
      // Scroll to bottom after posting
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text('Ticket Details'),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ticketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (ticket) {
          return commentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (comments) {
              // Check if IT has responded (any comment not from current user)
              final itResponded = comments
                  .any((c) => c.authorId != currentUserId && !c.isInternal);

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      controller: _scrollCtrl,
                      children: [
                        // ── IT Response Banner ──
                        if (itResponded)
                          Container(
                            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.08),
                                  AppColors.primaryLight.withOpacity(0.08),
                                ],
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                  color:
                                      AppColors.primary.withOpacity(0.25)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                      Icons.support_agent_rounded,
                                      size: 18,
                                      color: AppColors.primary),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'IT has responded to your ticket',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Scroll down to read the reply',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // ── Ticket info card ──
                        Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
                            boxShadow: AppShadows.card,
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ticket.subject, style: AppText.h2),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  StatusChip(status: ticket.status),
                                  PriorityChip(priority: ticket.priority),
                                ],
                              ),
                              if (ticket.description.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 10),
                                Text(ticket.description,
                                    style: AppText.body),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 14,
                                      color: AppColors.textMuted),
                                  const SizedBox(width: 5),
                                  Text(
                                    DateFormat('MMM d, yyyy').format(
                                        ticket.createdAt.toLocal()),
                                    style: AppText.caption,
                                  ),
                                  if (ticket.assigneeName != null) ...[
                                    const SizedBox(width: 16),
                                    const Icon(
                                        Icons.support_agent_rounded,
                                        size: 14,
                                        color: AppColors.textMuted),
                                    const SizedBox(width: 5),
                                    Text(
                                      ticket.assigneeName!,
                                      style: AppText.caption,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ── Conversation header ──
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 14,
                                    color: AppColors.primary),
                              ),
                              const SizedBox(width: 8),
                              const Text('Conversation',
                                  style: AppText.bodyStrong),
                              const Spacer(),
                              Text(
                                '${comments.length} message${comments.length == 1 ? '' : 's'}',
                                style: AppText.caption,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ── Messages ──
                        if (comments.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 24, horizontal: 32),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded,
                                      size: 36,
                                      color: AppColors.textMuted
                                          .withOpacity(0.5)),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'No messages yet',
                                    style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...comments.map((c) => CommentBubble(
                                comment: c,
                                isOwn: c.authorId == currentUserId,
                              )),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  // ── Input bar ──
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x10000000),
                          blurRadius: 12,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 8,
                      top: 10,
                      bottom:
                          MediaQuery.of(context).padding.bottom + 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            constraints:
                                const BoxConstraints(maxHeight: 120),
                            decoration: BoxDecoration(
                              color: AppColors.borderLight,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xl),
                            ),
                            child: TextField(
                              controller: _commentCtrl,
                              maxLines: null,
                              style: AppText.body
                                  .copyWith(color: AppColors.textPrimary),
                              decoration: const InputDecoration(
                                hintText: 'Reply to IT team...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: _postingComment
                                ? null
                                : AppColors.brandGradient,
                            color: _postingComment
                                ? AppColors.border
                                : null,
                            shape: BoxShape.circle,
                            boxShadow: _postingComment
                                ? null
                                : [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withOpacity(0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                          ),
                          child: IconButton(
                            icon: _postingComment
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Icon(Icons.send_rounded,
                                    color: Colors.white, size: 18),
                            onPressed:
                                _postingComment ? null : _postComment,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
