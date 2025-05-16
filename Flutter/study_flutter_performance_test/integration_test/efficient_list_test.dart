import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:study_flutter_performance_test/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test efficient list scrolling performance', (tester) async {
    // 啟動應用程序
    app.main();
    await tester.pumpAndSettle();

    // 應用程序啟動時默認在「優化版本」標籤
    final efficientListFinder = find.byKey(const ValueKey('efficient_list'));

    // 確保列表顯示正確
    expect(efficientListFinder, findsOneWidget);

    // 測量優化列表的滾動效能
    await binding.traceAction(() async {
      // 在優化列表中滾動
      await tester.fling(efficientListFinder, const Offset(0, -500), 1000);
      await tester.pumpAndSettle();

      // 再向上滾動
      await tester.fling(efficientListFinder, const Offset(0, -500), 1000);
      await tester.pumpAndSettle();
    }, reportKey: 'efficient_scrolling');
  });
}
