import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:verso_admin/core/design/design.dart';
import 'package:verso_admin/core/widgets/verso_avatar.dart';
import 'package:verso_admin/features/users/models/user_profile.dart';
import 'package:verso_admin/features/users/providers/users_provider.dart';

class UserDetailBottomSheet extends ConsumerWidget {
  const UserDetailBottomSheet({
    required this.user,
    super.key,
  });

  final VersoUserProfile user;

  static void show(BuildContext context, VersoUserProfile user) {
    VersoBottomSheet.show<void>(
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

    final progressAsync = ref.watch(userProgressProvider(user.id));
    final otChapters = progressAsync.value?.otChapters ?? 0;
    final ntChapters = progressAsync.value?.ntChapters ?? 0;
    final otProgress = progressAsync.value?.otProgress ?? 0.0;
    final ntProgress = progressAsync.value?.ntProgress ?? 0.0;

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
                      color: colors.tertiary,
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
                      '$otChapters / 929 chapters',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Gap(Spacing.sm),
                VersoProgressBar(
                  value: otProgress,
                  color: context.appColors.otColor,
                  label: '${(otProgress * 100).toStringAsFixed(1)}%',
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
                      '$ntChapters / 260 chapters',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Gap(Spacing.sm),
                VersoProgressBar(
                  value: ntProgress,
                  color: context.appColors.ntColor,
                  label: '${(ntProgress * 100).toStringAsFixed(1)}%',
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
                    try {
                      await ref
                          .read(usersListProvider.notifier)
                          .toggleFreeze(user.id, val);
                      if (context.mounted) {
                        VersoSnackbar.success(
                          context,
                          message: 'Streak freeze set to $val for ${user.name}',
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        VersoSnackbar.error(
                          context,
                          message: 'Failed to set streak freeze: $e',
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Adjust Current Streak'),
                  subtitle: Text('${user.streakCount} consecutive reading days'),
                  trailing: VersoButton.secondary(
                    label: 'Set Streak',
                    onPressed: () async {
                      final controller =
                          TextEditingController(text: '${user.streakCount}');
                      final newStreak = await showDialog<int>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Set Streak for ${user.name}'),
                          content: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'New Streak (days)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () {
                                final val =
                                    int.tryParse(controller.text.trim());
                                Navigator.pop(ctx, val);
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                      if (newStreak != null) {
                        if (context.mounted) Navigator.of(context).pop();
                        try {
                          await ref
                              .read(usersListProvider.notifier)
                              .updateStreak(user.id, newStreak);
                          if (context.mounted) {
                            VersoSnackbar.success(
                              context,
                              message: 'Streak updated to $newStreak days',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            VersoSnackbar.error(
                              context,
                              message: 'Failed to update streak: $e',
                            );
                          }
                        }
                      }
                    },
                  ),
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
                      try {
                        await ref
                            .read(usersListProvider.notifier)
                            .updateUserRole(user.id, newRole);
                        if (context.mounted) {
                          VersoSnackbar.success(
                            context,
                            message: 'User role updated to $newRole',
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          VersoSnackbar.error(
                            context,
                            message: 'Failed to update role: $e',
                          );
                        }
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
