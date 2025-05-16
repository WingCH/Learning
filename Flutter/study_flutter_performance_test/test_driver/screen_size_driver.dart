import 'dart:convert';
import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() {
  return integrationDriver(
    responseDataCallback: (data) async {
      if (data != null) {
        final screenSizeReports = <String, Map<String, dynamic>>{};
        
        // 提取所有與螢幕尺寸相關的時間線資料
        for (final key in data.keys) {
          if (key.startsWith('screen_size_')) {
            final timeline = driver.Timeline.fromJson(
              data[key] as Map<String, dynamic>,
            );
            final summary = driver.TimelineSummary.summarize(timeline);
            
            // 儲存時間線資料
            await summary.writeTimelineToFile(
              key,
              pretty: true,
              includeSummary: true,
            );
            
            // 收集性能摘要資料
            screenSizeReports[key] = summary.summaryJson;
          }
        }
        
        // 匯總並比較不同螢幕尺寸的性能
        final screenSizeComparison = <String, Map<String, dynamic>>{};
        for (final entry in screenSizeReports.entries) {
          final sizeKey = entry.key.replaceFirst('screen_size_', '');
          screenSizeComparison[sizeKey] = {
            'average_frame_build_time_ms': entry.value['average_frame_build_time_millis'],
            'worst_frame_build_time_ms': entry.value['worst_frame_build_time_millis'],
            'missed_frame_build_budget_count': entry.value['missed_frame_build_budget_count'],
            'average_frame_rasterizer_time_ms': entry.value['average_frame_rasterizer_time_millis'],
            'worst_frame_rasterizer_time_ms': entry.value['worst_frame_rasterizer_time_millis'],
            'missed_frame_rasterizer_budget_count': entry.value['missed_frame_rasterizer_budget_count'],
            'frame_count': entry.value['frame_count'],
          };
        }
        
        // 將比較報告寫入文件
        final directory = Directory('build');
        if (!directory.existsSync()) {
          directory.createSync();
        }
        final file = File('build/screen_size_comparison_report.json');
        await file.writeAsString(JsonEncoder.withIndent('  ').convert(screenSizeComparison));
      }
    },
  );
} 