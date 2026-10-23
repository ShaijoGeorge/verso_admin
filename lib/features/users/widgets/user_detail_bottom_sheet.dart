import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:verso_admin/core/design/design.dart';
import 'package:verso_admin/features/users/models/user_profile.dart';
import 'package:verso_admin/features/users/providers/users_provider.dart';

class UserDetailBottomSheet extends ConsumerWidget {
  const UserDetailBottomSheet({
    required this.user,
    super.key,
  });

  final VersoUserProfile user;

  static void show(BuildContext context, VersoUserProfile user) {
    VersoBottomSheet.show(
      context: context,
      title: 'User Telemetry & Profile',
      child: UserDetailBottomSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = context.textTheme;
    final colors = context.colors;
    final palette = context.palette;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User Avatar & Name Banner
          Center(
            child: Column(
              children: [
                VersoAvatar.fromGender(user.gender, size: 76, borderWidth: 3),
                const Gap(Spacing.sm),
                Text(
                  user.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  user.email,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const Gap(Spacing.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VersoChip(
                      text: user.role.toUpperCase(),
                      color: user.isAdmin ? colors.primary : colors.secondary,
                    ),
                    const SizedBox(width: 8),
                    VersoChip(
                      text: '${user.canonType.toUpperCase()} CANON',
                      color: colors.tertiary ?? colors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(Spacing.lg),

          // Reading Progress Cards (OT / NT)
          const VersoSectionHeader(title: 'Synced Bible Progress'),
          const Gap(Spacing.sm),

          VersoCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 18,
                          color: context.appColors.otColor,
                        ),
                        const SizedBox(width: 8),
                        Text('Old Testament', style: textTheme.labelLarge),
                      ],
                    ),
                    Text(
                      '${user.otChaptersCompleted} / 929 chapters',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Gap(Spacing.sm),
                VersoProgressBar(
                  value: user.otProgress,
                  color: context.appColors.otColor,
                  label: '${(user.otProgress * 100).toStringAsFixed(1)}%',
                ),
                const Gap(Spacing.md),
                const Divider(height: 1),
                const Gap(Spacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_stories_rounded,
                          size: 18,
                          color: context.appColors.ntColor,
                        ),
                        const SizedBox(width: 8),
                        Text('New Testament', style: textTheme.labelLarge),
                      ],
                    ),
                    Text(
                      '${user.ntChaptersCompleted} / 260 chapters',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Gap(Spacing.sm),
                VersoProgressBar(
                  value: user.ntProgress,
                  color: context.appColors.ntColor,
                  label: '${(user.ntProgress * 100).toStringAsFixed(1)}%',
                ),
              ],
            ),
          ),
          const Gap(Spacing.md),

          // Streak & Birthday Info
          const VersoSectionHeader(title: 'Engagement & Profile Details'),
          const Gap(Spacing.sm),

          Row(
            children: [
              Expanded(
                child: VersoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: context.appColors.streak,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text('Streak', style: textTheme.labelMedium),
                        ],
                      ),
                      const Gap(Spacing.xs),
                      Text(
                        '${user.streakCount} Days',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: context.appColors.streak,
                        ),
                      ),
                      const Gap(Spacing.xs),
                      Text(
                        user.isStreakFrozen ? 'Freeze Active' : 'Active reading',
                        style: textTheme.bodySmall?.copyWith(
                          color: user.isStreakFrozen
                              ? context.appColors.streakFreeze
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: VersoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.cake_outlined,
                            color: palette.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text('Birthday', style: textTheme.labelMedium),
                        ],
                      ),
                      const Gap(Spacing.xs),
                      Text(
                        user.birthday != null && user.birthday!.isNotEmpty
                            ? user.birthday!
                            : 'Not set',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(Spacing.xs),
                      Text(
                        'Language: ${user.bibleLanguage.toUpperCase()}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Gap(Spacing.md),

          // Administrative Actions
          const VersoSectionHeader(title: 'Administrative Controls'),
          const Gap(Spacing.sm),

          VersoCard(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Streak Freeze Protection'),
                  subtitle: const Text('Manually protect streak from resetting'),
                  value: user.isStreakFrozen,
                  onChanged: (val) async {
                    Navigator.of(context).pop();
                    await ref
                        .read(usersListProvider.notifier)
                        .toggleFreeze(user.id, val);
                    if (context.mounted) {
                      VersoSnackbar.success(
                        context,
                        message: 'Streak freeze set to $val for ${user.name}',
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Administrator Privileges'),
                  subtitle: Text(
                    user.isAdmin
                        ? 'User currently has full console access'
                        : 'Standard reader access',
                  ),
                  trailing: VersoButton.secondary(
                    label: user.isAdmin ? 'Revoke Admin' : 'Make Admin',
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final newRole = user.isAdmin ? 'reader' : 'admin';
                      await ref
                          .read(usersListProvider.notifier)
                          .updateUserRole(user.id, newRole);
                      if (context.mounted) {
                        VersoSnackbar.success(
                          context,
                          message: 'User role updated to $newRole',
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const Gap(Spacing.lg),
        ],
      ),
    );
  }
}
