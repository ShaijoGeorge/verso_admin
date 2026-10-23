import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso_admin/features/dashboard/models/dashboard_stats.dart';

class DashboardRepository {
  DashboardRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Fetches real-time KPI metrics from Supabase database tables.
  Future<DashboardStats> fetchStats() async {
    final now = DateTime.now().toUtc();
    final startOfDay =
        DateTime.utc(now.year, now.month, now.day).toIso8601String();

    var totalUsers = 0;
    var newSignupsToday = 0;
    var activeReadersToday = 0;
    var openFeedbackCount = 0;

    // 1. Total Registered Users
    try {
      final res = await _client
          .from('profiles')
          .select('id')
          .count(CountOption.exact);
      totalUsers = res.count;
    } catch (_) {
      try {
        final list = await _client.from('profiles').select('id');
        totalUsers = (list as List).length;
      } catch (_) {
        totalUsers = 0;
      }
    }

    // 2. New Signups Today
    try {
      final res = await _client
          .from('profiles')
          .select('id')
          .gte('created_at', startOfDay)
          .count(CountOption.exact);
      newSignupsToday = res.count;
    } catch (_) {
      try {
        final res = await _client
            .from('profiles')
            .select('id')
            .gte('updated_at', startOfDay)
            .count(CountOption.exact);
        newSignupsToday = res.count;
      } catch (_) {
        newSignupsToday = 0;
      }
    }

    // 3. Active Readers Today
    try {
      final res = await _client
          .from('profiles')
          .select('id')
          .gt('current_streak', 0)
          .count(CountOption.exact);
      activeReadersToday = res.count;
    } catch (_) {
      try {
        final res = await _client
            .from('profiles')
            .select('id')
            .gte('updated_at', startOfDay)
            .count(CountOption.exact);
        activeReadersToday = res.count;
      } catch (_) {
        activeReadersToday = 0;
      }
    }

    // 4. Open Feedback
    try {
      final res = await _client
          .from('feedbacks')
          .select('id')
          .neq('status', 'resolved')
          .count(CountOption.exact);
      openFeedbackCount = res.count;
    } catch (_) {
      try {
        final list = await _client.from('feedbacks').select('id');
        openFeedbackCount = (list as List).length;
      } catch (_) {
        openFeedbackCount = 0;
      }
    }

    return DashboardStats(
      totalUsers: totalUsers,
      activeReadersToday: activeReadersToday,
      newSignupsToday: newSignupsToday,
      openFeedbackCount: openFeedbackCount,
      lastRefreshedAt: DateTime.now(),
    );
  }
}
