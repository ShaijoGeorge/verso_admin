import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso_admin/features/alerts/models/live_alert.dart';

class AlertsRepository {
  AlertsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  RealtimeChannel? _activityChannel;

  /// Subscribes to Supabase Realtime Postgres Changes on `profiles` and `feedbacks`.
  Stream<LiveAlert> subscribeToLiveAlerts() {
    final controller = StreamController<LiveAlert>.broadcast();

    _activityChannel = _client.channel('public:admin-activity')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'profiles',
        callback: (payload) {
          try {
            final alert = LiveAlert.fromProfileInsert(payload.newRecord);
            controller.add(alert);
          } catch (e) {
            debugPrint('Failed to parse profiles insert realtime payload: $e');
          }
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'feedbacks',
        callback: (payload) {
          try {
            final alert = LiveAlert.fromFeedbackInsert(payload.newRecord);
            controller.add(alert);
          } catch (e) {
            debugPrint('Failed to parse feedbacks insert realtime payload: $e');
          }
        },
      )
      ..subscribe();

    controller.onCancel = () {
      _activityChannel?.unsubscribe();
    };

    return controller.stream;
  }

  /// Fetches recent events from database to initialize the alerts stream.
  Future<List<LiveAlert>> fetchRecentAlerts({int limit = 20}) async {
    final alerts = <LiveAlert>[];

    // 1. Fetch recent profiles
    try {
      final profiles = await _client
          .from('profiles')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      for (final p in profiles as List) {
        alerts.add(LiveAlert.fromProfileInsert(p as Map<String, dynamic>));
      }
    } catch (_) {}

    // 2. Fetch recent feedbacks
    try {
      final feedbacks = await _client
          .from('feedbacks')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      for (final f in feedbacks as List) {
        alerts.add(LiveAlert.fromFeedbackInsert(f as Map<String, dynamic>));
      }
    } catch (_) {}

    alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return alerts.take(limit).toList();
  }

  /// Registers an admin device's FCM push token into the `admin_devices` table.
  Future<void> registerAdminDevice({
    required String fcmToken,
    required String deviceName,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      await _client.from('admin_devices').upsert(
        {
          'admin_id': user.id,
          'fcm_token': fcmToken,
          'device_name': deviceName,
          'platform': defaultTargetPlatform.name,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'fcm_token',
      );
    } catch (e) {
      debugPrint('Failed to upsert admin device FCM token: $e');
    }
  }

  void dispose() {
    _activityChannel?.unsubscribe();
  }
}
