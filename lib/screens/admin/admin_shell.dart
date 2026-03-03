import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  static const _tabs = [
    (path: '/admin/dashboard', label: 'Dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard),
    (path: '/admin/tickets', label: 'Tickets', icon: Icons.confirmation_number_outlined, activeIcon: Icons.confirmation_number),
    (path: '/admin/inventory', label: 'Inventory', icon: Icons.computer_outlined, activeIcon: Icons.computer),
    (path: '/admin/tasks', label: 'Tasks', icon: Icons.checklist_outlined, activeIcon: Icons.checklist),
    (path: '/admin/knowledge', label: 'Knowledge', icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFD1FAE5),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF059669));
          }
          return const TextStyle(fontSize: 11, color: Color(0xFF94A3B8));
        }),
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon, color: const Color(0xFF94A3B8)),
                  selectedIcon: Icon(t.activeIcon, color: const Color(0xFF059669)),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}
