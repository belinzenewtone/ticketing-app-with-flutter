import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PortalShell extends StatelessWidget {
  final Widget child;

  const PortalShell({super.key, required this.child});

  static const _tabs = [
    (path: '/portal', label: 'My Tickets', icon: Icons.inbox_outlined, activeIcon: Icons.inbox),
    (path: '/portal/new', label: 'New Ticket', icon: Icons.add_circle_outline, activeIcon: Icons.add_circle),
    (path: '/portal/profile', label: 'Profile', icon: Icons.person_outline, activeIcon: Icons.person),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path) &&
          (_tabs[i].path != '/portal' ||
              location == '/portal' ||
              location.startsWith('/portal/tickets'))) return i;
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
                  selectedIcon:
                      Icon(t.activeIcon, color: const Color(0xFF059669)),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}
