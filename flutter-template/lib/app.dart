import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webapp_template/core/config/app_config.dart';
import 'package:webapp_template/core/theme/app_theme.dart';
import 'package:webapp_template/features/connection/models/saved_connection.dart';
import 'package:webapp_template/features/connection/providers/connection_providers.dart';
import 'package:webapp_template/features/connection/screens/add_connection_screen.dart';
import 'package:webapp_template/features/connection/screens/connection_hub_screen.dart';
import 'package:webapp_template/features/settings/providers/settings_providers.dart';
import 'package:webapp_template/features/settings/screens/settings_screen.dart';
import 'package:webapp_template/features/shell/screens/bootstrap_screen.dart';
import 'package:webapp_template/features/webview/screens/session_screen.dart';
import 'package:webapp_template/features/webview/screens/webview_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

SavedConnection _connectionFromState(Ref ref, GoRouterState state) {
  final extra = state.extra;
  if (extra is SavedConnection) {
    return extra;
  }

  final active = ref.read(activeConnectionProvider);
  if (active != null && active.id == state.pathParameters['id']) {
    return active;
  }

  final connections = ref.read(connectionsProvider).value ?? [];
  final id = state.pathParameters['id'];
  return connections.firstWhere(
    (item) => item.id == id,
    orElse: () => throw StateError('Connection not found'),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const BootstrapScreen(),
      ),
      GoRoute(
        path: '/hub',
        builder: (context, state) => const ConnectionHubScreen(),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) {
          final existing = state.extra as SavedConnection?;
          return AddConnectionScreen(existing: existing);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/webview/:id',
        builder: (context, state) {
          final connection = _connectionFromState(ref, state);
          return WebViewScreen(connection: connection);
        },
      ),
      GoRoute(
        path: '/session/:id',
        builder: (context, state) {
          final connection = _connectionFromState(ref, state);
          return SessionScreen(connection: connection);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(state.error?.toString() ?? 'Unknown routing error'),
      ),
    ),
  );
});

class WebAppTemplate extends ConsumerWidget {
  const WebAppTemplate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    return settings.when(
      loading: () => MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => MaterialApp(
        title: AppConfig.appName,
        home: Scaffold(body: Center(child: Text(error.toString()))),
      ),
      data: (appSettings) => MaterialApp.router(
        title: AppConfig.appName,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: appSettings.themeMode,
        routerConfig: router,
      ),
    );
  }
}
