import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso_admin/core/supabase/supabase_provider.dart';
import 'package:verso_admin/features/auth/data/admin_auth_repository.dart';

final adminAuthRepositoryProvider = Provider<AdminAuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AdminAuthRepository(client: client);
});

final adminAuthStateProvider = StreamProvider<AuthState>((ref) {
  final repo = ref.watch(adminAuthRepositoryProvider);
  return repo.authStateChanges;
});

final isAdminVerifiedProvider = FutureProvider<bool>((ref) async {
  ref.watch(adminAuthStateProvider);
  final repo = ref.watch(adminAuthRepositoryProvider);
  final user = repo.currentUser;
  if (user == null) return false;
  return repo.verifyAdminRole(user);
});

class AdminLoginController extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() => null;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(adminAuthRepositoryProvider);
      final user = await repo.signInAdmin(email: email, password: password);
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(adminAuthRepositoryProvider);
      await repo.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final adminLoginControllerProvider =
    AsyncNotifierProvider<AdminLoginController, User?>(
  AdminLoginController.new,
);
