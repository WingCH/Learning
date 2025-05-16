import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:study_flutter_performance_test/performance_comparison.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Compare scrolling performance between inefficient and efficient implementations',
      (tester) async {
    // 準備測試數據
    final items = List<String>.generate(1000, (i) => 'Item $i');
    
    // 構建應用程序
    await tester.pumpWidget(PerformanceComparisonApp(items: items));
    await tester.pumpAndSettle();

    // 找到 TabBarView 和列表
    final inefficientListFinder = find.byKey(const ValueKey('inefficient_list'));
    
    // 第一步：測試低效能版本的滾動表現
    await binding.traceAction(() async {
      // 在低效能列表中滾動
      await tester.fling(inefficientListFinder, const Offset(0, -500), 1000);
      await tester.pumpAndSettle();

      // 再向上滾動
      await tester.fling(inefficientListFinder, const Offset(0, -500), 1000);
      await tester.pumpAndSettle();
    }, reportKey: 'inefficient_scrolling');

    // 切換到優化版本的標籤
    await tester.tap(find.text('優化版本'));
    await tester.pumpAndSettle();

    final efficientListFinder = find.byKey(const ValueKey('efficient_list'));

    // 第二步：測試優化版本的滾動表現
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