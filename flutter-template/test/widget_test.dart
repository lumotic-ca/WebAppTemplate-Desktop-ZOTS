import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webapp_template/app.dart';

void main() {
  testWidgets('App boots to loading shell', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WebAppTemplate(),
      ),
    );

    expect(find.byType(WebAppTemplate), findsOneWidget);
  });
}
