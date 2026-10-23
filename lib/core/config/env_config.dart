import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for Verso Admin.
/// Reads from `.env` using [dotenv], with fallback to `--dart-define`.
abstract final class EnvConfig {
  static Future<void> init() async {
    try {
      await dotenv.load();
    } catch (_) {
      // .env file not present or couldn't be loaded; will fallback to fromEnvironment
    }
  }

  static String get supabaseUrl {
    final fromEnv = dotenv.env['SUPABASE_URL'];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return const String.fromEnvironment('SUPABASE_URL');
  }

  static String get supabaseAnonKey {
    final fromEnv = dotenv.env['SUPABASE_ANON_KEY'];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return const String.fromEnvironment('SUPABASE_ANON_KEY');
  }

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
