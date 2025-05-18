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
  Duration duration = const Duration(seconds: 3), // 增加默認持續時間到3秒
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

/// 模擬重複滾動的輔助函數
Future<void> simulateRepeatedScrolling(
  WidgetTester tester,
  Finder listFinder, {
  int repeatCount = 4,
  Offset offset = const Offset(0, -500),
  double velocity = 800,
  Duration scrollDuration = const Duration(seconds: 3),
  Duration pauseDuration = const Duration(milliseconds: 200),
}) async {
  for (int i = 0; i < repeatCount; i++) {
    // 向下滾動
    await simulateScrollWithFrames(
      tester,
      listFinder,
      offset: offset,
      velocity: velocity,
      duration: scrollDuration,
    );

    // 如果不是最後一次滾動，則等待短暫時間
    if (i < repeatCount - 1) {
      await tester.pump(pauseDuration);
    }
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
        // 使用共用函數執行重複滾動測試
        await simulateRepeatedScrolling(tester, inefficientListFinder);
      }, reportKey: 'inefficient_scrolling');
    } catch (e) {
      // 在不支援 timeline 的環境下執行基本測試
      // 使用共用函數執行重複滾動測試
      await simulateRepeatedScrolling(tester, inefficientListFinder);
    }
  });
}
