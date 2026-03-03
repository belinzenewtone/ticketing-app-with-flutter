import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/ticket.dart';
import 'status_chip.dart';
import 'priority_chip.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const TicketCard({super.key, required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.subject,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusChip(status: ticket.status, small: true),
                ],
              ),
              const SizedBox(height: 6),
              // Category + description
              Text(
                _formatCategory(ticket.category),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ticket.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              // Footer row
              Row(
                children: [
                  PriorityChip(priority: ticket.priority, small: true),
                  const Spacer(),
                  if (ticket.assigneeName != null) ...[
                    const Icon(Icons.person_outline,
                        size: 13, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 3),
                    Text(
                      ticket.assigneeName!,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Icon(Icons.access_time,
                      size: 13, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 3),
                  Text(
                    timeago.format(ticket.createdAt),
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
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
