import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webapp_template/core/config/app_config.dart';
import 'package:webapp_template/features/connection/providers/connection_providers.dart';
import 'package:webapp_template/features/settings/providers/settings_providers.dart';
import 'package:webapp_template/services/webview/webview_coordinator.dart';
import 'package:webapp_template/services/webview/webview_host.dart';

class BootstrapScreen extends ConsumerStatefulWidget {
  const BootstrapScreen({super.key});

  @override
  ConsumerState<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends ConsumerState<BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await ref.read(sharedPreferencesProvider.future);
    await ref.read(connectionsProvider.future);

    final settings = await ref.read(settingsProvider.future);
    if (!settings.autoReconnectOnLaunch) {
      _goHub();
      return;
    }

    final lastUsed =
        await ref.read(connectionsProvider.notifier).loadLastUsedFromStore();
    if (lastUsed == null) {
      _goHub();
      return;
    }

    final error = await ref
        .read(webViewCoordinatorProvider.notifier)
        .connect(lastUsed);

    if (!mounted) {
      return;
    }

    if (error != null) {
      _goHub();
      return;
    }

    final session = ref.read(webViewCoordinatorProvider);
    if (session == null) {
      _goHub();
      return;
    }

    if (session.presentation == WebViewPresentation.inline) {
      context.go(
        '/webview/${session.connection.id}',
        extra: session.connection,
      );
    } else {
      context.go(
        '/session/${session.connection.id}',
        extra: session.connection,
      );
    }
  }

  void _goHub() {
    if (mounted) {
      context.go('/hub');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
