import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verso_admin/features/system/data/system_repository.dart';
import 'package:verso_admin/features/system/models/system_config.dart';

final systemRepositoryProvider = Provider<SystemRepository>((ref) {
  return SystemRepository();
});

class SystemConfigNotifier extends StateNotifier<AsyncValue<SystemConfig>> {
  SystemConfigNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadConfig();
  }

  final SystemRepository _repository;

  Future<void> loadConfig() async {
    state = const AsyncValue.loading();
    try {
      final config = await _repository.fetchConfig();
      state = AsyncValue.data(config);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> saveConfig(SystemConfig config) async {
    try {
      await _repository.saveConfig(config);
      state = AsyncValue.data(config);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> toggleForceUpdate(bool value) async {
    final current = state.valueOrNull ?? const SystemConfig();
    final updated = current.copyWith(forceUpdate: value);
    return saveConfig(updated);
  }

  Future<bool> toggleMaintenanceMode(bool value) async {
    final current = state.valueOrNull ?? const SystemConfig();
    final updated = current.copyWith(maintenanceMode: value);
    return saveConfig(updated);
  }

  Future<bool> toggleVerseOverride(bool value) async {
    final current = state.valueOrNull ?? const SystemConfig();
    final updated = current.copyWith(verseOverrideEnabled: value);
    return saveConfig(updated);
  }

  Future<bool> updateVersions({
    required String minVersion,
    required String latestVersion,
    required String updateUrl,
  }) async {
    final current = state.valueOrNull ?? const SystemConfig();
    final updated = current.copyWith(
      minRequiredVersion: minVersion,
      latestVersion: latestVersion,
      updateUrl: updateUrl,
    );
    return saveConfig(updated);
  }

  Future<bool> updateVerseOverride({
    required String reference,
    required String text,
    String? mlPoc,
    String? mlBsi,
    bool? isEnabled,
  }) async {
    final current = state.valueOrNull ?? const SystemConfig();
    final updated = current.copyWith(
      verseOverrideReference: reference,
      verseOverrideText: text,
      verseOverrideMalayalamPoc: mlPoc ?? current.verseOverrideMalayalamPoc,
      verseOverrideMalayalamBsi: mlBsi ?? current.verseOverrideMalayalamBsi,
      verseOverrideEnabled: isEnabled ?? current.verseOverrideEnabled,
    );
    return saveConfig(updated);
  }
}

final systemConfigProvider =
    StateNotifierProvider<SystemConfigNotifier, AsyncValue<SystemConfig>>((ref) {
  final repo = ref.watch(systemRepositoryProvider);
  return SystemConfigNotifier(repo);
});
