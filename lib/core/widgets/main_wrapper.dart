import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verso_admin/core/design/extensions.dart';
import 'package:verso_admin/core/design/tokens/radii.dart';
import 'package:verso_admin/core/design/tokens/spacing.dart';
import 'package:verso_admin/core/supabase/supabase_provider.dart';
import 'package:verso_admin/core/transitions/animated_branch_container.dart';

class MainWrapper extends ConsumerWidget {
  const MainWrapper({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    final palette = context.palette;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 800;

    final navItems = const [
      NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard_rounded),
        label: 'Dashboard',
      ),
      NavigationDestination(
        icon: Icon(Icons.notifications_active_outlined),
        selectedIcon: Icon(Icons.notifications_active_rounded),
        label: 'Live Alerts',
      ),
      NavigationDestination(
        icon: Icon(Icons.people_outline_rounded),
        selectedIcon: Icon(Icons.people_rounded),
        label: 'Users',
      ),
      NavigationDestination(
        icon: Icon(Icons.feedback_outlined),
        selectedIcon: Icon(Icons.feedback_rounded),
        label: 'Feedback',
      ),
      NavigationDestination(
        icon: Icon(Icons.tune_rounded),
        selectedIcon: Icon(Icons.tune_rounded),
        label: 'System',
      ),
    ];

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              backgroundColor: palette.surface,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [palette.primary, palette.primaryHover],
                        ),
                        borderRadius: AppRadii.borderRadiusMD,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'VERSO ADMIN',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.md),
                    child: IconButton(
                      icon: const Icon(Icons.logout_rounded),
                      tooltip: 'Sign Out',
                      onPressed: () async {
                        await ref.read(supabaseAuthProvider).signOut();
                      },
                    ),
                  ),
                ),
              ),
              destinations: [
                for (final item in navItems)
                  NavigationRailDestination(
                    icon: item.icon,
                    selectedIcon: item.selectedIcon,
                    label: Text(item.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: AnimatedBranchContainer(
                currentIndex: navigationShell.currentIndex,
                children: [
                  for (var i = 0; i < navigationShell.route.branches.length; i++)
                    _BranchNavigator(index: i, navigationShell: navigationShell),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: AnimatedBranchContainer(
        currentIndex: navigationShell.currentIndex,
        children: [
          for (var i = 0; i < navigationShell.route.branches.length; i++)
            _BranchNavigator(index: i, navigationShell: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: navItems,
      ),
    );
  }
}

class _BranchNavigator extends StatelessWidget {
  const _BranchNavigator({
    required this.index,
    required this.navigationShell,
  });

  final int index;
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return navigationShell.route.branches[index].navigatorKey.currentContext !=
            null
        ? (navigationShell.children[index])
        : navigationShell.children[index];
  }
}
