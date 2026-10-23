import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verso_admin/core/supabase/supabase_provider.dart';
import 'package:verso_admin/features/users/data/users_repository.dart';
import 'package:verso_admin/features/users/models/user_profile.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return UsersRepository(client: client);
});

final userSearchQueryProvider = StateProvider<String>((ref) => '');

final usersListProvider =
    AsyncNotifierProvider<UsersListNotifier, List<VersoUserProfile>>(
  UsersListNotifier.new,
);

class UsersListNotifier extends AsyncNotifier<List<VersoUserProfile>> {
  @override
  Future<List<VersoUserProfile>> build() async {
    final query = ref.watch(userSearchQueryProvider);
    final repo = ref.watch(usersRepositoryProvider);
    return repo.fetchUsers(searchQuery: query);
  }

  Future<void> search(String query) async {
    ref.read(userSearchQueryProvider.notifier).state = query;
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    final repo = ref.read(usersRepositoryProvider);
    await repo.updateUserRole(userId: userId, newRole: newRole);
    ref.invalidateSelf();
  }

  Future<void> toggleFreeze(String userId, bool isFrozen) async {
    final repo = ref.read(usersRepositoryProvider);
    await repo.setStreakFreeze(userId: userId, isFrozen: isFrozen);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
