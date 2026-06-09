import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webapp_template/core/config/app_config.dart';
import 'package:webapp_template/features/connection/models/saved_connection.dart';
import 'package:webapp_template/services/webview/webview_coordinator.dart';

class WebViewScreen extends ConsumerStatefulWidget {
  const WebViewScreen({super.key, required this.connection});

  final SavedConnection connection;

  @override
  ConsumerState<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends ConsumerState<WebViewScreen> {
  late final WebViewController _controller;
  var _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('${_defaultUserAgent()} ${AppConfig.defaultUserAgentSuffix}')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _errorMessage = error.description;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.connection.url));
  }

  String _defaultUserAgent() {
    return 'Mozilla/5.0 (compatible; WebAppTemplate)';
  }

  Future<void> _disconnect() async {
    await ref.read(webViewCoordinatorProvider.notifier).disconnect();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _disconnect();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.connection.displayName),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Disconnect',
            onPressed: _disconnect,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload',
              onPressed: () => _controller.reload(),
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const LinearProgressIndicator(minHeight: 2),
            if (_errorMessage != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: MaterialBanner(
                  content: Text('Failed to load page: $_errorMessage'),
                  actions: [
                    TextButton(
                      onPressed: () => _controller.reload(),
                      child: const Text('Retry'),
                    ),
                    TextButton(
                      onPressed: _disconnect,
                      child: const Text('Disconnect'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
