import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userName = authState is AuthAuthenticated
        ? authState.user.name.split(' ').first
        : 'there';

    final statsAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good day, $userName 👋',
                style: const TextStyle(fontSize: 16)),
            const Text('IT Dashboard',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => ref.invalidate(dashboardProvider),
          ),
          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF059669),
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
            onPressed: () => context.go('/admin/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Ticket stats
              const Text('Tickets',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569))),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.8,
                children: [
                  StatCard(
                      label: 'Total',
                      value: stats.tickets.total,
                      color: const Color(0xFF059669),
                      icon: Icons.confirmation_number_outlined),
                  StatCard(
                      label: 'Open',
                      value: stats.tickets.open,
                      color: const Color(0xFFDC2626),
                      icon: Icons.inbox_outlined),
                  StatCard(
                      label: 'In Progress',
                      value: stats.tickets.inProgress,
                      color: const Color(0xFFD97706),
                      icon: Icons.sync_outlined),
                  StatCard(
                      label: 'Resolved',
                      value: stats.tickets.resolved,
                      color: const Color(0xFF059669),
                      icon: Icons.check_circle_outline),
                ],
              ),
              const SizedBox(height: 20),

              // Ticket status pie chart
              if (stats.tickets.total > 0) ...[
                const Text('Ticket Status Breakdown',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569))),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieSections(stats.tickets.open,
                              stats.tickets.inProgress, stats.tickets.resolved, stats.tickets.closed),
                          sectionsSpace: 3,
                          centerSpaceRadius: 48,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _PieLegend(),
                const SizedBox(height: 20),
              ],

              // Task stats
              const Text('Tasks',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569))),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                        label: 'Total Tasks',
                        value: stats.tasks.total,
                        color: const Color(0xFF7C3AED),
                        icon: Icons.checklist),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                        label: 'Completed',
                        value: stats.tasks.completed,
                        color: const Color(0xFF059669),
                        icon: Icons.task_alt),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Machine stats
              const Text('Inventory',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569))),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                        label: 'Total Requests',
                        value: stats.machines.total,
                        color: const Color(0xFF0284C7),
                        icon: Icons.computer_outlined),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                        label: 'Pending',
                        value: stats.machines.pending,
                        color: const Color(0xFFD97706),
                        icon: Icons.pending_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
    void add(int v, Color c, String t) {
      if (v > 0) {
        sections.add(PieChartSectionData(
          value: v.toDouble(),
          color: c,
          title: '${(v / total * 100).round()}%',
          radius: 60,
          titleStyle: const TextStyle(
              fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
        ));
      }
    }
    add(open, const Color(0xFFDC2626), 'Open');
    add(inProgress, const Color(0xFFD97706), 'In Progress');
    add(resolved, const Color(0xFF059669), 'Resolved');
    add(closed, const Color(0xFF64748B), 'Closed');
    return sections;
  }
}

class _PieLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      (color: Color(0xFFDC2626), label: 'Open'),
      (color: Color(0xFFD97706), label: 'In Progress'),
      (color: Color(0xFF059669), label: 'Resolved'),
      (color: Color(0xFF64748B), label: 'Closed'),
    ];
    return Wrap(
      spacing: 16,
      children: items
          .map((i) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: i.color, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(i.label,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B))),
                ],
              ))
          .toList(),
    );
  }
}
