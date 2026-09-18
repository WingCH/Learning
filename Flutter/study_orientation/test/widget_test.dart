import 'package:flutter_test/flutter_test.dart';

import 'package:study_orientation/main.dart';

void main() {
  testWidgets('Orientation test smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.textContaining('Orientation:'), findsOneWidget);
  });
}
