import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:webapp_template/core/utils/url_validator.dart';
import 'package:webapp_template/features/connection/models/saved_connection.dart';
import 'package:webapp_template/features/settings/providers/settings_providers.dart';
import 'package:webapp_template/services/persistence/connection_store.dart';

final connectionStoreProvider = FutureProvider<ConnectionStore>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return ConnectionStore(prefs);
});

class ConnectionsController extends AsyncNotifier<List<SavedConnection>> {
  @override
  Future<List<SavedConnection>> build() async {
    final store = await ref.watch(connectionStoreProvider.future);
    final connections = store.loadConnections();
    connections.sort((a, b) {
      final aTime = a.lastUsedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.lastUsedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return connections;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  SavedConnection? get lastUsed {
    final connections = state.value;
    if (connections == null || connections.isEmpty) {
      return null;
    }
    return connections.first;
  }

  Future<SavedConnection?> loadLastUsedFromStore() async {
    final store = await ref.read(connectionStoreProvider.future);
    final lastId = store.loadLastUsedId();
    if (lastId == null) {
      return null;
    }
    final connections = store.loadConnections();
    for (final connection in connections) {
      if (connection.id == lastId) {
        return connection;
      }
    }
    return null;
  }

  Future<SavedConnection> addConnection({
    required String displayName,
    required String url,
  }) async {
    final validation = UrlValidator.validate(url);
    if (!validation.isValid || validation.normalizedUrl == null) {
      throw StateError(validation.error ?? 'Invalid URL');
    }

    final store = await ref.read(connectionStoreProvider.future);
    final existing = store.loadConnections();
    final normalized = validation.normalizedUrl!;

    final duplicate = existing.any(
      (connection) => connection.url.toLowerCase() == normalized.toLowerCase(),
    );
    if (duplicate) {
      throw StateError('This server is already saved.');
    }

    final connection = SavedConnection(
      id: const Uuid().v4(),
      displayName: displayName.trim().isEmpty
          ? UrlValidator.displayHost(normalized)
          : displayName.trim(),
      url: normalized,
      lastUsedAt: DateTime.now(),
    );

    final updated = [...existing, connection];
    await store.saveConnections(updated);
    await store.saveLastUsedId(connection.id);
    await refresh();
    return connection;
  }

  Future<void> updateConnection(SavedConnection connection) async {
    final store = await ref.read(connectionStoreProvider.future);
    final existing = store.loadConnections();
    final updated = existing
        .map((item) => item.id == connection.id ? connection : item)
        .toList();
    await store.saveConnections(updated);
    await refresh();
  }

  Future<void> deleteConnection(String id) async {
    final store = await ref.read(connectionStoreProvider.future);
    final existing = store.loadConnections();
    final updated = existing.where((item) => item.id != id).toList();
    await store.saveConnections(updated);

    if (store.loadLastUsedId() == id) {
      await store.saveLastUsedId(updated.isNotEmpty ? updated.first.id : null);
    }
    await refresh();
  }

  Future<SavedConnection> markAsUsed(SavedConnection connection) async {
    final updated = connection.copyWith(lastUsedAt: DateTime.now());
    final store = await ref.read(connectionStoreProvider.future);
    final existing = store.loadConnections();
    final list = existing
        .map((item) => item.id == updated.id ? updated : item)
        .toList();
    await store.saveConnections(list);
    await store.saveLastUsedId(updated.id);
    await refresh();
    return updated;
  }

  Future<void> clearAll() async {
    final store = await ref.read(connectionStoreProvider.future);
    await store.clearAll();
    await refresh();
  }
}

final connectionsProvider =
    AsyncNotifierProvider<ConnectionsController, List<SavedConnection>>(
  ConnectionsController.new,
);

final activeConnectionProvider = StateProvider<SavedConnection?>((ref) => null);
