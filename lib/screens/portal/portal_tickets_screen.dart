import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/portal_provider.dart';
import '../../widgets/ticket_card.dart';

class PortalTicketsScreen extends ConsumerWidget {
  const PortalTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(portalTicketsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => ref.invalidate(portalTicketsProvider),
          ),
        ],
      ),
      body: ticketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tickets) => tickets.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inbox_outlined,
                        size: 64, color: Color(0xFFCBD5E1)),
                    const SizedBox(height: 16),
                    const Text('No tickets yet',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B))),
                    const SizedBox(height: 8),
                    const Text('Submit a ticket to get help from IT',
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('New Ticket'),
                      onPressed: () => context.go('/portal/new'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(portalTicketsProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: tickets.length,
                  itemBuilder: (ctx, i) => TicketCard(
                    ticket: tickets[i],
                    onTap: () =>
                        context.go('/portal/tickets/${tickets[i].id}'),
                  ),
                ),
              ),
      ),
    );
  }
}
