import 'dart:async';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:webapp_template/features/connection/models/saved_connection.dart';
import 'package:webapp_template/services/webview/webview_host.dart';

class MacOSWebViewHost implements WebViewHost {
  MacOSWebViewHost();

  Webview? _window;
  final _closedController = StreamController<void>.broadcast();

  @override
  WebViewPresentation get presentation => WebViewPresentation.externalWindow;

  @override
  Future<String?> availabilityError() async {
    final available = await WebviewWindow.isWebviewAvailable();
    if (!available) {
      return 'A system WebView is not available on this Mac.';
    }
    return null;
  }

  @override
  Future<void> open(SavedConnection connection) async {
    await close();

    final window = await WebviewWindow.create(
      configuration: CreateConfiguration(
        windowWidth: 1280,
        windowHeight: 800,
        title: connection.displayName,
        titleBarTopPadding: 0,
      ),
    );

    _window = window;
    window.launch(connection.url);

    window.onClose.whenComplete(() {
      _window = null;
      if (!_closedController.isClosed) {
        _closedController.add(null);
      }
    });
  }

  @override
  Future<void> close() async {
    final window = _window;
    _window = null;
    window?.close();
  }

  @override
  Stream<void> get onClosed => _closedController.stream;
}
