import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:verso_admin/core/design/design.dart';
import 'package:verso_admin/core/widgets/error_state_widget.dart';
import 'package:verso_admin/features/users/providers/users_provider.dart';
import 'package:verso_admin/features/users/widgets/user_detail_bottom_sheet.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersListProvider);
    final textTheme = context.textTheme;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Directory & Telemetry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Users',
            onPressed: () => ref.read(usersListProvider.notifier).refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Header
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: VersoTextField(
              controller: _searchController,
              label: 'Search by name or email',
              icon: Icons.search_rounded,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(usersListProvider.notifier).search('');
                        setState(() {});
                      },
                    )
                  : null,
              validator: null,
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: usersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, _) => ErrorStateWidget(
                error: err,
                onRetry: () => ref.read(usersListProvider.notifier).refresh(),
              ),
              data: (users) {
                if (users.isEmpty) {
                  return const VersoEmptyState(
                    icon: Icons.person_search_rounded,
                    title: 'No users found',
                    subtitle: 'Try a different search query or pull to refresh.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(usersListProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: Spacing.pagePadding,
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const Gap(Spacing.sm),
                    itemBuilder: (context, index) {
                      final user = users[index];

                      return VersoCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.md,
                          vertical: Spacing.sm + 4,
                        ),
                        onTap: () => UserDetailBottomSheet.show(context, user),
                        child: Row(
                          children: [
                            VersoAvatar.fromGender(user.gender, size: 44),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          user.name,
                                          style:
                                              textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (user.isAdmin) ...[
                                        const SizedBox(width: 6),
                                        VersoChip(
                                          text: 'ADMIN',
                                          color: colors.primary,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.local_fire_department_rounded,
                                      size: 16,
                                      color: context.appColors.streak,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${user.streakCount}d',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: context.appColors.streak,
                                      ),
                                    ),
                                  ],
                                ),
                                if (user.isStreakFrozen) ...[
                                  const SizedBox(height: 3),
                                  VersoChip(
                                    text: 'FROZEN',
                                    color: context.appColors.streakFreeze,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right_rounded, size: 18),
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
