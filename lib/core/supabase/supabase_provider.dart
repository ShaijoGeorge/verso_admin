import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the global [SupabaseClient] instance.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for Supabase Auth service.
final supabaseAuthProvider = Provider<GoTrueClient>((ref) {
  return ref.watch(supabaseClientProvider).auth;
});

/// Stream of auth state changes.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseAuthProvider).onAuthStateChange;
});

/// Current authenticated user (or null).
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateChangesProvider);
  return ref.watch(supabaseAuthProvider).currentUser;
});
