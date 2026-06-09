import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webapp_template/features/connection/models/saved_connection.dart';
import 'package:webapp_template/features/connection/providers/connection_providers.dart';
import 'package:webapp_template/services/webview/webview_host.dart';
import 'package:webapp_template/services/webview/webview_host_factory.dart';

class WebViewSession {
  const WebViewSession({
    required this.connection,
    required this.presentation,
  });

  final SavedConnection connection;
  final WebViewPresentation presentation;
}

class WebViewCoordinator extends Notifier<WebViewSession?> {
  WebViewHost? _host;
  StreamSubscription<void>? _closeSubscription;

  @override
  WebViewSession? build() {
    ref.onDispose(_disposeHost);
    return null;
  }

  WebViewHost get host => _host ??= createWebViewHost();

  Future<String?> connect(SavedConnection connection) async {
    final availabilityError = await host.availabilityError();
    if (availabilityError != null) {
      return availabilityError;
    }

    final updated = await ref
        .read(connectionsProvider.notifier)
        .markAsUsed(connection);

    await host.open(updated);
    _listenForClose();

    final session = WebViewSession(
      connection: updated,
      presentation: host.presentation,
    );
    state = session;
    ref.read(activeConnectionProvider.notifier).state = updated;
    return null;
  }

  Future<void> disconnect() async {
    await host.close();
    state = null;
    ref.read(activeConnectionProvider.notifier).state = null;
  }

  void _listenForClose() {
    _closeSubscription?.cancel();
    _closeSubscription = host.onClosed.listen((_) async {
      state = null;
      ref.read(activeConnectionProvider.notifier).state = null;
    });
  }

  void _disposeHost() {
    _closeSubscription?.cancel();
    _host?.close();
    _host = null;
  }
}

final webViewCoordinatorProvider =
    NotifierProvider<WebViewCoordinator, WebViewSession?>(WebViewCoordinator.new);
