# Flutter Performance Test Example

這個項目示範如何使用Flutter的集成測試來測量應用程序的性能表現。

## 項目結構

- `lib/performance_comparison.dart` - 主應用程序，包含效能比較介面
- `lib/inefficient_item.dart` - 低效能的列表項实现
- `lib/efficient_item.dart` - 優化過的列表項实现
- `lib/main.dart` - 應用程序入口點
- `integration_test/comparison_test.dart` - 低效與高效實現的比較測試
- `integration_test/screen_size_test.dart` - 不同螢幕尺寸影響測試
- `test_driver/comparison_driver.dart` - 比較測試驅動
- `test_driver/screen_size_driver.dart` - 螢幕尺寸測試驅動
- `test_driver/perf_driver.dart` - 基本測試驅動
- `run_multiple_tests.sh` - 自動運行多次測試的腳本
- `analyze_results.dart` - 分析測試結果的腳本

## 運行性能測試

### 效能比較測試

```bash
flutter drive \
  --driver=test_driver/comparison_driver.dart \
  --target=integration_test/comparison_test.dart \
  -d "<設備ID>"
```

### 螢幕尺寸影響測試

```bash
flutter drive \
  --driver=test_driver/screen_size_driver.dart \
  --target=integration_test/screen_size_test.dart \
  -d "<設備ID>"
```

## 批量測試與結果分析

### 運行多次測試

使用提供的腳本可以自動運行10次測試並保存結果：

```bash
./run_multiple_tests.sh
```

腳本會自動執行以下操作：
1. 創建 `test_results` 目錄保存測試結果
2. 運行10次比較測試
3. 為每次測試保存性能數據
4. 創建彙總的摘要文件

### 分析測試結果

運行結果分析腳本來處理測試數據：

```bash
dart analyze_results.dart
```

分析腳本會：
1. 讀取所有測試結果
2. 計算統計數據（平均值、最小值、最大值、標準差等）
3. 生成詳細的分析報告 `test_results/analysis_report.json`
4. 在控制台顯示簡要的結果摘要

## 查看測試結果

測試完成後，在 `test_results` 目錄下查看以下文件：

### 每次測試的結果文件
- `inefficient_scrolling_N.timeline_summary.json` - 低效實現的性能摘要
- `efficient_scrolling_N.timeline_summary.json` - 優化實現的性能摘要
- `performance_comparison_report_N.json` - 兩種實現的比較報告

### 彙總結果
- `summary.json` - 所有測試運行的彙總數據
- `analysis_report.json` - 詳細的統計分析報告

摘要文件可以用任何文本編輯器查看，包含如下指標：
- 平均幀構建時間
- 最差幀構建時間
- 錯失幀構建預算次數
- 平均幀光柵化時間
- 最差幀光柵化時間
- 錯失幀光柵化預算次數
- 幀數

時間線文件可以在Chrome的追蹤工具中打開，方法是打開 `chrome://tracing` 並加載該文件。

## 性能指標說明

- **幀構建時間**：Flutter構建幀所需的時間
- **幀光柵化時間**：將幀渲染到屏幕上所需的時間
- **錯失預算**：構建時間超過16.67ms預算（對應60fps）的幀數量

## 優化範例說明

### 低效實現問題
- 進行過多的計算（10000次循環）
- 嵌套過多的Widget
- 過多的佈局約束
- 動態創建色彩

### 優化方法
- 預計算或緩存值
- 減少Widget樹的深度
- 簡化佈局
- 使用常量和預定義的樣式

## 參考資料

本範例基於Flutter官方文檔中的[集成測試性能分析](https://docs.flutter.dev/cookbook/testing/integration/profiling)指南。
