import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../core/app_theme.dart';
import '../models/comment.dart';

class CommentBubble extends StatelessWidget {
  final Comment comment;
  final bool isOwn;

  const CommentBubble({
    super.key,
    required this.comment,
    required this.isOwn,
  });

  @override
  Widget build(BuildContext context) {
    final initial = comment.authorName.isNotEmpty
        ? comment.authorName[0].toUpperCase()
        : '?';

    return Padding(
      padding: EdgeInsets.only(
        left: isOwn ? 56 : 16,
        right: isOwn ? 16 : 56,
        bottom: 14,
      ),
      child: Column(
        crossAxisAlignment:
            isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Meta row
          Row(
            mainAxisAlignment:
                isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isOwn) ...[
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    gradient: AppColors.brandGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
              ],
              Text(
                isOwn ? 'You' : comment.authorName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              if (comment.isInternal) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warningSurface,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                        color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'Internal',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
              const SizedBox(width: 6),
              Text(
                timeago.format(comment.createdAt),
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Bubble
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              gradient: isOwn ? AppColors.brandGradient : null,
              color: isOwn ? null : Colors.white,
              border:
                  isOwn ? null : Border.all(color: AppColors.border),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isOwn
                    ? const Radius.circular(16)
                    : const Radius.circular(3),
                bottomRight: isOwn
                    ? const Radius.circular(3)
                    : const Radius.circular(16),
              ),
              boxShadow: isOwn
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : AppShadows.card,
            ),
            child: Text(
              comment.content,
              style: TextStyle(
                fontSize: 14,
                color: isOwn ? Colors.white : AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
