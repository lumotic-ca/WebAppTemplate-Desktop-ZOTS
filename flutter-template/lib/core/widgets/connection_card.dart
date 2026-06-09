import 'package:flutter/material.dart';
import 'package:webapp_template/core/utils/url_validator.dart';
import 'package:webapp_template/features/connection/models/saved_connection.dart';

class ConnectionCard extends StatelessWidget {
  const ConnectionCard({
    super.key,
    required this.connection,
    required this.onConnect,
    this.onEdit,
    this.onDelete,
    this.isLastUsed = false,
  });

  final SavedConnection connection;
  final VoidCallback onConnect;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isLastUsed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onConnect,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: Text(
                  connection.displayName.characters.first.toUpperCase(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            connection.displayName,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (isLastUsed)
                          Chip(
                            label: const Text('Last used'),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      UrlValidator.displayHost(connection.url),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                      case 'delete':
                        onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                  ],
                ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onConnect,
                child: const Text('Connect'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
