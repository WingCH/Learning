// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study_flutter_performance_test/performance_comparison.dart';

void main() {
  testWidgets('List scroll test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      PerformanceComparisonApp(items: List<String>.generate(100, (i) => 'Item $i')),
    );
    await tester.pumpAndSettle();

    // 切換到優化版本
    await tester.tap(find.text('優化版本'));
    await tester.pumpAndSettle();

    // Verify that our list shows the first item.
    expect(find.text('Item 0 - 0'), findsOneWidget);
    expect(find.text('Item 99 - 0'), findsNothing);

    // Scroll down.
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pump();

    // Verify that the list has scrolled.
    expect(find.text('Item 0 - 0'), findsNothing);
  });
}
