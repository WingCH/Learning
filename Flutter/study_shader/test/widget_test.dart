import 'package:flutter_test/flutter_test.dart';

import 'package:study_shader/main.dart';

void main() {
  testWidgets('topographic label renders', (WidgetTester tester) async {
    await tester.pumpWidget(const TopographicApp());
    await tester.pump();
    expect(find.text('Topographic'), findsOneWidget);
    expect(find.text('Shader'), findsOneWidget);
  });
}
