import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    final userName = user?.name.split(' ').first ?? 'there';
    final userInitial = user?.name.isNotEmpty == true
        ? user!.name[0].toUpperCase()
        : 'U';

    final statsAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardProvider),
          child: CustomScrollView(
            slivers: [
              // ── Gradient header ──
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(gradient: AppColors.heroBg),
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
                              'Good day, $userName',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'IT Operations Dashboard',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.65),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Refresh + Avatar
                      IconButton(
                        icon: Icon(Icons.refresh_rounded,
                            color: Colors.white.withOpacity(0.8), size: 22),
                        onPressed: () => ref.invalidate(dashboardProvider),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/admin/profile'),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3), width: 1.5),
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

              // ── Body content ──
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _SectionHeader(label: 'Tickets', icon: Icons.inbox_rounded),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.65,
                      children: [
                        StatCard(
                            label: 'TOTAL',
                            value: stats.tickets.total,
                            color: AppColors.primary,
                            icon: Icons.confirmation_number_rounded,
                            subtitle: 'all tickets'),
                        StatCard(
                            label: 'OPEN',
                            value: stats.tickets.open,
                            color: AppColors.danger,
                            icon: Icons.inbox_rounded,
                            subtitle: 'need attention'),
                        StatCard(
                            label: 'IN PROGRESS',
                            value: stats.tickets.inProgress,
                            color: AppColors.warning,
                            icon: Icons.autorenew_rounded,
                            subtitle: 'being handled'),
                        StatCard(
                            label: 'RESOLVED',
                            value: stats.tickets.resolved,
                            color: AppColors.primaryLight,
                            icon: Icons.check_circle_rounded,
                            subtitle: 'completed'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Pie chart
                    if (stats.tickets.total > 0) ...[
                      _SectionHeader(
                          label: 'Status Breakdown',
                          icon: Icons.donut_large_rounded),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: AppShadows.card,
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 190,
                              child: PieChart(
                                PieChartData(
                                  sections: _buildPieSections(
                                      stats.tickets.open,
                                      stats.tickets.inProgress,
                                      stats.tickets.resolved,
                                      stats.tickets.closed),
                                  sectionsSpace: 3,
                                  centerSpaceRadius: 50,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _PieLegend(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    _SectionHeader(label: 'Tasks', icon: Icons.task_alt_rounded),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                              label: 'TOTAL TASKS',
                              value: stats.tasks.total,
                              color: AppColors.purple,
                              icon: Icons.checklist_rounded),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                              label: 'COMPLETED',
                              value: stats.tasks.completed,
                              color: AppColors.primary,
                              icon: Icons.task_alt_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _SectionHeader(
                        label: 'Inventory', icon: Icons.inventory_2_rounded),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                              label: 'TOTAL REQUESTS',
                              value: stats.machines.total,
                              color: AppColors.info,
                              icon: Icons.computer_rounded),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                              label: 'PENDING',
                              value: stats.machines.pending,
                              color: AppColors.warning,
                              icon: Icons.pending_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
      int open, int inProgress, int resolved, int closed) {
    final total = open + inProgress + resolved + closed;
    if (total == 0) return [];
    final sections = <PieChartSectionData>[];
    void add(int v, Color c) {
      if (v > 0) {
        sections.add(PieChartSectionData(
          value: v.toDouble(),
          color: c,
          title: '${(v / total * 100).round()}%',
          radius: 62,
          titleStyle: const TextStyle(
              fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
        ));
      }
    }
    add(open, AppColors.danger);
    add(inProgress, AppColors.warning);
    add(resolved, AppColors.primaryLight);
    add(closed, AppColors.textMuted);
    return sections;
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 14, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _PieLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      (color: AppColors.danger, label: 'Open'),
      (color: AppColors.warning, label: 'In Progress'),
      (color: AppColors.primaryLight, label: 'Resolved'),
      (color: AppColors.textMuted, label: 'Closed'),
    ];
    return Wrap(
      spacing: 20,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: items
          .map((i) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration:
                          BoxDecoration(color: i.color, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text(i.label,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ))
          .toList(),
    );
  }
}
