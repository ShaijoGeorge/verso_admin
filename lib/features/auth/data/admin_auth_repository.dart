import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAuthRepository {
  AdminAuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Signs in admin user with email and password and validates admin role.
  Future<User> signInAdmin({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Authentication failed. No user returned.');
    }

    final isAdmin = await verifyAdminRole(user);
    if (!isAdmin) {
      await _client.auth.signOut();
      throw const AuthException(
        'Access denied. This account does not have administrator privileges.',
      );
    }

    return user;
  }

  /// Checks if user has admin privileges in profiles table, user_metadata, or app_metadata.
  Future<bool> verifyAdminRole(User user) async {
    // 1. Check App Metadata / User Metadata
    final appRole = user.appMetadata['role'] as String?;
    final userRole = user.userMetadata?['role'] as String?;
    final isExplicitAdmin = (user.appMetadata['is_admin'] == true) ||
        (user.userMetadata?['is_admin'] == true);

    if (appRole == 'admin' || userRole == 'admin' || isExplicitAdmin) {
      return true;
    }

    // 2. Check profiles table in Supabase
    try {
      final profile = await _client
          .from('profiles')
          .select('role, is_admin')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        final role = profile['role'] as String?;
        final isAdminFlag = profile['is_admin'] as bool?;
        if (role == 'admin' || isAdminFlag == true) {
          return true;
        }
      }
    } catch (_) {
      // Table query failure - if in development with single master account,
      // allow fallback if matching configured admin or admin metadata.
    }

    return false;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
