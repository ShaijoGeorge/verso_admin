import 'package:flutter_test/flutter_test.dart';
import 'package:verso_admin/features/users/models/user_profile.dart';

void main() {
  group('VersoUserProfile Schema Resiliency', () {
    test('parses live Supabase profiles table format with username and current_streak', () {
      final json = {
        'id': '0ccd0649-63df-45b5-a547-e4b004784e46',
        'username': 'Shaijo George',
        'current_streak': 5,
        'updated_at': '2025-11-28T22:13:18.983691+00:00',
        'canon_type': 'catholic',
        'role': 'reader',
        'is_admin': false,
      };

      final profile = VersoUserProfile.fromJson(json);

      expect(profile.id, '0ccd0649-63df-45b5-a547-e4b004784e46');
      expect(profile.name, 'Shaijo George');
      expect(profile.streakCount, 5);
      expect(profile.role, 'reader');
      expect(profile.isAdmin, false);
      expect(profile.canonType, 'catholic');
      expect(profile.email, 'shaijogeorge@verso.app');
      expect(profile.createdAt, DateTime.parse('2025-11-28T22:13:18.983691+00:00'));
    });

    test('parses admin user profile format', () {
      final json = {
        'id': '2c9bb33b-a69e-4e30-b457-39978869157a',
        'username': 'versoadmin',
        'current_streak': 0,
        'updated_at': '2026-10-23T09:02:11.831159+00:00',
        'canon_type': 'catholic',
        'role': 'admin',
        'is_admin': true,
      };

      final profile = VersoUserProfile.fromJson(json);

      expect(profile.name, 'versoadmin');
      expect(profile.isAdmin, true);
      expect(profile.role, 'admin');
    });

    test('falls back gracefully on empty or null values', () {
      final json = <String, dynamic>{};
      final profile = VersoUserProfile.fromJson(json);

      expect(profile.id, '');
      expect(profile.name, 'Reader');
      expect(profile.streakCount, 0);
      expect(profile.isAdmin, false);
      expect(profile.isStreakFrozen, false);
    });
  });
}
