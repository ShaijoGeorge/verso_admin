import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:verso_admin/core/design/design.dart';
import 'package:verso_admin/core/widgets/error_state_widget.dart';
import 'package:verso_admin/features/feedback/models/feedback_type.dart';
import 'package:verso_admin/features/feedback/providers/feedback_provider.dart';
import 'package:verso_admin/features/feedback/widgets/feedback_detail_sheet.dart';

class FeedbackScreen extends ConsumerWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackAsync = ref.watch(feedbackInboxProvider);
    final selectedType = ref.watch(feedbackTypeFilterProvider);
    final textTheme = context.textTheme;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback & Issue Triage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Inbox',
            onPressed: () => ref.read(feedbackInboxProvider.notifier).refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: [
                // Type filters
                FilterChip(
                  label: const Text('All Submissions'),
                  selected: selectedType == null,
                  onSelected: (_) {
                    ref.read(feedbackTypeFilterProvider.notifier).state = null;
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  avatar: const Icon(Icons.bug_report_outlined, size: 16),
                  label: const Text('Issues'),
                  selected: selectedType == FeedbackType.issue,
                  onSelected: (_) {
                    ref.read(feedbackTypeFilterProvider.notifier).state =
                        FeedbackType.issue;
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  avatar: const Icon(Icons.lightbulb_outline_rounded, size: 16),
                  label: const Text('Ideas'),
                  selected: selectedType == FeedbackType.idea,
                  onSelected: (_) {
                    ref.read(feedbackTypeFilterProvider.notifier).state =
                        FeedbackType.idea;
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: feedbackAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => ErrorStateWidget(
                error: err,
                onRetry: () =>
                    ref.read(feedbackInboxProvider.notifier).refresh(),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const VersoEmptyState(
                    icon: Icons.inbox_rounded,
                    title: 'No feedback found',
                    subtitle:
                        'No feedback submissions found in Supabase.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(feedbackInboxProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: Spacing.pagePadding,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Gap(Spacing.sm),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final timeStr =
                          DateFormat('MMM d, h:mm a').format(item.createdAt);

                      return VersoCard(
                        onTap: () => FeedbackDetailSheet.show(context, item),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                VersoChip(
                                  text: item.type.shortTitle.toUpperCase(),
                                  color: item.type.accentColor,
                                ),
                                const SizedBox(width: 8),
                                VersoChip(
                                  text: item.platform.toUpperCase(),
                                  color: colors.surfaceContainerHighest,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'v${item.appVersion}',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  timeStr,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant
                                        .withValues(alpha: 0.7),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(Spacing.sm),
                            Text(
                              item.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(Spacing.xs),
                            Row(
                              children: [
                                Text(
                                  item.userEmail ?? 'Anonymous',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                const Spacer(),
                                if (item.imageUrls.isNotEmpty) ...[
                                  Icon(
                                    Icons.attach_file_rounded,
                                    size: 14,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${item.imageUrls.length}',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
