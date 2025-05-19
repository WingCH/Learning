# Flutter 效能測試專案

此專案用於比較 Flutter 不同實現方式的效能差異，特別針對列表捲動效能進行測試。

## 效能測試流程

本專案包含自動化測試腳本，可執行完整的構建和效能測試流程：

1. 構建高效/低效版本的 IPA 檔案
2. 運行效能測試並收集結果
3. 生成詳細報告

## 如何使用

### 運行完整測試流程

```bash
./scripts/run_all.sh
```

此命令會執行完整的測試流程，包括構建 IPA 檔案、運行效能測試，並生成報告。

### 只構建 IPA 檔案

```bash
./scripts/build_ipa.sh
```

此命令會分別構建高效版本和低效版本的 IPA 檔案，並記錄構建時間。

### 只運行效能測試

```bash
./scripts/run_performance_tests.sh
```

此命令會使用現有的 IPA 檔案執行效能測試，並收集結果。

## 測試結果檔案

測試完成後，會在 `test_results/` 目錄中生成以下檔案：

- `efficient_scrolling_1.timeline_summary.json` - 高效版本測試結果摘要
- `inefficient_scrolling_1.timeline_summary.json` - 低效版本測試結果摘要
- `performance_report.json` - 完整測試報告
- `build_times.json` - 構建時間記錄

## 報告格式

完整測試後，會在 `test_results/performance_report.json` 生成一份詳細的 JSON 報告，按照測試用例分組整理結果：

```json
{
  "timestamp": "2023-05-01T10:00:00Z",
  "test_cases": {
    "efficient": {
      "build_time": {
        "total_seconds": 60,
        "formatted": "00:01:00",
        "status": "success"
      },
      "test_times": {
        "runs": {
          "test_1": {
            "total_seconds": 30,
            "formatted": "00:00:30",
            "status": "success"
          }
        },
        "total": {
          "total_seconds": 30,
          "formatted": "00:00:30"
        }
      },
      "results": [
        {
          "average_frame_build_time_millis": 4.0,
          "worst_frame_build_time_millis": 8.0,
          "missed_frame_build_budget_count": 0
        }
      ],
      "files": [
        "/Users/username/project/test_results/efficient_scrolling_1.timeline_summary.json"
      ]
    },
    "inefficient": {
      "build_time": {
        "total_seconds": 60,
        "formatted": "00:01:00",
        "status": "success"
      },
      "test_times": {
        "runs": {
          "test_1": {
            "total_seconds": 35,
            "formatted": "00:00:35",
            "status": "success"
          }
        },
        "total": {
          "total_seconds": 35,
          "formatted": "00:00:35"
        }
      },
      "results": [
        {
          "average_frame_build_time_millis": 12.0,
          "worst_frame_build_time_millis": 20.0,
          "missed_frame_build_budget_count": 5
        }
      ],
      "files": [
        "/Users/username/project/test_results/inefficient_scrolling_1.timeline_summary.json"
      ]
    }
  },
  "summary": {
    "build_status": "success",
    "test_status": "success",
    "build_time": {
      "total_seconds": 120,
      "formatted": "00:02:00"
    },
    "test_time": {
      "total_seconds": 65,
      "formatted": "00:01:05"
    },
    "total_duration": {
      "total_seconds": 185,
      "formatted": "00:03:05"
    },
    "completed_at": "2023-05-01T10:30:00Z"
  }
}
```

## 查看報告

可以使用以下命令查看報告：

```bash
# 查看完整報告
jq . test_results/performance_report.json | less

# 查看高效版本測試結果
jq '.test_cases.efficient' test_results/performance_report.json

# 查看低效版本測試結果
jq '.test_cases.inefficient' test_results/performance_report.json

# 查看高效版本測試結果檔案路徑
jq '.test_cases.efficient.files' test_results/performance_report.json

# 查看低效版本測試結果檔案路徑
jq '.test_cases.inefficient.files' test_results/performance_report.json
```

## 注意事項

- 確保已安裝 `jq` 工具，用於處理 JSON 數據
- 確保已安裝 Flutter 和 FVM（Flutter Version Manager）
- 設備 ID 需要在 `run_performance_tests.sh` 中設定，可透過 `flutter devices` 或 `xcrun xctrace list devices` 獲取

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
chmod +x ./scripts/run_all.sh

# 執行完整測試流程（構建IPA並運行測試）
./scripts/run_all.sh

# 或者單獨執行各個步驟
./scripts/build_ipa.sh          # 僅構建IPA檔案
./scripts/run_performance_tests.sh  # 僅運行測試(需要已構建的IPA)
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
- `/scripts` - 測試腳本
  - `build_ipa.sh` - 構建IPA檔案的腳本
  - `run_performance_tests.sh` - 執行效能測試的腳本
  - `run_all.sh` - 執行完整流程的主腳本

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

# Pre-build binary and run test

## Pre-build ipa
```bash
fvm flutter build ipa \
--target=integration_test/inefficient_list_test.dart \
--profile \
--export-method development
```

## Pre-build apk
```bash
fvm flutter build apk \
--target=integration_test/inefficient_list_test.dart \
--profile
```

## Run test with pre-build ipa
```bash
# `--target` option seems can be ignored because the `build ipa` command already specifies the target.
fvm flutter drive \
  --driver=test_driver/inefficient_list_test_driver.dart \
  --target=integration_test/inefficient_list_test.dart \
  --no-dds \
  --profile \
  --use-application-binary /Users/wingchan/Project/Learning/Flutter/study_flutter_performance_test/build/ios/ipa/study_flutter_performance_test.ipa \
  -d 00008130-001435102EC0001C
```

## Run test with pre-build apk
```
fvm flutter drive \
  --driver=test_driver/inefficient_list_test_driver.dart \
  --target=integration_test/inefficient_list_test.dart \
  --no-dds \
  --profile \
  --use-application-binary /Users/wingchan/Project/Learning/Flutter/study_flutter_performance_test/build/app/outputs/flutter-apk/app-profile.apk \
  -d 39181FDJG006N3
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
Wing's MacBook Pro (ID1)
Hong Wing's Apple Watch (ID2)
Wing CHAN's iPhone (ID3)
Wing's iPad Mimi (ID4)

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
