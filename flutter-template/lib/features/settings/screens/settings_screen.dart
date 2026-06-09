import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webapp_template/core/widgets/settings_section.dart';
import 'package:webapp_template/features/connection/providers/connection_providers.dart';
import 'package:webapp_template/features/settings/providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmClearConnections(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear saved servers?'),
        content: const Text(
          'This removes all saved connections. You will need to add a server again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(connectionsProvider.notifier).clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved servers cleared.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              SettingsSection(
                title: 'Appearance',
                children: [
                  ListTile(
                    title: const Text('Theme'),
                    subtitle: Text(_themeLabel(settings.themeMode)),
                    trailing: DropdownButton<ThemeMode>(
                      value: settings.themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(settingsProvider.notifier)
                              .setThemeMode(value);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('System'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SettingsSection(
                title: 'Connection behavior',
                subtitle: 'Control how the app reconnects on launch.',
                children: [
                  SwitchListTile(
                    title: const Text('Reconnect on launch'),
                    subtitle: const Text(
                      'Automatically open the last used server when the app starts.',
                    ),
                    value: settings.autoReconnectOnLaunch,
                    onChanged: (value) => ref
                        .read(settingsProvider.notifier)
                        .setAutoReconnect(value),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SettingsSection(
                title: 'Data',
                children: [
                  ListTile(
                    title: const Text('Clear saved servers'),
                    subtitle: const Text('Remove all saved connections'),
                    trailing: const Icon(Icons.delete_outline),
                    onTap: () => _confirmClearConnections(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SettingsSection(
                title: 'App-specific settings',
                subtitle:
                    'Forks can add custom settings widgets below this section.',
                children: [
                  ListTile(
                    title: const Text('No app-specific settings yet'),
                    subtitle: const Text(
                      'See docs/FORKING.md to extend this section.',
                    ),
                    enabled: false,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}
