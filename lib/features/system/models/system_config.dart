class SystemConfig {
  const SystemConfig({
    this.forceUpdate = false,
    this.minRequiredVersion = '2.0.0',
    this.latestVersion = '2.1.2',
    this.updateUrl = 'https://versobibletracker.netlify.app/#download',
    this.maintenanceMode = false,
    this.maintenanceMessage =
        'Verso is undergoing scheduled maintenance. Please check back shortly.',
    this.verseOverrideEnabled = false,
    this.verseOverrideReference = 'Psalm 23:1',
    this.verseOverrideText =
        'The LORD is my shepherd; I shall not want.',
    this.verseOverrideMalayalamPoc =
        'കർത്താവാണ് എൻ്റെ ഇടയൻ; എനിക്കൊന്നിനും കുറവുണ്ടാവുകയില്ല.',
    this.verseOverrideMalayalamBsi =
        'യഹോവ എന്റെ ഇടയനാകുന്നു; എനിക്കു മുട്ടുണ്ടാകയില്ല.',
    this.updatedAt,
  });

  factory SystemConfig.fromJson(Map<String, dynamic> json) {
    return SystemConfig(
      forceUpdate: json['force_update'] as bool? ?? false,
      minRequiredVersion:
          json['min_required_version'] as String? ?? '2.0.0',
      latestVersion: json['latest_version'] as String? ?? '2.1.2',
      updateUrl: json['update_url'] as String? ??
          'https://versobibletracker.netlify.app/#download',
      maintenanceMode: json['maintenance_mode'] as bool? ?? false,
      maintenanceMessage: json['maintenance_message'] as String? ??
          'Verso is undergoing scheduled maintenance. Please check back shortly.',
      verseOverrideEnabled:
          json['verse_override_enabled'] as bool? ?? false,
      verseOverrideReference:
          json['verse_override_reference'] as String? ?? 'Psalm 23:1',
      verseOverrideText: json['verse_override_text'] as String? ??
          'The LORD is my shepherd; I shall not want.',
      verseOverrideMalayalamPoc:
          json['verse_override_ml_poc'] as String? ??
              'കർത്താവാണ് എൻ്റെ ഇടയൻ; എനിക്കൊന്നിനും കുറവുണ്ടാവുകയില്ല.',
      verseOverrideMalayalamBsi:
          json['verse_override_ml_bsi'] as String? ??
              'യഹോവ എന്റെ ഇടയനാകുന്നു; എനിക്കു മുട്ടുണ്ടാകയില്ല.',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  final bool forceUpdate;
  final String minRequiredVersion;
  final String latestVersion;
  final String updateUrl;
  final bool maintenanceMode;
  final String maintenanceMessage;
  final bool verseOverrideEnabled;
  final String verseOverrideReference;
  final String verseOverrideText;
  final String verseOverrideMalayalamPoc;
  final String verseOverrideMalayalamBsi;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'force_update': forceUpdate,
      'min_required_version': minRequiredVersion,
      'latest_version': latestVersion,
      'update_url': updateUrl,
      'maintenance_mode': maintenanceMode,
      'maintenance_message': maintenanceMessage,
      'verse_override_enabled': verseOverrideEnabled,
      'verse_override_reference': verseOverrideReference,
      'verse_override_text': verseOverrideText,
      'verse_override_ml_poc': verseOverrideMalayalamPoc,
      'verse_override_ml_bsi': verseOverrideMalayalamBsi,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  SystemConfig copyWith({
    bool? forceUpdate,
    String? minRequiredVersion,
    String? latestVersion,
    String? updateUrl,
    bool? maintenanceMode,
    String? maintenanceMessage,
    bool? verseOverrideEnabled,
    String? verseOverrideReference,
    String? verseOverrideText,
    String? verseOverrideMalayalamPoc,
    String? verseOverrideMalayalamBsi,
    DateTime? updatedAt,
  }) {
    return SystemConfig(
      forceUpdate: forceUpdate ?? this.forceUpdate,
      minRequiredVersion: minRequiredVersion ?? this.minRequiredVersion,
      latestVersion: latestVersion ?? this.latestVersion,
      updateUrl: updateUrl ?? this.updateUrl,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
      verseOverrideEnabled: verseOverrideEnabled ?? this.verseOverrideEnabled,
      verseOverrideReference:
          verseOverrideReference ?? this.verseOverrideReference,
      verseOverrideText: verseOverrideText ?? this.verseOverrideText,
      verseOverrideMalayalamPoc:
          verseOverrideMalayalamPoc ?? this.verseOverrideMalayalamPoc,
      verseOverrideMalayalamBsi:
          verseOverrideMalayalamBsi ?? this.verseOverrideMalayalamBsi,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
