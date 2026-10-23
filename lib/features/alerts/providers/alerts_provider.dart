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

class AlertFilterNotifier extends Notifier<AlertType?> {
  @override
  AlertType? build() => null;

  @override
  set state(AlertType? value) => super.state = value;
}

final alertFilterProvider =
    NotifierProvider<AlertFilterNotifier, AlertType?>(AlertFilterNotifier.new);

class LiveAlertsNotifier extends AsyncNotifier<List<LiveAlert>> {
  StreamSubscription<LiveAlert>? _subscription;

  @override
  FutureOr<List<LiveAlert>> build() async {
    final repo = ref.watch(alertsRepositoryProvider);
    _subscription?.cancel();
    _subscription = repo.subscribeToLiveAlerts().listen(
      (newAlert) {
        final current = state.value ?? [];
        state = AsyncValue.data([newAlert, ...current]);
      },
    );
    ref.onDispose(() => _subscription?.cancel());

    return repo.fetchRecentAlerts();
  }

  void clearAlerts() {
    state = const AsyncValue.data([]);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(alertsRepositoryProvider);
      return repo.fetchRecentAlerts();
    });
  }
}

final liveAlertsProvider =
    AsyncNotifierProvider<LiveAlertsNotifier, List<LiveAlert>>(
  LiveAlertsNotifier.new,
);
