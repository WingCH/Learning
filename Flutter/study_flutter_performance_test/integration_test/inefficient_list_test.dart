import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:study_flutter_performance_test/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test inefficient list scrolling performance', (tester) async {
    // 啟動應用程序
    app.main();
    await tester.pumpAndSettle();

    // 切換到低效能版本標籤
    await tester.tap(find.text('低效能版本'));
    await tester.pumpAndSettle();

    // 確保已經切換到低效能列表
    final inefficientListFinder =
        find.byKey(const ValueKey('inefficient_list'));
    expect(inefficientListFinder, findsOneWidget);

    // 測量低效能列表的滾動效能
    await binding.traceAction(() async {
      // 在低效能列表中滾動
      await tester.fling(inefficientListFinder, const Offset(0, -500), 1000);
      await tester.pumpAndSettle();

      // 再向上滾動
      await tester.fling(inefficientListFinder, const Offset(0, -500), 1000);
      await tester.pumpAndSettle();
    }, reportKey: 'inefficient_scrolling');
  });
}
