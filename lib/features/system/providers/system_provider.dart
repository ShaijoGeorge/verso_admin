import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verso_admin/features/system/data/system_repository.dart';
import 'package:verso_admin/features/system/models/system_config.dart';

final systemRepositoryProvider = Provider<SystemRepository>((ref) {
  return SystemRepository();
});

class SystemConfigNotifier extends AsyncNotifier<SystemConfig> {
  @override
  FutureOr<SystemConfig> build() async {
    final repo = ref.watch(systemRepositoryProvider);
    return repo.fetchConfig();
  }

  Future<bool> saveConfig(SystemConfig config) async {
    final previousConfig = state.value;
    try {
      final repo = ref.read(systemRepositoryProvider);
      await repo.saveConfig(config);
      state = AsyncValue.data(config);
      return true;
    } catch (e, st) {
      if (previousConfig != null) {
        state = AsyncValue.data(previousConfig);
      } else {
        state = AsyncValue.error(e, st);
      }
      return false;
    }
  }

  Future<bool> toggleForceUpdate(bool value) async {
    final current = state.value ?? const SystemConfig();
    return saveConfig(current.copyWith(forceUpdate: value));
  }

  Future<bool> toggleMaintenanceMode(bool value) async {
    final current = state.value ?? const SystemConfig();
    return saveConfig(current.copyWith(maintenanceMode: value));
  }

  Future<bool> toggleVerseOverride(bool value) async {
    final current = state.value ?? const SystemConfig();
    return saveConfig(current.copyWith(verseOverrideEnabled: value));
  }

  Future<bool> updateVersions({
    required String minVersion,
    required String latestVersion,
    required String updateUrl,
  }) async {
    final current = state.value ?? const SystemConfig();
    return saveConfig(
      current.copyWith(
        minRequiredVersion: minVersion,
        latestVersion: latestVersion,
        updateUrl: updateUrl,
      ),
    );
  }

  Future<bool> updateVerseOverride({
    required String reference,
    required String text,
    String? mlPoc,
    String? mlBsi,
    bool? isEnabled,
  }) async {
    final current = state.value ?? const SystemConfig();
    return saveConfig(
      current.copyWith(
        verseOverrideReference: reference,
        verseOverrideText: text,
        verseOverrideMalayalamPoc: mlPoc ?? current.verseOverrideMalayalamPoc,
        verseOverrideMalayalamBsi: mlBsi ?? current.verseOverrideMalayalamBsi,
        verseOverrideEnabled: isEnabled ?? current.verseOverrideEnabled,
      ),
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(systemRepositoryProvider);
      return repo.fetchConfig();
    });
  }
}

final systemConfigProvider =
    AsyncNotifierProvider<SystemConfigNotifier, SystemConfig>(
  SystemConfigNotifier.new,
);
