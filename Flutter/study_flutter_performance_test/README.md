# Flutter 效能測試示例

這個專案展示了 Flutter 中高效能和低效能版本的比較，並提供集成測試來測量它們的效能差異。

## 效能測試說明

本專案包含兩個獨立的集成測試，用於分別測量優化版本和低效能版本的滾動效能：

1. `efficient_list_test.dart` - 測試優化版本列表的滾動效能
2. `inefficient_list_test.dart` - 測試低效能版本列表的滾動效能

## 運行測試

### 單次測試

#### 測試優化版本

```bash
fvm flutter drive \
  --driver=test_driver/efficient_driver.dart \
  --target=integration_test/efficient_list_test.dart \
  --no-dds \
  --profile \
  -d 00008130-001435102EC0001C
```

#### 測試低效能版本

```bash
fvm flutter drive \
  --driver=test_driver/inefficient_driver.dart \
  --target=integration_test/inefficient_list_test.dart \
  --no-dds \
  --profile \
  -d 00008130-001435102EC0001C
```

### 批量測試

我們也提供了一個腳本，可以自動連續執行多次測試，並整理結果：

```bash
# 確保腳本有執行權限
chmod +x run_performance_tests.sh

# 執行批量測試
./run_performance_tests.sh
```

此腳本會：
1. 連續執行多次優化版本和低效能版本測試
2. 將結果保存到 `test_results` 目錄
3. 自動生成最終的比較報告

報告將保存在 `build/performance_comparison_report.json` 中。

## 查看測試結果

測試結束後，以下文件會包含有用的資訊：

- `build/efficient_scrolling.timeline_summary.json` - 優化版本的測試摘要
- `build/inefficient_scrolling.timeline_summary.json` - 低效能版本的測試摘要

時間線文件（.timeline.json）可以在 Chrome 的追蹤工具中打開，方法是打開 `chrome://tracing` 並載入該文件。

## 專案結構

- `/lib` - 應用程式源碼
  - `main.dart` - 主應用程式入口
  - `performance_comparison.dart` - 效能比較頁面
  - `efficient_item.dart` - 優化的列表項目組件
  - `inefficient_item.dart` - 低效能的列表項目組件
- `/integration_test` - 集成測試
  - `efficient_list_test.dart` - 優化版本測試
  - `inefficient_list_test.dart` - 低效能版本測試
- `/test_driver` - 測試驅動器
  - `efficient_driver.dart` - 優化版本測試驅動器
  - `inefficient_driver.dart` - 低效能版本測試驅動器
- `run_performance_tests.sh` - 批量測試執行腳本

## 性能指標說明

- **幀構建時間**：Flutter構建幀所需的時間
- **幀光柵化時間**：將幀渲染到屏幕上所需的時間
- **錯失預算**：構建時間超過16.67ms預算（對應60fps）的幀數量

## 優化範例說明

### 低效實現問題
- 進行過多的計算
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

---

# Pre-build ipa and run test

```bash
fvm flutter build ipa \
--target=integration_test/inefficient_list_test.dart \
--profile \
--export-method development
```

```bash
# `--target` option seems can be ignored because the `build ipa` command already specifies the target.
fvm flutter drive \
  --driver=test_driver/inefficient_driver.dart \
  --target=integration_test/inefficient_list_test.dart \
  --no-dds \
  --profile \
  --use-application-binary /Users/wingchan/Project/Learning/Flutter/study_flutter_performance_test/build/ios/ipa/study_flutter_performance_test.ipa \
  -d 00008130-001435102EC0001C
```

## if no need TimelineSummary, just run test (don't support pre-build ipa)
https://github.com/flutter/flutter/issues/114541
```bash
fvm flutter test integration_test/inefficient_list_test.dart \
  --no-dds \
  -d 00008130-001435102EC0001C
```

---

# Firebase Test Lab
https://github.com/flutter/flutter/blob/master/packages/integration_test/README.md

```bash
chmod +x ./firebase_test_lab.sh
./firebase_test_lab.sh
```

```bash
# find device id
xcrun xctrace list devices

== Devices ==
Wing’s MacBook Pro (ID1)
Hong Wing的Apple Watch (ID2)
Wing CHAN's iPhone (ID3)
Wing’s iPad Mimi (ID4)

== Simulators ==
iPad (10th generation) Simulator (18.2) (9E29E800-8FA8-4854-B5FA-8D6A9C76A6B8)
iPad (10th generation) (18.3.1) (788DFE68-2683-4813-9CC2-AD159E308871)
iPad Air 11-inch (M2) Simulator (18.2) (455C72F7-99AD-4060-995B-F46CD413A6BE)
iPad Air 11-inch (M2) (18.3.1) (975BC2BE-EA6F-4269-9F59-101ABB0A13F8)
iPad Air 13-inch (M2) Simulator (18.2) (FA6796CA-F8EF-455B-B9B4-42E838196C03)
```

You can verify locally that your tests are successful by running the following command:
```bash
XCTESTRUN_FILE=$(find build/ios_integ/Build/Products -name "Runner_*.xctestrun" | head -n 1)
xcodebuild test-without-building \
  -xctestrun "$XCTESTRUN_FILE" \
  -destination id=00008130-001435102EC0001C
```

> 在Firebase Test Lab入面不支援Flutter Drive的time summary統計數據

