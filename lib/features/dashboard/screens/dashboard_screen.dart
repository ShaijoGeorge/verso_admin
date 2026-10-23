import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:verso_admin/core/design/design.dart';
import 'package:verso_admin/core/widgets/error_state_widget.dart';
import 'package:verso_admin/features/dashboard/providers/dashboard_provider.dart';
import 'package:verso_admin/features/dashboard/widgets/stat_summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final textTheme = context.textTheme;
    final colors = context.colors;
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Executive Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Metrics',
            onPressed: () {
              ref.read(dashboardStatsProvider.notifier).refresh();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, _) => ErrorStateWidget(
          error: err,
          onRetry: () => ref.read(dashboardStatsProvider.notifier).refresh(),
        ),
        data: (stats) {
          final timeStr =
              DateFormat('hh:mm:ss a').format(stats.lastRefreshedAt);

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(dashboardStatsProvider.notifier).refresh(),
            child: ListView(
              padding: Spacing.pagePadding,
              children: [
                // Top Welcome / Pulse Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'System Telemetry',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Live cloud telemetry from Supabase',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: context.appColors.success.withValues(alpha: 0.12),
                        borderRadius: AppRadii.borderRadiusFull,
                        border: Border.all(
                          color:
                              context.appColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.appColors.success,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'LIVE • $timeStr',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: context.appColors.success,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(Spacing.lg),

                // 2x2 KPI Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;
                    final crossAxisCount = isWide ? 4 : 2;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: Spacing.md,
                      mainAxisSpacing: Spacing.md,
                      childAspectRatio: isWide ? 1.4 : 1.05,
                      children: [
                        StatSummaryCard(
                          title: 'Total Users',
                          value: NumberFormat.compact().format(stats.totalUsers),
                          icon: Icons.group_rounded,
                          accentColor: palette.primary,
                          trendText: '+${stats.newSignupsToday}',
                          subtitle: 'Registered accounts',
                          onTap: () => context.go('/users'),
                        ),
                        StatSummaryCard(
                          title: 'Active Today',
                          value: NumberFormat.compact()
                              .format(stats.activeReadersToday),
                          icon: Icons.auto_stories_rounded,
                          accentColor: context.appColors.chapters,
                          subtitle: 'Syncd reading today',
                          onTap: () => context.go('/users'),
                        ),
                        StatSummaryCard(
                          title: 'New Signups',
                          value: stats.newSignupsToday.toString(),
                          icon: Icons.person_add_alt_1_rounded,
                          accentColor: context.appColors.streak,
                          subtitle: 'Joined today',
                          onTap: () => context.go('/alerts'),
                        ),
                        StatSummaryCard(
                          title: 'Open Feedback',
                          value: stats.openFeedbackCount.toString(),
                          icon: Icons.mark_chat_unread_rounded,
                          accentColor: stats.openFeedbackCount > 0
                              ? colors.error
                              : context.appColors.success,
                          subtitle: 'Requires review',
                          onTap: () => context.go('/feedback'),
                        ),
                      ],
                    );
                  },
                ),
                const Gap(Spacing.xl),

                // Quick Navigation Hub
                const VersoSectionHeader(title: 'Quick Triage & Controls'),
                const Gap(Spacing.md),

                Row(
                  children: [
                    Expanded(
                      child: VersoCard(
                        onTap: () => context.go('/alerts'),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: context.appColors.streak
                                    .withValues(alpha: 0.12),
                                borderRadius: AppRadii.borderRadiusMD,
                              ),
                              child: Icon(
                                Icons.bolt_rounded,
                                color: context.appColors.streak,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Live Event Stream',
                                    style: textTheme.titleSmall,
                                  ),
                                  Text(
                                    'Real-time Postgres changes',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: VersoCard(
                        onTap: () => context.go('/system'),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: palette.secondary.withValues(alpha: 0.12),
                                borderRadius: AppRadii.borderRadiusMD,
                              ),
                              child: Icon(
                                Icons.settings_suggest_rounded,
                                color: palette.secondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'System Settings',
                                    style: textTheme.titleSmall,
                                  ),
                                  Text(
                                    'App update & daily verse',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
