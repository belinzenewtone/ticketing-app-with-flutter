import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../core/app_theme.dart';
import '../models/ticket.dart';
import 'status_chip.dart';
import 'priority_chip.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;
  final bool showUnreadBadge;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
    this.showUnreadBadge = false,
  });

  Color get _priorityAccent => switch (ticket.priority) {
        'critical' || 'urgent' => AppColors.danger,
        'high' => const Color(0xFFEA580C),
        'medium' => AppColors.warning,
        'low' => AppColors.primaryLight,
        _ => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Priority accent bar ──
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _priorityAccent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.lg),
                    bottomLeft: Radius.circular(AppRadius.lg),
                  ),
                ),
              ),
              // ── Content ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject + status + unread badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              ticket.subject,
                              style: AppText.bodyStrong,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (showUnreadBadge && ticket.publicCommentCount > 0)
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.info,
                                    borderRadius: BorderRadius.circular(AppRadius.full),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                          Icons.mark_unread_chat_alt_rounded,
                                          size: 10,
                                          color: Colors.white),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${ticket.publicCommentCount}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              StatusChip(status: ticket.status, small: true),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatCategory(ticket.category),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        ticket.description,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          PriorityChip(priority: ticket.priority, small: true),
                          const Spacer(),
                          if (ticket.assigneeName != null) ...[
                            const Icon(Icons.person_outline_rounded,
                                size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 3),
                            Text(
                              ticket.assigneeName!.split(' ').first,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(width: 8),
                          ],
                          const Icon(Icons.schedule_rounded,
                              size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 3),
                          Text(
                            timeago.format(ticket.createdAt),
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatCategory(String cat) =>
      cat.replaceAll('-', ' ').replaceAll('_', ' ').split(' ').map((w) {
        if (w.isEmpty) return w;
        return w[0].toUpperCase() + w.substring(1);
      }).join(' ');
}
