import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';

class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  static const _tabs = [
    (path: '/admin/dashboard', label: 'Dashboard', icon: Icons.grid_view_rounded, activeIcon: Icons.grid_view_rounded),
    (path: '/admin/tickets', label: 'Tickets', icon: Icons.inbox_outlined, activeIcon: Icons.inbox_rounded),
    (path: '/admin/inventory', label: 'Inventory', icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2_rounded),
    (path: '/admin/tasks', label: 'Tasks', icon: Icons.task_alt_outlined, activeIcon: Icons.task_alt_rounded),
    (path: '/admin/knowledge', label: 'Knowledge', icon: Icons.auto_stories_outlined, activeIcon: Icons.auto_stories_rounded),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: _AppNavBar(
        currentIndex: currentIndex,
        onTap: (i) => context.go(_tabs[i].path),
        labels: _tabs.map((t) => t.label).toList(),
        icons: _tabs.map((t) => t.icon).toList(),
        activeIcons: _tabs.map((t) => t.activeIcon).toList(),
      ),
    );
  }
}

class _AppNavBar extends StatelessWidget {
  final int currentIndex;
  final List<String> labels;
  final List<IconData> icons;
  final List<IconData> activeIcons;
  final void Function(int) onTap;

  const _AppNavBar({
    required this.currentIndex,
    required this.labels,
    required this.icons,
    required this.activeIcons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: AppShadows.nav,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: List.generate(labels.length, (i) {
              final active = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: active
                        ? BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          )
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          active ? activeIcons[i] : icons[i],
                          size: 21,
                          color: active ? AppColors.primary : AppColors.textMuted,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                            color: active ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
