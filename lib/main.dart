import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso_admin/core/config/env_config.dart';
import 'package:verso_admin/core/design/design.dart';
import 'package:verso_admin/core/error/verso_error_observer.dart';
import 'package:verso_admin/core/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env if present
  await EnvConfig.init();

  // Initialize Supabase client
  if (EnvConfig.isConfigured) {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        eventsPerSecond: 10,
      ),
    );
  } else {
    // Fallback placeholder initialization to allow app boot without immediate crash
    await Supabase.initialize(
      url: 'https://placeholder.supabase.co',
      anonKey: 'placeholder-anon-key',
    );
  }

  runApp(
    const ProviderScope(
      observers: [
        VersoErrorObserver(null),
      ],
      child: VersoAdminApp(),
    ),
  );
}

class VersoAdminApp extends ConsumerWidget {
  const VersoAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Verso Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(currentProfile.light),
      darkTheme: AppTheme.build(currentProfile.dark),
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
