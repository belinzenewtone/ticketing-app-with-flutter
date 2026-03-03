import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/portal_provider.dart';
import '../../widgets/ticket_card.dart';

class PortalTicketsScreen extends ConsumerWidget {
  const PortalTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userName = authState is AuthAuthenticated
        ? authState.user.name.split(' ').first
        : '';
    final userInitial = authState is AuthAuthenticated &&
            authState.user.name.isNotEmpty
        ? authState.user.name[0].toUpperCase()
        : 'U';

    final ticketsAsync = ref.watch(portalTicketsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ticketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tickets) {
          // Count tickets with IT responses
          final withResponses =
              tickets.where((t) => t.publicCommentCount > 0).length;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(portalTicketsProvider),
            child: CustomScrollView(
              slivers: [
                // ── Gradient header ──
                SliverToBoxAdapter(
                  child: Container(
                    decoration:
                        const BoxDecoration(gradient: AppColors.heroBg),
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 20,
                      right: 20,
                      bottom: 24,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName.isNotEmpty
                                    ? 'Hello, $userName'
                                    : 'My Tickets',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${tickets.length} ticket${tickets.length == 1 ? '' : 's'} submitted',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh_rounded,
                              color: Colors.white.withOpacity(0.8), size: 22),
                          onPressed: () =>
                              ref.invalidate(portalTicketsProvider),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/portal/profile'),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.15),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                userInitial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── IT Responses banner ──
                if (withResponses > 0)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.infoSurface,
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                            color: AppColors.info.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                                Icons.mark_unread_chat_alt_rounded,
                                size: 16,
                                color: AppColors.info),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$withResponses ticket${withResponses == 1 ? ' has' : 's have'} responses from IT — tap to read',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.info,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Ticket list or empty state ──
                if (tickets.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.borderLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.inbox_outlined,
                                  size: 48, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No tickets yet',
                              style: AppText.h3,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Submit a support ticket and the IT\nteam will help you shortly.',
                              textAlign: TextAlign.center,
                              style: AppText.body,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('New Ticket'),
                              onPressed: () => context.go('/portal/new'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 12, bottom: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => TicketCard(
                          ticket: tickets[i],
                          onTap: () => context
                              .go('/portal/tickets/${tickets[i].id}'),
                          showUnreadBadge: true,
                        ),
                        childCount: tickets.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
