import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:study_flutter_performance_test/performance_comparison.dart';

/// 該測試評估不同螢幕大小對應用程式效能的影響
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test performance across different screen sizes', (tester) async {
    // 準備測試數據
    final items = List<String>.generate(1000, (i) => 'Item $i');
    
    // 測試不同的螢幕大小
    final screenSizes = [
      const Size(320, 480),  // 小型手機
      const Size(375, 667),  // iPhone 8
      const Size(414, 896),  // iPhone 11
      const Size(768, 1024), // iPad
    ];
    
    for (final size in screenSizes) {
      // 設置測試裝置尺寸
      await binding.setSurfaceSize(size);
      
      // 構建應用程序
      await tester.pumpWidget(PerformanceComparisonApp(items: items));
      await tester.pumpAndSettle();
      
      // 找到列表
      final efficientListFinder = find.byKey(const ValueKey('efficient_list'));
      
      // 測試在當前螢幕尺寸下的滾動表現
      await binding.traceAction(() async {
        // 進行多次滾動以獲得更準確的效能指標
        for (int i = 0; i < 3; i++) {
          await tester.fling(efficientListFinder, const Offset(0, -300), 1000);
          await tester.pumpAndSettle();
        }
      }, reportKey: 'screen_size_${size.width.toInt()}x${size.height.toInt()}');
    }
  });
} 