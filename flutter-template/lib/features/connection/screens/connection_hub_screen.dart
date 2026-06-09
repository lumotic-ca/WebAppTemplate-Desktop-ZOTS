import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webapp_template/core/config/app_config.dart';
import 'package:webapp_template/core/widgets/connection_card.dart';
import 'package:webapp_template/core/widgets/empty_state.dart';
import 'package:webapp_template/features/connection/providers/connection_providers.dart';
import 'package:webapp_template/services/webview/webview_coordinator.dart';
import 'package:webapp_template/services/webview/webview_host.dart';

class ConnectionHubScreen extends ConsumerStatefulWidget {
  const ConnectionHubScreen({super.key});

  @override
  ConsumerState<ConnectionHubScreen> createState() =>
      _ConnectionHubScreenState();
}

class _ConnectionHubScreenState extends ConsumerState<ConnectionHubScreen> {
  String? _connectError;
  String? _connectingId;

  Future<void> _connect(String connectionId) async {
    final connections = ref.read(connectionsProvider).value ?? [];
    final connection = connections.firstWhere((item) => item.id == connectionId);

    setState(() {
      _connectError = null;
      _connectingId = connectionId;
    });

    final error = await ref
        .read(webViewCoordinatorProvider.notifier)
        .connect(connection);

    if (!mounted) {
      return;
    }

    setState(() => _connectingId = null);

    if (error != null) {
      setState(() => _connectError = error);
      return;
    }

    final session = ref.read(webViewCoordinatorProvider);
    if (session == null) {
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

  Future<void> _confirmDelete(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete server?'),
        content: Text('Remove "$name" from saved servers?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(connectionsProvider.notifier).deleteConnection(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionsAsync = ref.watch(connectionsProvider);
    final lastUsedId = connectionsAsync.maybeWhen(
      data: (connections) =>
          connections.isNotEmpty ? connections.first.id : null,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConfig.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add server'),
      ),
      body: connectionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load servers',
          message: error.toString(),
          actionLabel: 'Retry',
          onAction: () =>
              ref.read(connectionsProvider.notifier).refresh(),
        ),
        data: (connections) {
          if (connections.isEmpty) {
            return EmptyState(
              icon: Icons.dns_outlined,
              title: 'No servers yet',
              message:
                  'Add the web app URL you want to connect to. '
                  'Your choice will be remembered next time.',
              actionLabel: 'Add server',
              onAction: () => context.push('/add'),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final list = ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 48 : 16,
                  16,
                  isWide ? 48 : 16,
                  96,
                ),
                itemCount: connections.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final connection = connections[index];
                  final isConnecting = _connectingId == connection.id;

                  return ConnectionCard(
                    connection: connection,
                    isLastUsed: connection.id == lastUsedId,
                    onConnect: isConnecting
                        ? () {}
                        : () => _connect(connection.id),
                    onEdit: () => context.push(
                      '/add',
                      extra: connection,
                    ),
                    onDelete: () => _confirmDelete(
                      connection.id,
                      connection.displayName,
                    ),
                  );
                },
              );

              return Column(
                children: [
                  if (_connectError != null)
                    MaterialBanner(
                      content: Text(_connectError!),
                      leading: const Icon(Icons.warning_amber_outlined),
                      actions: [
                        TextButton(
                          onPressed: () => setState(() => _connectError = null),
                          child: const Text('Dismiss'),
                        ),
                      ],
                    ),
                  if (_connectingId != null)
                    const LinearProgressIndicator(minHeight: 2),
                  Expanded(child: list),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
