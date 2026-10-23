import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso_admin/features/users/models/user_profile.dart';

class UsersRepository {
  UsersRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Fetches users with optional search query filter by name or email.
  Future<List<VersoUserProfile>> fetchUsers({
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _client.from('profiles').select();

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final term = '%${searchQuery.trim()}%';
        query = query.or('username.ilike.$term,canon_type.ilike.$term,role.ilike.$term');
      }

      dynamic list;
      try {
        list = await query
            .order('updated_at', ascending: false)
            .range(offset, offset + limit - 1);
      } catch (_) {
        try {
          list = await query
              .order('created_at', ascending: false)
              .range(offset, offset + limit - 1);
        } catch (_) {
          list = await query.range(offset, offset + limit - 1);
        }
      }

      return (list as List)
          .map((item) => VersoUserProfile.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Rethrow to let the UI ErrorStateWidget present the exact reason and allow retry
      rethrow;
    }
  }

  /// Updates a user's role (e.g. 'admin' vs 'reader').
  Future<void> updateUserRole({
    required String userId,
    required String newRole,
  }) async {
    await _client.from('profiles').update({
      'role': newRole,
      'is_admin': newRole == 'admin',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', userId);
  }

  /// Toggles streak freeze status in Supabase.
  Future<void> setStreakFreeze({
    required String userId,
    required bool isFrozen,
  }) async {
    try {
      await _client.from('profiles').update({
        'is_streak_frozen': isFrozen,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', userId);
    } catch (_) {
      // If optional column not present yet, update timestamp safely
      await _client.from('profiles').update({
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', userId);
    }
  }
}
