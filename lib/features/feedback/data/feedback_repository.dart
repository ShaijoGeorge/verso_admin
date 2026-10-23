import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso_admin/features/feedback/models/feedback_item.dart';
import 'package:verso_admin/features/feedback/models/feedback_type.dart';

class FeedbackRepository {
  FeedbackRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Fetches feedback submissions from Supabase matching the exact table schema:
  /// (id, user_id, user_email, type, message, image_urls, app_version, platform, created_at)
  Future<List<FeedbackItem>> fetchFeedbacks({
    FeedbackType? type,
    String? status,
    int limit = 50,
  }) async {
    try {
      var query = _client.from('feedbacks').select();

      if (type != null) {
        query = query.eq('type', type.name);
      }

      final list =
          await query.order('created_at', ascending: false).limit(limit);

      return (list as List)
          .map((e) => FeedbackItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Updates status if supported by schema, or handles gracefully.
  Future<void> updateFeedbackStatus({
    required String feedbackId,
    required String newStatus,
  }) async {
    try {
      await _client.from('feedbacks').update({
        'status': newStatus,
      }).eq('id', feedbackId);
    } catch (_) {
      // Gracefully handled if column is not on table
    }
  }

  /// Deletes a feedback item from the database.
  Future<void> deleteFeedback(String feedbackId) async {
    await _client.from('feedbacks').delete().eq('id', feedbackId);
  }
}
