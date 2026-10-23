import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verso_admin/core/supabase/supabase_provider.dart';
import 'package:verso_admin/features/alerts/data/alerts_repository.dart';
import 'package:verso_admin/features/alerts/models/live_alert.dart';

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final repo = AlertsRepository(client: client);
  ref.onDispose(repo.dispose);
  return repo;
});

final alertFilterProvider = StateProvider<AlertType?>((ref) => null);

final liveAlertsProvider =
    StateNotifierProvider<LiveAlertsNotifier, AsyncValue<List<LiveAlert>>>((ref) {
  final repo = ref.watch(alertsRepositoryProvider);
  return LiveAlertsNotifier(repo);
});

class LiveAlertsNotifier extends StateNotifier<AsyncValue<List<LiveAlert>>> {
  LiveAlertsNotifier(this._repo) : super(const AsyncValue.loading()) {
    _init();
  }

  final AlertsRepository _repo;
  StreamSubscription<LiveAlert>? _subscription;

  Future<void> _init() async {
    try {
      final initialAlerts = await _repo.fetchRecentAlerts();
      state = AsyncValue.data(initialAlerts);

      _subscription = _repo.subscribeToLiveAlerts().listen(
        (newAlert) {
          final current = state.value ?? [];
          state = AsyncValue.data([newAlert, ...current]);
        },
        onError: (err, st) {
          // Keep current state on transient stream error
        },
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clearAlerts() {
    state = const AsyncValue.data([]);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final alerts = await _repo.fetchRecentAlerts();
      state = AsyncValue.data(alerts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
