import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() async {
  // 讀取摘要文件
  final summaryFile = File('test_results/summary.json');
  if (!await summaryFile.exists()) {
    print('找不到摘要文件。請先運行測試。');
    return;
  }
  
  final summaryContent = await summaryFile.readAsString();
  final summary = jsonDecode(summaryContent);
  final tests = summary['tests'] as List;
  
  if (tests.isEmpty) {
    print('沒有測試結果可分析。');
    return;
  }
  
  // 準備統計數據
  final inefficientStats = {
    'avgBuildTimes': <double>[],
    'worstBuildTimes': <double>[],
    'missedBuildCounts': <double>[],
    'avgRasterizerTimes': <double>[],
    'worstRasterizerTimes': <double>[],
    'missedRasterizerCounts': <double>[],
    'frameCounts': <double>[],
  };
  
  final efficientStats = {
    'avgBuildTimes': <double>[],
    'worstBuildTimes': <double>[],
    'missedBuildCounts': <double>[],
    'avgRasterizerTimes': <double>[],
    'worstRasterizerTimes': <double>[],
    'missedRasterizerCounts': <double>[],
    'frameCounts': <double>[],
  };
  
  final improvementStats = {
    'avgBuildTimePercents': <double>[],
    'worstBuildTimePercents': <double>[],
    'avgRasterizerTimePercents': <double>[],
    'worstRasterizerTimePercents': <double>[],
  };
  
  // 從每次測試中提取數據
  for (final test in tests) {
    final data = test['data'];
    final inefficient = data['inefficient'];
    final efficient = data['efficient'];
    final improvement = data['improvement'];
    
    // 提取低效能數據
    inefficientStats['avgBuildTimes']!.add(inefficient['average_frame_build_time_ms'].toDouble());
    inefficientStats['worstBuildTimes']!.add(inefficient['worst_frame_build_time_ms'].toDouble());
    inefficientStats['missedBuildCounts']!.add(inefficient['missed_frame_build_budget_count'].toDouble());
    inefficientStats['avgRasterizerTimes']!.add(inefficient['average_frame_rasterizer_time_ms'].toDouble());
    inefficientStats['worstRasterizerTimes']!.add(inefficient['worst_frame_rasterizer_time_ms'].toDouble());
    inefficientStats['missedRasterizerCounts']!.add(inefficient['missed_frame_rasterizer_budget_count'].toDouble());
    inefficientStats['frameCounts']!.add(inefficient['frame_count'].toDouble());
    
    // 提取高效能數據
    efficientStats['avgBuildTimes']!.add(efficient['average_frame_build_time_ms'].toDouble());
    efficientStats['worstBuildTimes']!.add(efficient['worst_frame_build_time_ms'].toDouble());
    efficientStats['missedBuildCounts']!.add(efficient['missed_frame_build_budget_count'].toDouble());
    efficientStats['avgRasterizerTimes']!.add(efficient['average_frame_rasterizer_time_ms'].toDouble());
    efficientStats['worstRasterizerTimes']!.add(efficient['worst_frame_rasterizer_time_ms'].toDouble());
    efficientStats['missedRasterizerCounts']!.add(efficient['missed_frame_rasterizer_budget_count'].toDouble());
    efficientStats['frameCounts']!.add(efficient['frame_count'].toDouble());
    
    // 提取改進數據
    improvementStats['avgBuildTimePercents']!.add(improvement['average_frame_build_time_percent'].toDouble());
    improvementStats['worstBuildTimePercents']!.add(improvement['worst_frame_build_time_percent'].toDouble());
    improvementStats['avgRasterizerTimePercents']!.add(improvement['average_frame_rasterizer_time_percent'].toDouble());
    improvementStats['worstRasterizerTimePercents']!.add(improvement['worst_frame_rasterizer_time_percent'].toDouble());
  }
  
  // 計算統計數據
  final analysisReport = {
    'inefficient': {
      'avg_build_time': {
        'mean': _calculateMean(inefficientStats['avgBuildTimes']!),
        'min': _calculateMin(inefficientStats['avgBuildTimes']!),
        'max': _calculateMax(inefficientStats['avgBuildTimes']!),
        'stdDev': _calculateStdDev(inefficientStats['avgBuildTimes']!),
      },
      'worst_build_time': {
        'mean': _calculateMean(inefficientStats['worstBuildTimes']!),
        'min': _calculateMin(inefficientStats['worstBuildTimes']!),
        'max': _calculateMax(inefficientStats['worstBuildTimes']!),
        'stdDev': _calculateStdDev(inefficientStats['worstBuildTimes']!),
      },
      'missed_build_budgets': {
        'mean': _calculateMean(inefficientStats['missedBuildCounts']!),
        'min': _calculateMin(inefficientStats['missedBuildCounts']!),
        'max': _calculateMax(inefficientStats['missedBuildCounts']!),
        'stdDev': _calculateStdDev(inefficientStats['missedBuildCounts']!),
      },
      'avg_rasterizer_time': {
        'mean': _calculateMean(inefficientStats['avgRasterizerTimes']!),
        'min': _calculateMin(inefficientStats['avgRasterizerTimes']!),
        'max': _calculateMax(inefficientStats['avgRasterizerTimes']!),
        'stdDev': _calculateStdDev(inefficientStats['avgRasterizerTimes']!),
      },
      'frame_count': {
        'mean': _calculateMean(inefficientStats['frameCounts']!),
        'min': _calculateMin(inefficientStats['frameCounts']!),
        'max': _calculateMax(inefficientStats['frameCounts']!),
        'stdDev': _calculateStdDev(inefficientStats['frameCounts']!),
      },
    },
    'efficient': {
      'avg_build_time': {
        'mean': _calculateMean(efficientStats['avgBuildTimes']!),
        'min': _calculateMin(efficientStats['avgBuildTimes']!),
        'max': _calculateMax(efficientStats['avgBuildTimes']!),
        'stdDev': _calculateStdDev(efficientStats['avgBuildTimes']!),
      },
      'worst_build_time': {
        'mean': _calculateMean(efficientStats['worstBuildTimes']!),
        'min': _calculateMin(efficientStats['worstBuildTimes']!),
        'max': _calculateMax(efficientStats['worstBuildTimes']!),
        'stdDev': _calculateStdDev(efficientStats['worstBuildTimes']!),
      },
      'missed_build_budgets': {
        'mean': _calculateMean(efficientStats['missedBuildCounts']!),
        'min': _calculateMin(efficientStats['missedBuildCounts']!),
        'max': _calculateMax(efficientStats['missedBuildCounts']!),
        'stdDev': _calculateStdDev(efficientStats['missedBuildCounts']!),
      },
      'avg_rasterizer_time': {
        'mean': _calculateMean(efficientStats['avgRasterizerTimes']!),
        'min': _calculateMin(efficientStats['avgRasterizerTimes']!),
        'max': _calculateMax(efficientStats['avgRasterizerTimes']!),
        'stdDev': _calculateStdDev(efficientStats['avgRasterizerTimes']!),
      },
      'frame_count': {
        'mean': _calculateMean(efficientStats['frameCounts']!),
        'min': _calculateMin(efficientStats['frameCounts']!),
        'max': _calculateMax(efficientStats['frameCounts']!),
        'stdDev': _calculateStdDev(efficientStats['frameCounts']!),
      },
    },
    'improvement': {
      'avg_build_time_percent': {
        'mean': _calculateMean(improvementStats['avgBuildTimePercents']!),
        'min': _calculateMin(improvementStats['avgBuildTimePercents']!),
        'max': _calculateMax(improvementStats['avgBuildTimePercents']!),
        'stdDev': _calculateStdDev(improvementStats['avgBuildTimePercents']!),
      },
      'worst_build_time_percent': {
        'mean': _calculateMean(improvementStats['worstBuildTimePercents']!),
        'min': _calculateMin(improvementStats['worstBuildTimePercents']!),
        'max': _calculateMax(improvementStats['worstBuildTimePercents']!),
        'stdDev': _calculateStdDev(improvementStats['worstBuildTimePercents']!),
      },
      'avg_rasterizer_time_percent': {
        'mean': _calculateMean(improvementStats['avgRasterizerTimePercents']!),
        'min': _calculateMin(improvementStats['avgRasterizerTimePercents']!),
        'max': _calculateMax(improvementStats['avgRasterizerTimePercents']!),
        'stdDev': _calculateStdDev(improvementStats['avgRasterizerTimePercents']!),
      },
      'worst_rasterizer_time_percent': {
        'mean': _calculateMean(improvementStats['worstRasterizerTimePercents']!),
        'min': _calculateMin(improvementStats['worstRasterizerTimePercents']!),
        'max': _calculateMax(improvementStats['worstRasterizerTimePercents']!),
        'stdDev': _calculateStdDev(improvementStats['worstRasterizerTimePercents']!),
      },
    },
    'test_count': tests.length,
  };
  
  // 輸出分析報告
  final analysisFile = File('test_results/analysis_report.json');
  await analysisFile.writeAsString(const JsonEncoder.withIndent('  ').convert(analysisReport));
  
  // 輸出摘要到控制台
  print('===== 測試結果分析 =====');
  print('測試次數: ${tests.length}');
  print('\n低效能版本:');
  print('  平均幀構建時間 (ms): ${(analysisReport['inefficient'] as Map)['avg_build_time']['mean'].toStringAsFixed(3)} ± ${(analysisReport['inefficient'] as Map)['avg_build_time']['stdDev'].toStringAsFixed(3)}');
  print('  最差幀構建時間 (ms): ${(analysisReport['inefficient'] as Map)['worst_build_time']['mean'].toStringAsFixed(3)} ± ${(analysisReport['inefficient'] as Map)['worst_build_time']['stdDev'].toStringAsFixed(3)}');
  print('  平均錯過幀構建預算次數: ${(analysisReport['inefficient'] as Map)['missed_build_budgets']['mean'].toStringAsFixed(2)}');
  
  print('\n高效能版本:');
  print('  平均幀構建時間 (ms): ${(analysisReport['efficient'] as Map)['avg_build_time']['mean'].toStringAsFixed(3)} ± ${(analysisReport['efficient'] as Map)['avg_build_time']['stdDev'].toStringAsFixed(3)}');
  print('  最差幀構建時間 (ms): ${(analysisReport['efficient'] as Map)['worst_build_time']['mean'].toStringAsFixed(3)} ± ${(analysisReport['efficient'] as Map)['worst_build_time']['stdDev'].toStringAsFixed(3)}');
  print('  平均錯過幀構建預算次數: ${(analysisReport['efficient'] as Map)['missed_build_budgets']['mean'].toStringAsFixed(2)}');
  
  print('\n平均改進:');
  print('  平均幀構建時間: ${(analysisReport['improvement'] as Map)['avg_build_time_percent']['mean'].toStringAsFixed(2)}%');
  print('  最差幀構建時間: ${(analysisReport['improvement'] as Map)['worst_build_time_percent']['mean'].toStringAsFixed(2)}%');
  
  print('\n詳細分析報告已保存到 test_results/analysis_report.json');
}

double _calculateMean(List<double> values) {
  if (values.isEmpty) return 0;
  return values.reduce((a, b) => a + b) / values.length;
}

double _calculateMin(List<double> values) {
  if (values.isEmpty) return 0;
  return values.reduce((a, b) => a < b ? a : b);
}

double _calculateMax(List<double> values) {
  if (values.isEmpty) return 0;
  return values.reduce((a, b) => a > b ? a : b);
}

double _calculateStdDev(List<double> values) {
  if (values.isEmpty) return 0;
  final mean = _calculateMean(values);
  final sumOfSquaredDifferences = values.fold(0.0, (sum, value) => sum + pow(value - mean, 2));
  return sqrt(sumOfSquaredDifferences / values.length);
} 