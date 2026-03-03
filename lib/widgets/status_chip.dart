import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final bool small;

  const StatusChip({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _resolve(status);
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: small ? 11 : 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static (Color, Color, String) _resolve(String status) => switch (status) {
        'open' => (
            const Color(0xFFFEF2F2),
            const Color(0xFFDC2626),
            'Open'
          ),
        'in-progress' || 'in_progress' => (
            const Color(0xFFFFFBEB),
            const Color(0xFFD97706),
            'In Progress'
          ),
        'resolved' => (
            const Color(0xFFECFDF5),
            const Color(0xFF059669),
            'Resolved'
          ),
        'closed' => (
            const Color(0xFFF1F5F9),
            const Color(0xFF64748B),
            'Closed'
          ),
        'pending' => (
            const Color(0xFFFFFBEB),
            const Color(0xFFD97706),
            'Pending'
          ),
        'approved' => (
            const Color(0xFFECFDF5),
            const Color(0xFF059669),
            'Approved'
          ),
        'rejected' => (
            const Color(0xFFFEF2F2),
            const Color(0xFFDC2626),
            'Rejected'
          ),
        _ => (
            const Color(0xFFF1F5F9),
            const Color(0xFF64748B),
            _capitalize(status)
          ),
      };

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
