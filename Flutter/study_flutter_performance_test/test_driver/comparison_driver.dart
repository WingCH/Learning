import 'dart:convert';
import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() {
  return integrationDriver(
    responseDataCallback: (data) async {
      if (data != null) {
        // 處理低效能版本的時間線
        final inefficientTimeline = driver.Timeline.fromJson(
          data['inefficient_scrolling'] as Map<String, dynamic>,
        );
        final inefficientSummary = driver.TimelineSummary.summarize(inefficientTimeline);
        
        // 處理優化版本的時間線
        final efficientTimeline = driver.Timeline.fromJson(
          data['efficient_scrolling'] as Map<String, dynamic>,
        );
        final efficientSummary = driver.TimelineSummary.summarize(efficientTimeline);

        // 儲存低效能版本的時間線和摘要
        await inefficientSummary.writeTimelineToFile(
          'inefficient_scrolling',
          pretty: true,
          includeSummary: true,
        );
        
        // 儲存優化版本的時間線和摘要
        await efficientSummary.writeTimelineToFile(
          'efficient_scrolling',
          pretty: true,
          includeSummary: true,
        );
        
        // 取得性能摘要數據
        final inefficientSummaryData = inefficientSummary.summaryJson;
        final efficientSummaryData = efficientSummary.summaryJson;
        
        // 儲存比較結果
        final comparisonReport = {
          'inefficient': {
            'average_frame_build_time_ms': inefficientSummaryData['average_frame_build_time_millis'],
            'worst_frame_build_time_ms': inefficientSummaryData['worst_frame_build_time_millis'],
            'missed_frame_build_budget_count': inefficientSummaryData['missed_frame_build_budget_count'],
            'average_frame_rasterizer_time_ms': inefficientSummaryData['average_frame_rasterizer_time_millis'],
            'worst_frame_rasterizer_time_ms': inefficientSummaryData['worst_frame_rasterizer_time_millis'],
            'missed_frame_rasterizer_budget_count': inefficientSummaryData['missed_frame_rasterizer_budget_count'],
            'frame_count': inefficientSummaryData['frame_count'],
          },
          'efficient': {
            'average_frame_build_time_ms': efficientSummaryData['average_frame_build_time_millis'],
            'worst_frame_build_time_ms': efficientSummaryData['worst_frame_build_time_millis'],
            'missed_frame_build_budget_count': efficientSummaryData['missed_frame_build_budget_count'],
            'average_frame_rasterizer_time_ms': efficientSummaryData['average_frame_rasterizer_time_millis'],
            'worst_frame_rasterizer_time_ms': efficientSummaryData['worst_frame_rasterizer_time_millis'],
            'missed_frame_rasterizer_budget_count': efficientSummaryData['missed_frame_rasterizer_budget_count'],
            'frame_count': efficientSummaryData['frame_count'],
          },
          'improvement': {
            'average_frame_build_time_percent': _calculateImprovement(
              inefficientSummaryData['average_frame_build_time_millis'] as double,
              efficientSummaryData['average_frame_build_time_millis'] as double,
            ),
            'worst_frame_build_time_percent': _calculateImprovement(
              inefficientSummaryData['worst_frame_build_time_millis'] as double,
              efficientSummaryData['worst_frame_build_time_millis'] as double,
            ),
            'average_frame_rasterizer_time_percent': _calculateImprovement(
              inefficientSummaryData['average_frame_rasterizer_time_millis'] as double,
              efficientSummaryData['average_frame_rasterizer_time_millis'] as double,
            ),
            'worst_frame_rasterizer_time_percent': _calculateImprovement(
              inefficientSummaryData['worst_frame_rasterizer_time_millis'] as double,
              efficientSummaryData['worst_frame_rasterizer_time_millis'] as double,
            ),
          },
        };
        
        // 將比較報告寫入文件
        final directory = Directory('build');
        if (!directory.existsSync()) {
          directory.createSync();
        }
        final file = File('build/performance_comparison_report.json');
        await file.writeAsString(const JsonEncoder.withIndent('  ').convert(comparisonReport));
      }
    },
  );
}

/// 計算性能改進百分比
double _calculateImprovement(double before, double after) {
  if (before <= 0) return 0;
  return ((before - after) / before) * 100;
} 