import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webapp_template/features/connection/models/saved_connection.dart';
import 'package:webapp_template/services/persistence/connection_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConnectionStore', () {
    late SharedPreferences prefs;
    late ConnectionStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      store = ConnectionStore(prefs);
    });

    test('loads empty list by default', () {
      expect(store.loadConnections(), isEmpty);
      expect(store.loadLastUsedId(), isNull);
    });

    test('persists and reloads connections', () async {
      final connection = SavedConnection(
        id: '1',
        displayName: 'Test',
        url: 'https://example.com',
        lastUsedAt: DateTime.utc(2026, 1, 1),
      );

      await store.saveConnections([connection]);
      await store.saveLastUsedId(connection.id);

      expect(store.loadConnections(), [connection]);
      expect(store.loadLastUsedId(), '1');
    });

    test('clearAll removes saved data', () async {
      final connection = SavedConnection(
        id: '1',
        displayName: 'Test',
        url: 'https://example.com',
      );
      await store.saveConnections([connection]);
      await store.saveLastUsedId(connection.id);

      await store.clearAll();

      expect(store.loadConnections(), isEmpty);
      expect(store.loadLastUsedId(), isNull);
    });
  });
}
