import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:verso_admin/core/design/design.dart';
import 'package:verso_admin/core/widgets/error_state_widget.dart';
import 'package:verso_admin/features/system/models/system_config.dart';
import 'package:verso_admin/features/system/providers/system_provider.dart';

class SystemScreen extends ConsumerStatefulWidget {
  const SystemScreen({super.key});

  @override
  ConsumerState<SystemScreen> createState() => _SystemScreenState();
}

class _SystemScreenState extends ConsumerState<SystemScreen> {
  final _minVersionController = TextEditingController();
  final _latestVersionController = TextEditingController();
  final _downloadUrlController = TextEditingController();
  final _maintenanceMsgController = TextEditingController();
  final _verseRefController = TextEditingController();
  final _verseTextController = TextEditingController();
  final _versePocController = TextEditingController();
  final _verseBsiController = TextEditingController();

  bool _hasInitialized = false;

  @override
  void dispose() {
    _minVersionController.dispose();
    _latestVersionController.dispose();
    _downloadUrlController.dispose();
    _maintenanceMsgController.dispose();
    _verseRefController.dispose();
    _verseTextController.dispose();
    _versePocController.dispose();
    _verseBsiController.dispose();
    super.dispose();
  }

  void _populateControllers(SystemConfig config) {
    if (_hasInitialized) return;
    _minVersionController.text = config.minRequiredVersion;
    _latestVersionController.text = config.latestVersion;
    _downloadUrlController.text = config.updateUrl;
    _maintenanceMsgController.text = config.maintenanceMessage;
    _verseRefController.text = config.verseOverrideReference;
    _verseTextController.text = config.verseOverrideText;
    _versePocController.text = config.verseOverrideMalayalamPoc;
    _verseBsiController.text = config.verseOverrideMalayalamBsi;
    _hasInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(systemConfigProvider);
    final textTheme = context.textTheme;
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Control & Updates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload Config',
            onPressed: () {
              _hasInitialized = false;
              ref.read(systemConfigProvider.notifier).reload();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: ErrorStateWidget(
            error: error,
            onRetry: () {
              _hasInitialized = false;
              ref.read(systemConfigProvider.notifier).reload();
            },
          ),
        ),
        data: (config) {
          _populateControllers(config);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Maintenance Mode Alert Banner if active
                if (config.maintenanceMode) ...[
                  VersoCard(
                    color: palette.accent.withValues(alpha: 0.15),
                    border: Border.all(color: palette.accent),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: palette.accent,
                          size: 32,
                        ),
                        const Gap(Spacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MAINTENANCE MODE ACTIVE',
                                style: textTheme.labelLarge?.copyWith(
                                  color: palette.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(2),
                              Text(
                                'All main Verso app clients are blocked with maintenance banner.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: palette.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(Spacing.md),
                ],

                // Section 2: App Version & Force Update
                const VersoSectionHeader(
                  title: 'App Update Policies',
                ),
                const Gap(4),
                Text(
                  'Control client force-updates, minimum build thresholds, and download URLs.',
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                  ),
                ),
                const Gap(Spacing.sm),
                VersoCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Enforce Mandatory Update',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'If enabled, users below minimum required version cannot dismiss the update dialog.',
                          style: textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                          ),
                        ),
                        value: config.forceUpdate,
                        activeThumbColor: palette.accent,
                        onChanged: (val) async {
                          final success = await ref
                              .read(systemConfigProvider.notifier)
                              .toggleForceUpdate(val);
                          if (context.mounted) {
                            if (success) {
                              VersoSnackbar.success(
                                context,
                                message: 'Force update policy updated to $val',
                              );
                            } else {
                              VersoSnackbar.error(
                                context,
                                message: 'Failed to update policy',
                              );
                            }
                          }
                        },
                      ),
                      const Divider(height: Spacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: VersoTextField(
                              label: 'Min Required Version',
                              controller: _minVersionController,
                              hintText: 'e.g. 2.0.0',
                            ),
                          ),
                          const Gap(Spacing.sm),
                          Expanded(
                            child: VersoTextField(
                              label: 'Latest Release Version',
                              controller: _latestVersionController,
                              hintText: 'e.g. 2.1.2',
                            ),
                          ),
                        ],
                      ),
                      const Gap(Spacing.sm),
                      VersoTextField(
                        label: 'Download / Release URL',
                        controller: _downloadUrlController,
                        hintText:
                            'https://versobibletracker.netlify.app/#download',
                      ),
                      const Gap(Spacing.md),
                      Align(
                        alignment: Alignment.centerRight,
                        child: VersoButton(
                          label: 'Save Version Settings',
                          icon: Icons.save_rounded,
                          onPressed: () async {
                            final success = await ref
                                .read(systemConfigProvider.notifier)
                                .updateVersions(
                                  minVersion:
                                      _minVersionController.text.trim(),
                                  latestVersion:
                                      _latestVersionController.text.trim(),
                                  updateUrl:
                                      _downloadUrlController.text.trim(),
                                );
                            if (context.mounted) {
                              if (success) {
                                VersoSnackbar.success(
                                  context,
                                  message:
                                      'Version policies saved successfully',
                                );
                              } else {
                                VersoSnackbar.error(
                                  context,
                                  message: 'Failed to save version policies',
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(Spacing.lg),

                // Section 3: Maintenance Control
                const VersoSectionHeader(
                  title: 'Maintenance Controls',
                ),
                const Gap(4),
                Text(
                  'Lock client access during database migrations or infrastructure maintenance.',
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                  ),
                ),
                const Gap(Spacing.sm),
                VersoCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Maintenance Mode',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Instructs clients to display a maintenance screen and halt requests.',
                          style: textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                          ),
                        ),
                        value: config.maintenanceMode,
                        activeThumbColor: palette.accent,
                        onChanged: (val) async {
                          final success = await ref
                              .read(systemConfigProvider.notifier)
                              .toggleMaintenanceMode(val);
                          if (context.mounted) {
                            if (success) {
                              VersoSnackbar.success(
                                context,
                                message:
                                    'Maintenance mode toggled to $val',
                              );
                            } else {
                              VersoSnackbar.error(
                                context,
                                message: 'Failed to update maintenance mode',
                              );
                            }
                          }
                        },
                      ),
                      const Divider(height: Spacing.lg),
                      VersoTextField(
                        label: 'Maintenance Notice to Users',
                        controller: _maintenanceMsgController,
                        maxLines: 3,
                        hintText:
                            'Verso is undergoing scheduled maintenance. Please check back shortly.',
                      ),
                      const Gap(Spacing.md),
                      Align(
                        alignment: Alignment.centerRight,
                        child: VersoButton(
                          label: 'Update Maintenance Message',
                          icon: Icons.message_rounded,
                          variant: VersoButtonVariant.secondary,
                          onPressed: () async {
                            final current = config.copyWith(
                              maintenanceMessage:
                                  _maintenanceMsgController.text.trim(),
                            );
                            final success = await ref
                                .read(systemConfigProvider.notifier)
                                .saveConfig(current);
                            if (context.mounted) {
                              if (success) {
                                VersoSnackbar.success(
                                  context,
                                  message: 'Maintenance message updated',
                                );
                              } else {
                                VersoSnackbar.error(
                                  context,
                                  message:
                                      'Failed to update maintenance message',
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(Spacing.lg),

                // Section 4: Daily Verse Remote Override
                const VersoSectionHeader(
                  title: 'Daily Verse Remote Override',
                ),
                const Gap(4),
                Text(
                  'Push an immediate daily verse to all devices, overriding the standard day-of-year schedule.',
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                  ),
                ),
                const Gap(Spacing.sm),
                VersoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Enable Verse Override',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'When turned ON, the app presents this curated verse instead of the routine sequence.',
                          style: textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                          ),
                        ),
                        value: config.verseOverrideEnabled,
                        activeThumbColor: palette.primary,
                        onChanged: (val) async {
                          final success = await ref
                              .read(systemConfigProvider.notifier)
                              .toggleVerseOverride(val);
                          if (context.mounted) {
                            if (success) {
                              VersoSnackbar.success(
                                context,
                                message: 'Verse override toggled to $val',
                              );
                            } else {
                              VersoSnackbar.error(
                                context,
                                message: 'Failed to update verse override',
                              );
                            }
                          }
                        },
                      ),
                      const Divider(height: Spacing.lg),
                      VersoTextField(
                        label: 'Scripture Reference',
                        controller: _verseRefController,
                        hintText: 'e.g. John 3:16 or Psalm 23:1',
                      ),
                      const Gap(Spacing.sm),
                      VersoTextField(
                        label: 'English Text (ESV / NIV)',
                        controller: _verseTextController,
                        maxLines: 2,
                        hintText: 'For God so loved the world...',
                      ),
                      const Gap(Spacing.sm),
                      VersoTextField(
                        label: 'Malayalam POC Text (പി.ഒ.സി.)',
                        controller: _versePocController,
                        maxLines: 2,
                        hintText: 'എന്തെന്നാല്‍, ദൈവത്തിനു ലോകത്തോട്...',
                      ),
                      const Gap(Spacing.sm),
                      VersoTextField(
                        label: 'Malayalam BSI Text (ബി.എസ്.ഐ.)',
                        controller: _verseBsiController,
                        maxLines: 2,
                        hintText: 'തന്റെ ഏകജാതനായ പുത്രനിൽ വിശ്വസിക്കുന്ന...',
                      ),
                      const Gap(Spacing.md),
                      Align(
                        alignment: Alignment.centerRight,
                        child: VersoButton(
                          label: 'Publish Verse Override',
                          icon: Icons.publish_rounded,
                          onPressed: () async {
                            final success = await ref
                                .read(systemConfigProvider.notifier)
                                .updateVerseOverride(
                                  reference:
                                      _verseRefController.text.trim(),
                                  text: _verseTextController.text.trim(),
                                  mlPoc: _versePocController.text.trim(),
                                  mlBsi: _verseBsiController.text.trim(),
                                );
                            if (context.mounted) {
                              if (success) {
                                VersoSnackbar.success(
                                  context,
                                  message:
                                      'Daily verse override published!',
                                );
                              } else {
                                VersoSnackbar.error(
                                  context,
                                  message:
                                      'Failed to publish verse override',
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(Spacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }
}
