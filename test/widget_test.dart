import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yalla_app/src/app.dart';

void main() {
  testWidgets('shows splash title first', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KidsEcoApp()));
    expect(find.text('أصدقاء البيئة الصغار'), findsOneWidget);
  });
}
