import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:verso_admin/core/design/design.dart';
import 'package:verso_admin/core/widgets/error_state_widget.dart';
import 'package:verso_admin/features/alerts/models/live_alert.dart';
import 'package:verso_admin/features/alerts/providers/alerts_provider.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(liveAlertsProvider);
    final selectedFilter = ref.watch(alertFilterProvider);
    final textTheme = context.textTheme;
    final colors = context.colors;
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Activity Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear Alert Feed',
            onPressed: () {
              ref.read(liveAlertsProvider.notifier).clearAlerts();
              VersoSnackbar.show(context, message: 'Alert feed cleared.');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Feed',
            onPressed: () => ref.read(liveAlertsProvider.notifier).refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row + Live indicator
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All Activity'),
                          selected: selectedFilter == null,
                          onSelected: (_) {
                            ref.read(alertFilterProvider.notifier).state = null;
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('New Users'),
                          selected: selectedFilter == AlertType.newUser,
                          onSelected: (_) {
                            ref.read(alertFilterProvider.notifier).state =
                                AlertType.newUser;
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Feedback'),
                          selected: selectedFilter == AlertType.newFeedback,
                          onSelected: (_) {
                            ref.read(alertFilterProvider.notifier).state =
                                AlertType.newFeedback;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.appColors.success.withValues(alpha: 0.12),
                    borderRadius: AppRadii.borderRadiusFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.appColors.success,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'REALTIME',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: context.appColors.success,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: alertsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, _) => ErrorStateWidget(
                error: err,
                onRetry: () => ref.read(liveAlertsProvider.notifier).refresh(),
              ),
              data: (alerts) {
                final filtered = selectedFilter == null
                    ? alerts
                    : alerts.where((a) => a.type == selectedFilter).toList();

                if (filtered.isEmpty) {
                  return const VersoEmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: 'No activity events',
                    subtitle:
                        'Live Supabase postgres inserts will stream here in real-time.',
                  );
                }

                return ListView.separated(
                  padding: Spacing.pagePadding,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Gap(Spacing.sm),
                  itemBuilder: (context, index) {
                    final alert = filtered[index];
                    final isUser = alert.type == AlertType.newUser;
                    final iconColor = isUser
                        ? context.appColors.streak
                        : palette.primary;
                    final icon = isUser
                        ? Icons.person_add_alt_1_rounded
                        : Icons.feedback_rounded;
                    final timeStr =
                        DateFormat('MMM d, h:mm:ss a').format(alert.timestamp);

                    return VersoCard(
                      padding: const EdgeInsets.all(Spacing.md),
                      onTap: () {
                        _showAlertDetails(context, alert);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.12),
                              borderRadius: AppRadii.borderRadiusMD,
                            ),
                            child: Icon(icon, color: iconColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      alert.title,
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      timeStr,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colors.onSurfaceVariant
                                            .withValues(alpha: 0.7),
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  alert.message,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAlertDetails(BuildContext context, LiveAlert alert) {
    VersoBottomSheet.show(
      context: context,
      title: alert.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alert.message,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(Spacing.md),
          Text(
            'Raw Postgres Record Payload:',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const Gap(Spacing.xs),
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: AppRadii.borderRadiusSM,
            ),
            child: SelectableText(
              alert.metadata != null
                  ? alert.metadata.toString()
                  : 'No additional metadata available',
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 12,
              ),
            ),
          ),
          const Gap(Spacing.lg),
        ],
      ),
    );
  }
}
