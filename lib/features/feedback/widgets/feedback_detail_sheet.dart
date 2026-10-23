import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:verso_admin/core/design/design.dart';
import 'package:verso_admin/features/feedback/models/feedback_item.dart';
import 'package:verso_admin/features/feedback/providers/feedback_provider.dart';

class FeedbackDetailSheet extends ConsumerWidget {
  const FeedbackDetailSheet({
    required this.feedback,
    super.key,
  });

  final FeedbackItem feedback;

  static void show(BuildContext context, FeedbackItem item) {
    VersoBottomSheet.show<void>(
      context: context,
      title: '${item.type.shortTitle} Details',
      child: FeedbackDetailSheet(feedback: item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = context.textTheme;
    final colors = context.colors;
    final timeStr =
        DateFormat('MMM d, yyyy • h:mm a').format(feedback.createdAt);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header info
          Row(
            children: [
              VersoChip(
                text: feedback.type.shortTitle.toUpperCase(),
                color: feedback.type.accentColor,
              ),
              const SizedBox(width: 8),
              VersoChip(
                text: feedback.platform.toUpperCase(),
                color: colors.surfaceContainerHighest,
              ),
              const Spacer(),
              Text(
                timeStr,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Gap(Spacing.md),

          // User info
          VersoCard(
            padding: const EdgeInsets.all(Spacing.sm + 4),
            child: Row(
              children: [
                const Icon(Icons.person_pin_circle_outlined, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.userEmail ?? 'Anonymous User',
                        style: textTheme.labelLarge,
                      ),
                      Text(
                        'Verso v${feedback.appVersion} • ${feedback.platform}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(Spacing.md),

          // Message content
          Text('User Feedback Message:', style: textTheme.labelMedium),
          const Gap(Spacing.xs),
          VersoCard(
            padding: const EdgeInsets.all(Spacing.md),
            child: SelectableText(
              feedback.message,
              style: textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ),

          // Screenshots if any
          if (feedback.imageUrls.isNotEmpty) ...[
            const Gap(Spacing.md),
            Text('Attached Screenshots:', style: textTheme.labelMedium),
            const Gap(Spacing.xs),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: feedback.imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final url = feedback.imageUrls[index];
                  return ClipRRect(
                    borderRadius: AppRadii.borderRadiusMD,
                    child: Image.network(
                      url,
                      height: 140,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 140,
                        width: 100,
                        color: colors.surfaceContainerHighest,
                        child: const Icon(Icons.broken_image_rounded),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const Gap(Spacing.lg),

          // Triage Actions
          const VersoSectionHeader(title: 'Triage Actions'),
          const Gap(Spacing.sm),

          Row(
            children: [
              Expanded(
                child: VersoButton.destructive(
                  label: 'Delete Record',
                  onPressed: () async {
                    Navigator.of(context).pop();
                    try {
                      await ref
                          .read(feedbackRepositoryProvider)
                          .deleteFeedback(feedback.id);
                      ref.invalidate(feedbackInboxProvider);
                      if (context.mounted) {
                        VersoSnackbar.success(
                          context,
                          message: 'Feedback deleted successfully',
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        VersoSnackbar.error(
                          context,
                          message: 'Failed to delete feedback: $e',
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          const Gap(Spacing.lg),
        ],
      ),
    );
  }
}
