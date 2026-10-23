import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for Verso Admin.
/// Reads from `--dart-define` / `--dart-define-from-file=.env`,
/// with fallback to [dotenv] if `.env` is loaded.
abstract final class EnvConfig {
  static Future<void> init() async {
    try {
      await dotenv.load();
    } catch (_) {
      // .env asset not present or running via --dart-define-from-file
    }
  }

  static String get supabaseUrl {
    const fromDefine = String.fromEnvironment('SUPABASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;

    if (dotenv.isInitialized) {
      final fromEnv = dotenv.env['SUPABASE_URL'];
      if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    }
    return '';
  }

  static String get supabaseAnonKey {
    const fromDefine = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;

    if (dotenv.isInitialized) {
      final fromEnv = dotenv.env['SUPABASE_ANON_KEY'];
      if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    }
    return '';
  }

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
