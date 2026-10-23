import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso_admin/features/system/models/system_config.dart';

class SystemRepository {
  SystemRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Fetches system configuration from Supabase.
  Future<SystemConfig> fetchConfig() async {
    try {
      final response = await _client
          .from('system_config')
          .select()
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return const SystemConfig();
      }

      return SystemConfig.fromJson(response);
    } catch (_) {
      return const SystemConfig();
    }
  }

  /// Updates or inserts system configuration in Supabase.
  Future<void> saveConfig(SystemConfig config) async {
    final payload = {
      'id': 1,
      ...config.toJson(),
    };

    await _client.from('system_config').upsert(payload);
  }

  /// Updates a daily verse entry in the `daily_verses` table for a specific day of the year.
  Future<void> updateDailyVerse({
    required int dayOfYear,
    required String reference,
    required String text,
    String? textMlPoc,
    String? textMlBsi,
  }) async {
    await _client.from('daily_verses').upsert({
      'day_of_year': dayOfYear,
      'reference': reference,
      'text': text,
      if (textMlPoc != null) 'text_ml_poc': textMlPoc,
      if (textMlBsi != null) 'text_ml_bsi': textMlBsi,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
