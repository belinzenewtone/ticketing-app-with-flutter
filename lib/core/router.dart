import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/admin/admin_shell.dart';
import '../screens/admin/dashboard_screen.dart';
import '../screens/admin/tickets_screen.dart';
import '../screens/admin/ticket_detail_screen.dart';
import '../screens/admin/inventory_screen.dart';
import '../screens/admin/tasks_screen.dart';
import '../screens/admin/knowledge_screen.dart';
import '../screens/portal/portal_shell.dart';
import '../screens/portal/portal_tickets_screen.dart';
import '../screens/portal/portal_new_ticket_screen.dart';
import '../screens/portal/portal_ticket_detail_screen.dart';
import '../screens/profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _adminNavKey = GlobalKey<NavigatorState>();
final _portalNavKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoginRoute = state.matchedLocation == '/login';

      if (authState is AuthLoading) return null;

      if (authState is AuthAuthenticated) {
        if (isLoginRoute) {
          return authState.user.isStaff ? '/admin/dashboard' : '/portal';
        }
        return null;
      }

      // Not authenticated
      if (!isLoginRoute) return '/login';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // ---- Admin shell ----
      ShellRoute(
        navigatorKey: _adminNavKey,
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            pageBuilder: (context, state) =>
                _fade(state, const DashboardScreen()),
          ),
          GoRoute(
            path: '/admin/tickets',
            pageBuilder: (context, state) =>
                _fade(state, const TicketsScreen()),
          ),
          GoRoute(
            path: '/admin/tickets/:id',
            builder: (context, state) =>
                TicketDetailScreen(ticketId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/admin/inventory',
            pageBuilder: (context, state) =>
                _fade(state, const InventoryScreen()),
          ),
          GoRoute(
            path: '/admin/tasks',
            pageBuilder: (context, state) => _fade(state, const TasksScreen()),
          ),
          GoRoute(
            path: '/admin/knowledge',
            pageBuilder: (context, state) =>
                _fade(state, const KnowledgeScreen()),
          ),
          GoRoute(
            path: '/admin/profile',
            pageBuilder: (context, state) =>
                _fade(state, const ProfileScreen()),
          ),
        ],
      ),

      // ---- Portal shell ----
      ShellRoute(
        navigatorKey: _portalNavKey,
        builder: (context, state, child) => PortalShell(child: child),
        routes: [
          GoRoute(
            path: '/portal',
            pageBuilder: (context, state) =>
                _fade(state, const PortalTicketsScreen()),
          ),
          GoRoute(
            path: '/portal/new',
            builder: (context, state) => const PortalNewTicketScreen(),
          ),
          GoRoute(
            path: '/portal/tickets/:id',
            builder: (context, state) => PortalTicketDetailScreen(
                ticketId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/portal/profile',
            pageBuilder: (context, state) =>
                _fade(state, const ProfileScreen()),
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, animation, __, c) =>
          FadeTransition(opacity: animation, child: c),
    );
