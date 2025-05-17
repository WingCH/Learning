import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:study_flutter_performance_test/main.dart' as app;

/// 模擬滑動並渲染連續幀的輔助函數
Future<void> simulateScrollWithFrames(
  WidgetTester tester,
  Finder finder, {
  required Offset offset,
  required double velocity,
  Duration duration = const Duration(seconds: 2),
  int fps = 60,
}) async {
  // 執行滑動操作
  await tester.fling(finder, offset, velocity);

  // 計算需要多少幀來模擬指定的持續時間
  final int frameCount = duration.inMilliseconds ~/ (1000 ~/ fps);
  final int frameDurationMs = 1000 ~/ fps;

  // 模擬連續幀更新
  for (int i = 0; i < frameCount; i++) {
    await tester.pump(Duration(milliseconds: frameDurationMs));
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test inefficient list scrolling performance', (tester) async {
    // 啟動應用程序
    app.main();
    await tester.pumpAndSettle();

    // 切換到低效能版本標籤
    await tester.tap(find.text('低效能版本'));
    await tester.pump(const Duration(seconds: 1));

    // 確保已經切換到低效能列表
    final inefficientListFinder =
        find.byKey(const ValueKey('inefficient_list'));
    expect(inefficientListFinder, findsOneWidget);

    // 測量低效能列表的滾動效能
    try {
      await binding.traceAction(() async {
        // 在低效能列表中滾動兩次
        await simulateScrollWithFrames(
          tester,
          inefficientListFinder,
          offset: const Offset(0, -500),
          velocity: 1000,
        );

        await simulateScrollWithFrames(
          tester,
          inefficientListFinder,
          offset: const Offset(0, -500),
          velocity: 1000,
        );
      }, reportKey: 'inefficient_scrolling');
    } catch (e) {
      // 在不支援 timeline 的環境下執行基本測試
      // 在低效能列表中滾動兩次
      await simulateScrollWithFrames(
        tester,
        inefficientListFinder,
        offset: const Offset(0, -500),
        velocity: 1000,
      );

      await simulateScrollWithFrames(
        tester,
        inefficientListFinder,
        offset: const Offset(0, -500),
        velocity: 1000,
      );
    }
  });
}
