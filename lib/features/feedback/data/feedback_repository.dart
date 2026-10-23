import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso_admin/features/feedback/models/feedback_item.dart';
import 'package:verso_admin/features/feedback/models/feedback_type.dart';

class FeedbackRepository {
  FeedbackRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Fetches feedback submissions with optional filters.
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

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      final list = await query.order('created_at', ascending: false).limit(limit);

      return (list as List)
          .map((e) => FeedbackItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Updates status ('open', 'in_progress', 'resolved') directly in Supabase.
  Future<void> updateFeedbackStatus({
    required String feedbackId,
    required String newStatus,
  }) async {
    await _client.from('feedbacks').update({
      'status': newStatus,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', feedbackId);
  }
}
