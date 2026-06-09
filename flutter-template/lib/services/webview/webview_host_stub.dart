import 'dart:async';

import 'package:webapp_template/features/connection/models/saved_connection.dart';
import 'package:webapp_template/services/webview/webview_host.dart';

class StubWebViewHost implements WebViewHost {
  final _closedController = StreamController<void>.broadcast();

  @override
  WebViewPresentation get presentation => WebViewPresentation.inline;

  @override
  Future<String?> availabilityError() async {
    return 'WebView is not supported on this platform yet.';
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
