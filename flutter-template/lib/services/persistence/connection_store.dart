import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:webapp_template/features/connection/models/saved_connection.dart';

class ConnectionStore {
  ConnectionStore(this._prefs);

  static const _connectionsKey = 'connections';
  static const _lastUsedIdKey = 'last_used_connection_id';

  final SharedPreferences _prefs;

  List<SavedConnection> loadConnections() {
    final raw = _prefs.getString(_connectionsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => SavedConnection.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveConnections(List<SavedConnection> connections) async {
    final encoded = jsonEncode(connections.map((c) => c.toJson()).toList());
    await _prefs.setString(_connectionsKey, encoded);
  }

  String? loadLastUsedId() => _prefs.getString(_lastUsedIdKey);

  Future<void> saveLastUsedId(String? id) async {
    if (id == null) {
      await _prefs.remove(_lastUsedIdKey);
      return;
    }
    await _prefs.setString(_lastUsedIdKey, id);
  }

  Future<void> clearAll() async {
    await _prefs.remove(_connectionsKey);
    await _prefs.remove(_lastUsedIdKey);
  }
}
