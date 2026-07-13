import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_tile.dart';

/// Settings screen — tab 4 in the bottom navigation.
///
/// Provides access to backup/restore, data export, theme toggle,
/// language, PIN, and biometric lock settings.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text('Settings', style: theme.textTheme.headlineMedium),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.horizontalPadding,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // ─── Data ──────────────────────────────────
                _SectionLabel('Data'),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      SettingsTile(
                        icon: Icons.backup_rounded,
                        title: 'Backup Data',
                        subtitle: 'Export all data as JSON',
                        onTap: () => _backup(context),
                      ),
                      Divider(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        indent: 70,
                      ),
                      SettingsTile(
                        icon: Icons.restore_rounded,
                        title: 'Restore Data',
                        subtitle: 'Import from a backup file',
                        onTap: () => _restore(context),
                      ),
                      Divider(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        indent: 70,
                      ),
                      SettingsTile(
                        icon: Icons.picture_as_pdf_rounded,
                        title: 'Export Report',
                        subtitle: 'Generate PDF report',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Appearance ────────────────────────────
                _SectionLabel('Appearance'),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      SettingsTile(
                        icon: Icons.dark_mode_rounded,
                        title: 'Dark Mode',
                        subtitle: _themeModeLabel(themeMode),
                        trailing: SegmentedButton<ThemeMode>(
                          style: SegmentedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            textStyle: const TextStyle(fontSize: 11),
                          ),
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: Icon(Icons.brightness_auto, size: 16),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode_rounded, size: 16),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode_rounded, size: 16),
                            ),
                          ],
                          selected: {themeMode},
                          onSelectionChanged: (selected) {
                            ref.read(themeModeProvider.notifier).state =
                                selected.first;
                          },
                        ),
                      ),
                      Divider(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        indent: 70,
                      ),
                      SettingsTile(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        subtitle: 'English',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Additional languages coming soon'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Security ──────────────────────────────
                _SectionLabel('Security'),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      SettingsTile(
                        icon: Icons.pin_rounded,
                        title: 'Change PIN',
                        subtitle: 'Set or update app PIN',
                        onTap: () => _changePinDialog(context),
                      ),
                      Divider(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        indent: 70,
                      ),
                      SettingsTile(
                        icon: Icons.fingerprint_rounded,
                        title: 'Biometric Lock',
                        subtitle: 'Use fingerprint to unlock',
                        trailing: Switch(
                          value: false,
                          onChanged: (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Biometric lock will be available after setup'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Danger Zone ───────────────────────────
                _SectionLabel('Danger Zone'),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.moneyOut.withValues(alpha: 0.15),
                    ),
                  ),
                  child: SettingsTile(
                    icon: Icons.delete_forever_rounded,
                    iconColor: AppColors.moneyOut,
                    title: 'Clear All Data',
                    subtitle: 'Permanently delete everything',
                    onTap: () => _clearData(context, ref),
                  ),
                ),

                const SizedBox(height: 32),

                // App info
                Center(
                  child: Column(
                    children: [
                      Text(
                        AppConstants.appName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Version ${AppConstants.appVersion}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Made with ❤️ for money lenders',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Always light';
      case ThemeMode.dark:
        return 'Always dark';
    }
  }

  void _backup(BuildContext context) async {
    try {
      await BackupService.shareBackup();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    }
  }

  void _restore(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Select a backup file to restore from'),
      ),
    );
  }

  void _changePinDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PIN setup will open a secure dialog'),
      ),
    );
  }

  void _clearData(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Clear All Data?',
      description:
          'This will permanently delete ALL customers, loans, and payments. This cannot be undone. Consider backing up first.',
      confirmLabel: 'Clear Everything',
      icon: Icons.delete_forever_rounded,
    );

    if (confirmed && context.mounted) {
      await StorageService.clearAllData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data cleared')),
      );
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
