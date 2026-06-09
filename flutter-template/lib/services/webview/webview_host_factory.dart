import 'dart:io' show Platform;

import 'package:webapp_template/services/webview/webview_host.dart';
import 'package:webapp_template/services/webview/webview_host_macos.dart';
import 'package:webapp_template/services/webview/webview_host_mobile.dart';
import 'package:webapp_template/services/webview/webview_host_stub.dart';
import 'package:webapp_template/services/webview/webview_host_windows.dart';

WebViewHost createWebViewHost() {
  if (Platform.isAndroid || Platform.isIOS) {
    return MobileWebViewHost();
  }
  if (Platform.isWindows) {
    return WindowsWebViewHost();
  }
  if (Platform.isMacOS) {
    return MacOSWebViewHost();
  }
  return StubWebViewHost();
}
