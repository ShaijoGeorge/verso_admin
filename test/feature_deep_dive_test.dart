// ignore_for_file: avoid_print, unused_import, directives_ordering
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso_admin/features/dashboard/data/dashboard_repository.dart';
import 'package:verso_admin/features/feedback/data/feedback_repository.dart';
import 'package:verso_admin/features/system/data/system_repository.dart';
import 'package:verso_admin/features/alerts/data/alerts_repository.dart';
import 'package:verso_admin/features/users/data/users_repository.dart';

void main() {
  test('Detailed feature-by-feature test', () async {
    final envLines = await File('.env').readAsLines();
    final env = <String, String>{};
    for (final line in envLines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final idx = trimmed.indexOf('=');
      if (idx != -1) {
        env[trimmed.substring(0, idx).trim()] = trimmed.substring(idx + 1).trim();
      }
    }
    final url = env['SUPABASE_URL'] ?? '';
    final anonKey = env['SUPABASE_ANON_KEY'] ?? '';
    final client = SupabaseClient(url, anonKey);

    print('=== 1. DASHBOARD FEATURE ===');
    final dashRepo = DashboardRepository(client: client);
    try {
      final stats = await dashRepo.fetchStats();
      print('Dashboard stats SUCCESS: totalUsers=${stats.totalUsers}, activeReaders=${stats.activeReadersToday}, signups=${stats.newSignupsToday}, openFeedback=${stats.openFeedbackCount}');
    } catch (e) {
      print('Dashboard stats ERROR: $e');
    }

    print('=== 2. SYSTEM CONFIG FETCH & SAVE ===');
    final sysRepo = SystemRepository(client: client);
    try {
      final rawRow = await client.from('system_config').select().limit(1).maybeSingle();
      print('system_config raw columns: ${rawRow?.keys.toList()}');
      print('system_config raw data: $rawRow');
      
      final config = await sysRepo.fetchConfig();
      print('fetchConfig SUCCESS: latestVersion=${config.latestVersion}, forceUpdate=${config.forceUpdate}, verseOverride=${config.verseOverrideEnabled}');
    } catch (e) {
      print('System config ERROR: $e');
    }

    print('=== 3. DAILY VERSE UPDATE ===');
    try {
      final verseRow = await client.from('daily_verses').select().limit(1).maybeSingle();
      print('daily_verses raw columns: ${verseRow?.keys.toList()}');
    } catch (e) {
      print('daily_verses ERROR: $e');
    }

    print('=== 4. USER PROGRESS (CHECK RLS & DATA) ===');
    try {
      final res = await client.from('user_progress').select().limit(5);
      print('user_progress query SUCCESS: count=${(res as List).length}');
    } catch (e) {
      print('user_progress query ERROR: $e');
    }

    print('=== 5. FEEDBACKS (CHECK RLS & DATA) ===');
    final feedbackRepo = FeedbackRepository(client: client);
    try {
      final res = await feedbackRepo.fetchFeedbacks();
      print('feedbacks query SUCCESS: count=${res.length}');
      
      // Test insert dummy feedback then delete it
      final inserted = await client.from('feedbacks').insert({
        'type': 'idea',
        'message': 'Test automated admin probe',
        'platform': 'android',
        'app_version': '2.0.1',
      }).select().single();
      print('Test feedback insert SUCCESS: id=${inserted['id']}');
      
      await feedbackRepo.deleteFeedback(inserted['id'] as String);
      print('Test feedback delete SUCCESS');
    } catch (e) {
      print('feedbacks ERROR: $e');
    }

    final adminProfile = await client.from('profiles').select().eq('username', 'versoadmin').maybeSingle();
    print('versoadmin profile: $adminProfile');

    print('=== 7. PROFILES UPDATE (ROLE & STREAK) ===');
    final usersRepo = UsersRepository(client: client);
    try {
      final profileRow = await client.from('profiles').select().limit(1).maybeSingle();
      print('profiles raw columns: ${profileRow?.keys.toList()}');
      print('profiles sample row: $profileRow');
      final testUserId = profileRow!['id'] as String;
      final originalStreak = profileRow['current_streak'] as int? ?? 0;
      
      // Test update streak
      await usersRepo.updateStreak(
        userId: testUserId,
        streak: originalStreak + 5,
      );
      final checkRow = await client.from('profiles').select('current_streak').eq('id', testUserId).single();
      print('streak after +5: ${checkRow['current_streak']} (expected ${originalStreak + 5})');
      
      // Revert streak
      await usersRepo.updateStreak(
        userId: testUserId,
        streak: originalStreak,
      );
      final revertRow = await client.from('profiles').select('current_streak').eq('id', testUserId).single();
      print('streak after revert: ${revertRow['current_streak']} (expected $originalStreak)');
    } catch (e) {
      print('profiles update ERROR: $e');
    }
  });
}
