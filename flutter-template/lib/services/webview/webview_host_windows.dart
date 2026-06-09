import 'dart:async';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:webapp_template/features/connection/models/saved_connection.dart';
import 'package:webapp_template/services/webview/webview_host.dart';

class WindowsWebViewHost implements WebViewHost {
  final _closedController = StreamController<void>.broadcast();

  @override
  WebViewPresentation get presentation => WebViewPresentation.inline;

  @override
  Future<String?> availabilityError() async {
    final available = await WebviewWindow.isWebviewAvailable();
    if (!available) {
      return 'Microsoft WebView2 Runtime is not installed. '
          'Install it from https://developer.microsoft.com/microsoft-edge/webview2/';
    }
    return null;
  }

  @override
  Future<void> open(SavedConnection connection) async {}

  @override
  Future<void> close() async {
    if (!_closedController.isClosed) {
      _closedController.add(null);
    }
  }

  @override
  Stream<void> get onClosed => _closedController.stream;
}
