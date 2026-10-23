import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verso_admin/core/transitions/app_page_transitions.dart';
import 'package:verso_admin/core/widgets/main_wrapper.dart';
import 'package:verso_admin/core/widgets/not_found_screen.dart';
import 'package:verso_admin/features/alerts/screens/alerts_screen.dart';
import 'package:verso_admin/features/auth/providers/admin_auth_provider.dart';
import 'package:verso_admin/features/auth/screens/admin_login_screen.dart';
import 'package:verso_admin/features/dashboard/screens/dashboard_screen.dart';
import 'package:verso_admin/features/feedback/screens/feedback_screen.dart';
import 'package:verso_admin/features/system/screens/system_screen.dart';
import 'package:verso_admin/features/users/screens/users_screen.dart';

/// Helper to convert a Stream into a Listenable for GoRouter refresh.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(adminAuthRepositoryProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: GoRouterRefreshStream(authRepo.authStateChanges),
    redirect: (context, state) async {
      final user = authRepo.currentUser;
      final isLoggingIn = state.matchedLocation == '/login';

      if (user == null) {
        return isLoggingIn ? null : '/login';
      }

      final isAdmin = await authRepo.verifyAdminRole(user);
      if (!isAdmin) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
    errorBuilder: (context, state) => NotFoundScreen(error: state.error),
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          key: state.pageKey,
          child: const AdminLoginScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
                  key: state.pageKey,
                  child: const DashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/alerts',
                name: 'alerts',
                pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
                  key: state.pageKey,
                  child: const AlertsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/users',
                name: 'users',
                pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
                  key: state.pageKey,
                  child: const UsersScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/feedback',
                name: 'feedback',
                pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
                  key: state.pageKey,
                  child: const FeedbackScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/system',
                name: 'system',
                pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
                  key: state.pageKey,
                  child: const SystemScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
