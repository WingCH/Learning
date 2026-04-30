import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_nestedscrollview/main.dart';

void main() {
  testWidgets('shows pinned and floating NestedScrollView header modes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NestedScrollExampleApp());

    expect(find.byType(NestedScrollView), findsOneWidget);
    expect(find.byType(SliverAppBar), findsNothing);
    expect(find.byType(SliverPersistentHeader), findsOneWidget);
    expect(find.text('pinned'), findsOneWidget);
    expect(find.text('floating'), findsOneWidget);
    expect(find.text('Inner scroll item 1'), findsOneWidget);

    NestedScrollView nestedScrollView = tester.widget<NestedScrollView>(
      find.byKey(const ValueKey<String>('demo-nested-scroll-view')),
    );
    SliverPersistentHeader persistentHeader = tester
        .widget<SliverPersistentHeader>(
          find.byKey(const ValueKey<String>('demo-persistent-header')),
        );

    expect(nestedScrollView.floatHeaderSlivers, isFalse);
    expect(persistentHeader.pinned, isTrue);
    expect(persistentHeader.floating, isFalse);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -360));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('floating'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    nestedScrollView = tester.widget<NestedScrollView>(
      find.byKey(const ValueKey<String>('demo-nested-scroll-view')),
    );
    persistentHeader = tester.widget<SliverPersistentHeader>(
      find.byKey(const ValueKey<String>('demo-persistent-header')),
    );

    expect(nestedScrollView.floatHeaderSlivers, isTrue);
    expect(persistentHeader.pinned, isFalse);
    expect(persistentHeader.floating, isTrue);
    expect(persistentHeader.delegate.snapConfiguration, isNotNull);
  });
}
