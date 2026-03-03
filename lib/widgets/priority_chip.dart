import 'package:flutter/material.dart';

class PriorityChip extends StatelessWidget {
  final String priority;
  final bool small;

  const PriorityChip({super.key, required this.priority, this.small = false});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label, icon) = _resolve(priority);
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: small ? 10 : 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: small ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static (Color, Color, String, IconData) _resolve(String priority) =>
      switch (priority) {
        'urgent' => (
            const Color(0xFFFEF2F2),
            const Color(0xFFDC2626),
            'Urgent',
            Icons.keyboard_double_arrow_up
          ),
        'high' => (
            const Color(0xFFFFF7ED),
            const Color(0xFFEA580C),
            'High',
            Icons.keyboard_arrow_up
          ),
        'medium' => (
            const Color(0xFFFFFBEB),
            const Color(0xFFD97706),
            'Medium',
            Icons.remove
          ),
        'low' => (
            const Color(0xFFF0FDF4),
            const Color(0xFF16A34A),
            'Low',
            Icons.keyboard_arrow_down
          ),
        _ => (
            const Color(0xFFF1F5F9),
            const Color(0xFF64748B),
            priority,
            Icons.remove
          ),
      };
}
