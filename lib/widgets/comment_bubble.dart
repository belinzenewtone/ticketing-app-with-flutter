import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
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
    return Padding(
      padding: EdgeInsets.only(
        left: isOwn ? 48 : 0,
        right: isOwn ? 0 : 48,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment:
            isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isOwn) ...[
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF059669),
                  child: Text(
                    comment.authorName.isNotEmpty
                        ? comment.authorName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                comment.authorName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              if (comment.isInternal) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Internal',
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFFD97706),
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              const SizedBox(width: 6),
              Text(
                timeago.format(comment.createdAt),
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isOwn
                  ? const Color(0xFF059669)
                  : Colors.white,
              border: isOwn
                  ? null
                  : Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: isOwn
                    ? const Radius.circular(12)
                    : const Radius.circular(2),
                bottomRight: isOwn
                    ? const Radius.circular(2)
                    : const Radius.circular(12),
              ),
            ),
            child: Text(
              comment.content,
              style: TextStyle(
                fontSize: 14,
                color: isOwn ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
