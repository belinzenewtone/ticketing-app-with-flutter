import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';

class PortalShell extends StatelessWidget {
  final Widget child;

  const PortalShell({super.key, required this.child});

  static const _tabs = [
    (path: '/portal', label: 'My Tickets', icon: Icons.inbox_outlined, activeIcon: Icons.inbox_rounded),
    (path: '/portal/new', label: 'New Ticket', icon: Icons.add_circle_outline_rounded, activeIcon: Icons.add_circle_rounded),
    (path: '/portal/profile', label: 'Profile', icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded),
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: AppShadows.nav,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final t = _tabs[i];
                final active = i == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.go(t.path),
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
                            active ? t.activeIcon : t.icon,
                            size: 22,
                            color: active ? AppColors.primary : AppColors.textMuted,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            t.label,
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
      ),
    );
  }
}
