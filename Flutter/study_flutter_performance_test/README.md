# Flutter 效能測試專案

此專案用於比較 Flutter 不同實現方式的效能差異，特別針對列表捲動效能進行測試。

## 📋 快速導航

- [⚠️ 免費 Apple 開發者帳號限制與解決方案](#️-重要免費-apple-開發者帳號限制與解決方案) - **必讀！**
- [效能測試流程](#效能測試流程)
- [如何使用](#如何使用)
- [測試結果檔案](#測試結果檔案)
- [注意事項](#注意事項)
- [Pre-build Binary and Run Test](#pre-build-binary-and-run-test)
- [配置設備 ID](#配置設備-id)

---

## ⚠️ 重要：免費 Apple 開發者帳號限制與解決方案

### 限制說明

**免費的 Apple 開發者帳號無法使用 Pre-build IPA 功能！**

- ❌ **不支援**：`flutter build ipa` + `flutter drive --use-application-binary`
- ✅ **只能使用**：[`flutter drive` 直接運行](#單次測試)（每次重新構建和安裝）
- 📦 **本專案的自動化腳本**（`build_ipa.sh`、`run_all.sh`、`run_performance_tests.sh`）需要**付費 Apple 開發者帳號**

### 免費帳號的開發者信任問題

使用免費 Apple 帳號時，會遇到「Untrusted Developer」問題：

1. **首次安裝需要手動信任**：第一次安裝 app 需要在 iPhone 上手動信任開發者
   - 設定 → 一般 → VPN 與裝置管理 → 開發者 App → 信任
2. **測試會自動刪除 app**：`flutter drive` 測試結束後會自動移除應用程式
3. **所有 apps 被刪除後信任消失**：當開發者的所有 apps 都被刪除時，信任狀態會被重置
4. **下次測試需要重新信任**：導致每次測試都需要手動重新信任開發者

### 🎯 解決方案：保持開發者信任的方法

**創建一個「佔位 App」來保持開發者信任：**

1. **創建一個空的 Flutter 專案**：
   ```bash
   flutter create dummy_app
   cd dummy_app
   ```

2. **在 iPhone 上運行這個空專案**：
   ```bash
   flutter run -d YOUR_DEVICE_ID
   ```

3. **保持這個 app 在設備上**：
   - 不要刪除這個 app
   - 這個 app 會「佔位」保持開發者信任狀態

4. **運行測試**：
   - 現在可以正常運行 `flutter drive` 測試
   - 即使測試自動刪除測試 app，佔位 app 仍然在設備上
   - 開發者信任狀態得以保持，無需每次手動重新信任

**運作原理：**
- 只要設備上有**至少一個**該開發者的 app，信任狀態就會保持
- 佔位 app 確保永遠有一個 app 在設備上
- 測試可以自由刪除和重新安裝測試 app，不影響信任狀態

**參考資料：**
- [iOS Untrusted Developer Error - Perplexity Discussion](https://www.perplexity.ai/search/ios-untrusted-developer-error-b58JeVmORn.yjasDOFMCJQ#1)

### 總結

| 功能 | 免費 Apple 帳號 | 付費 Apple 開發者帳號 |
|------|----------------|---------------------|
| Pre-build IPA | ❌ 不支援 | ✅ 支援 |
| [`flutter drive` 直接運行](#單次測試) | ✅ 支援（需佔位 app） | ✅ 支援 |
| 本專案自動化腳本 | ❌ 不支援 | ✅ 支援 |
| 開發者信任問題 | ⚠️ 需要佔位 app 解決 | ✅ 無此問題 |

**建議：**
- **免費帳號**：使用 [`flutter drive`](#單次測試) + 佔位 app 方案
- **付費帳號**：可使用本專案的所有自動化腳本

---

## 效能測試流程

本專案包含自動化測試腳本，可執行完整的構建和效能測試流程：

1. 構建高效/低效版本的 IPA 檔案
2. 運行效能測試並收集結果
3. 生成詳細報告

## 如何使用

### 運行完整測試流程

> ⚠️ **iOS 注意**：完整測試流程使用 pre-build IPA 功能，需要**付費的 Apple 開發者帳號**。免費帳號請使用「單次測試」章節的 `flutter drive` 命令。

```bash
# iOS 測試流程（需要付費 Apple 開發者帳號）
./scripts/run_all.sh --platform ios

# Android 測試流程
./scripts/run_all.sh --platform android
```

此命令會執行完整的測試流程，包括構建 IPA/APK 檔案、運行效能測試，並生成報告。

### 完整測試流程日志示例

#### iOS 完整測試流程成功日志（2025年11月7日）

```bash
./scripts/run_all.sh --platform ios

# ===== Flutter 效能測試全流程 =====
# 平台: ios
# 1. 構建測試二進制檔案
# 2. 運行效能測試
# 3. 生成測試報告

# ===== 步驟 1: 構建二進制檔案 =====
# ===== 開始動態構建IPA檔案 =====
# 找到 2 個測試檔案：
# - efficient_list_test.dart
# - inefficient_list_test.dart

# ===== 構建 efficient_list_test IPA =====
# Archiving com.example.studyFlutterPerformanceTest...
# Automatically signing iOS for device deployment using specified development team in Xcode project: AL869FRMV6
# Running Xcode build...
# Xcode archive done.                                         13.5s
# ✓ Built build/ios/archive/Runner.xcarchive (32.1MB)
# Building debugging IPA...                                           8.2s
# ✓ Built IPA to build/ios/ipa (8.9MB)
# efficient_list_test IPA已構建
# 構建時間: 00:00:24
# efficient_list_test IPA已備份到: build/efficient_list_test_ipa/

# ===== 構建 inefficient_list_test IPA =====
# Archiving com.example.studyFlutterPerformanceTest...
# Automatically signing iOS for device deployment using specified development team in Xcode project: AL869FRMV6
# Running Xcode build...
# Xcode archive done.                                         10.4s
# ✓ Built build/ios/archive/Runner.xcarchive (32.1MB)
# Building debugging IPA...                                           8.1s
# ✓ Built IPA to build/ios/ipa (8.9MB)
# inefficient_list_test IPA已構建
# 構建時間: 00:00:21
# inefficient_list_test IPA已備份到: build/inefficient_list_test_ipa/

# ===== IPA構建完成 =====
# 總共構建了 2 個測試的 IPA 檔案
# 構建時間總計: 00:00:45

# ===== 步驟 2: 運行效能測試 =====
# 載入 scripts/.env 配置文件
# 使用 scripts/.env 中的 iOS 設備 ID: 00008130-001435102EC0001C
# ===== 開始效能測試 =====
# 將會運行每個測試 1 次
# 平台: ios
# 設備 ID: 00008130-001435102EC0001C

# ===== 運行 efficient_list_test 測試 #1 =====
# Installing and launching...                                         9.5s
# VMServiceFlutterDriver: Connected to Flutter application.
# flutter: 00:00 +0: Test efficient list scrolling performance
# flutter: 00:07 +1: (tearDownAll)
# flutter: 00:07 +2: All tests passed!
# All tests passed.
# efficient_list_test 測試 #1 完成並保存結果
# 測試時間: 00:00:21
# 結果文件路徑: test_results/ios/efficient_list_test/efficient_scrolling_1.timeline_summary.json

# ===== 運行 inefficient_list_test 測試 #1 =====
# Installing and launching...                                         9.2s
# VMServiceFlutterDriver: Connected to Flutter application.
# flutter: 00:00 +0: Test inefficient list scrolling performance
# flutter: 00:31 +1: (tearDownAll)
# flutter: 00:31 +2: All tests passed!
# All tests passed.
# inefficient_list_test 測試 #1 完成並保存結果
# 測試時間: 00:00:46
# 結果文件路徑: test_results/ios/inefficient_list_test/inefficient_scrolling_1.timeline_summary.json

# ===== 測試完成 =====
# 總計運行了 2 個測試檔案，每個檔案 1 次測試
# 總測試時間: 00:01:07
# 所有結果已保存到: test_results/ios/ 目錄

# ===== 步驟 3: 生成測試報告 =====
# 搜尋測試結果目錄...
# 找到 2 個測試目錄：
# - efficient_list_test (找到 1 個結果檔案)
# - inefficient_list_test (找到 1 個結果檔案)
# 生成最終報告...

# ===== 測試結果摘要 =====
# 總共找到 2 個測試目錄
# - efficient_list_test
# - inefficient_list_test

# ===== 全流程完成 =====
# 恭喜！構建和測試流程已全部完成
# 詳細報告已保存到: test_results/performance_report.json
```

**完整流程摘要：**

**步驟 1: 構建階段**
- efficient_list_test IPA：24 秒
- inefficient_list_test IPA：21 秒
- 構建總時間：45 秒

**步驟 2: 測試階段**
- efficient_list_test：21 秒（實際測試 7 秒）
- inefficient_list_test：46 秒（實際測試 31 秒）
- 測試總時間：1 分 7 秒

**步驟 3: 報告生成**
- 成功生成 performance_report.json
- 包含所有測試結果的詳細數據

**總時長：** 約 1 分 52 秒（45秒構建 + 67秒測試）

**關鍵觀察：**
- 完整流程自動化，無需手動干預
- inefficient 版本測試時間是 efficient 版本的 **2.2 倍**（46秒 vs 21秒）
- 實際測試執行時間差距更明顯：**4.4 倍**（31秒 vs 7秒）
- 所有測試均通過，結果已保存到對應目錄

### 只構建 IPA/APK 檔案

> ⚠️ **iOS 注意**：構建 IPA 功能需要**付費的 Apple 開發者帳號**。免費帳號請使用「單次測試」章節的 `flutter drive` 命令。

```bash
# 構建 iOS IPA 檔案（需要付費 Apple 開發者帳號）
./scripts/build_ipa.sh

# 構建 Android APK 檔案
./scripts/build_apk.sh
```

此命令會分別構建高效版本和低效版本的 IPA/APK 檔案，並記錄構建時間。

### 構建日志示例

#### iOS IPA 構建成功日志（2025年11月7日）

```bash
# 清理項目
fvm flutter clean
# Cleaning Xcode workspace...                                      1,219ms
# Cleaning Xcode workspace...                                      1,743ms
# Deleting build...                                                  291ms
# Deleting .dart_tool...                                             287ms

# 構建 IPA 檔案
./scripts/build_ipa.sh

# ===== 開始動態構建IPA檔案 =====
# 找到 2 個測試檔案：
# - efficient_list_test.dart
# - inefficient_list_test.dart

# ===== 構建 efficient_list_test IPA =====
# Archiving com.example.studyFlutterPerformanceTest...
# Automatically signing iOS for device deployment using specified development team in Xcode project: AL869FRMV6
# Running Xcode build...
# Xcode archive done.                                         15.8s
# ✓ Built build/ios/archive/Runner.xcarchive (32.1MB)
# Building debugging IPA...                                           7.5s
# ✓ Built IPA to build/ios/ipa (8.9MB)
# efficient_list_test IPA已構建: /Users/wingchan/Project/Learning/Flutter/study_flutter_performance_test/build/ios/ipa/study_flutter_performance_test.ipa
# 構建時間: 00:00:25
# efficient_list_test IPA已備份到: build/efficient_list_test_ipa/

# ===== 構建 inefficient_list_test IPA =====
# Archiving com.example.studyFlutterPerformanceTest...
# Automatically signing iOS for device deployment using specified development team in Xcode project: AL869FRMV6
# Running Xcode build...
# Xcode archive done.                                         14.3s
# ✓ Built build/ios/archive/Runner.xcarchive (32.1MB)
# Building debugging IPA...                                           7.5s
# ✓ Built IPA to build/ios/ipa (8.9MB)
# inefficient_list_test IPA已構建: /Users/wingchan/Project/Learning/Flutter/study_flutter_performance_test/build/ios/ipa/study_flutter_performance_test.ipa
# 構建時間: 00:00:25
# inefficient_list_test IPA已備份到: build/inefficient_list_test_ipa/

# ===== IPA構建完成 =====
# 總共構建了 2 個測試的 IPA 檔案
# 構建時間總計: 00:00:50
# 構建時間詳情已保存到: /Users/wingchan/Project/Learning/Flutter/study_flutter_performance_test/test_results/build_times.json
# 可以運行 './scripts/run_performance_tests.sh' 開始測試
```

**構建摘要：**
- efficient_list_test IPA：25 秒
- inefficient_list_test IPA：25 秒
- 總構建時間：50 秒
- 構建產物大小：8.9MB（每個 IPA）
- Archive 大小：32.1MB

### 只運行效能測試

> ⚠️ **iOS 注意**：此命令使用 pre-build IPA 功能，需要**付費的 Apple 開發者帳號**。免費帳號請使用「單次測試」章節的 `flutter drive` 命令。

```bash
# 運行 iOS 測試（需要付費 Apple 開發者帳號）
./scripts/run_performance_tests.sh --platform ios

# 運行 Android 測試
./scripts/run_performance_tests.sh --platform android
```

此命令會使用現有的 IPA/APK 檔案執行效能測試，並收集結果。測試會使用在 `scripts/.env` 中配置的設備 ID。

### 測試運行日志示例

#### iOS 效能測試運行成功日志（2025年11月7日）

```bash
./scripts/run_performance_tests.sh --platform ios

# 載入 scripts/.env 配置文件
# 設定環境變數: IOS_DEVICE_ID
# 設定環境變數: ANDROID_DEVICE_ID
# 使用 scripts/.env 中的 iOS 設備 ID: 00008130-001435102EC0001C
# ===== 開始效能測試 =====
# 將會運行每個測試 1 次
# 平台: ios
# 設備 ID: 00008130-001435102EC0001C
# 找到 2 個測試檔案：
# - efficient_list_test.dart
# - inefficient_list_test.dart

# ===== 運行 efficient_list_test 測試 =====
# 使用二進制檔案: /Users/wingchan/Project/Learning/Flutter/study_flutter_performance_test/build/efficient_list_test_ipa/study_flutter_performance_test.ipa
# driver_file: /Users/wingchan/Project/Learning/Flutter/study_flutter_performance_test/test_driver/efficient_list_test_driver.dart

# ===== 運行 efficient_list_test 測試 #1 =====
# Resolving dependencies... 
# Got dependencies!
# Installing and launching...                                         9.3s
# VMServiceFlutterDriver: Connecting to Flutter application at http://127.0.0.1:62487/iQ1Joz40HsI=/
# VMServiceFlutterDriver: Isolate found with number: 1808562034494311
# VMServiceFlutterDriver: Connected to Flutter application.
# flutter: 00:00 +0: Test efficient list scrolling performance
# flutter: 00:07 +1: (tearDownAll)
# flutter: 00:07 +2: All tests passed!
# All tests passed.
# RESULT_FILE: build/efficient_scrolling.timeline_summary.json
# TARGET_FILE: test_results/ios/efficient_list_test/efficient_scrolling_1.timeline_summary.json
# efficient_list_test 測試 #1 完成並保存結果
# 測試時間: 00:00:21
# 結果文件路徑: test_results/ios/efficient_list_test/efficient_scrolling_1.timeline_summary.json

# ===== 運行 inefficient_list_test 測試 =====
# 使用二進制檔案: /Users/wingchan/Project/Learning/Flutter/study_flutter_performance_test/build/inefficient_list_test_ipa/study_flutter_performance_test.ipa
# driver_file: /Users/wingchan/Project/Learning/Flutter/study_flutter_performance_test/test_driver/inefficient_list_test_driver.dart

# ===== 運行 inefficient_list_test 測試 #1 =====
# Resolving dependencies... 
# Got dependencies!
# Installing and launching...                                         9.2s
# VMServiceFlutterDriver: Connecting to Flutter application at http://127.0.0.1:62641/nbW8v3LlAmg=/
# VMServiceFlutterDriver: Isolate found with number: 8849909928030975
# VMServiceFlutterDriver: Connected to Flutter application.
# flutter: 00:00 +0: Test inefficient list scrolling performance
# flutter: 00:31 +1: (tearDownAll)
# flutter: 00:31 +2: All tests passed!
# All tests passed.
# RESULT_FILE: build/inefficient_scrolling.timeline_summary.json
# TARGET_FILE: test_results/ios/inefficient_list_test/inefficient_scrolling_1.timeline_summary.json
# inefficient_list_test 測試 #1 完成並保存結果
# 測試時間: 00:00:46
# 結果文件路徑: test_results/ios/inefficient_list_test/inefficient_scrolling_1.timeline_summary.json
```

**測試摘要：**
- **efficient_list_test**：
  - 測試時間：21 秒
  - 實際測試執行時間：7 秒（flutter 測試部分）
  - 安裝和啟動時間：9.3 秒
  - 狀態：✓ 所有測試通過
  - 結果文件：`test_results/ios/efficient_list_test/efficient_scrolling_1.timeline_summary.json`

- **inefficient_list_test**：
  - 測試時間：46 秒
  - 實際測試執行時間：31 秒（flutter 測試部分）
  - 安裝和啟動時間：9.2 秒
  - 狀態：✓ 所有測試通過
  - 結果文件：`test_results/ios/inefficient_list_test/inefficient_scrolling_1.timeline_summary.json`

**效能對比觀察：**
- inefficient 版本的測試執行時間（31秒）明顯長於 efficient 版本（7秒），**差距約 4.4 倍**
- 這顯示了低效實現對滾動效能的顯著影響

## 測試結果檔案

測試完成後，會在 `test_results/[平台名稱]/` 目錄中生成以下檔案：

- `efficient_scrolling_1.timeline_summary.json` - 高效版本測試結果摘要
- `inefficient_scrolling_1.timeline_summary.json` - 低效版本測試結果摘要
- `performance_report.json` - 完整測試報告
- `build_times.json` - 構建時間記錄

不同平台的結果會分別保存在對應的目錄中：
- iOS 測試結果：`test_results/ios/`
- Android 測試結果：`test_results/android/`

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
- 必須在 `scripts/.env` 文件中設定測試設備的 ID
- iOS 設備 ID 可以透過 `xcrun xctrace list devices` 獲取
- Android 設備需要連接並啟用 USB 調試，設備 ID 可以通過 `adb devices` 獲取
- 請確保 Android 設備已經在開發者選項中啟用 USB 調試模式

### ⚠️ 重要限制：免費 Apple 開發者帳號

> 💡 **完整說明請參閱文檔最上方的「[免費 Apple 開發者帳號限制與解決方案](#️-重要免費-apple-開發者帳號限制與解決方案)」章節**
> 
> 該章節包含：
> - Pre-build IPA 功能限制
> - 開發者信任問題的詳細說明
> - **佔位 App 解決方案**（避免每次測試都要重新信任）
> - 免費 vs 付費帳號功能對比表

**快速摘要：**

- ❌ **免費帳號不支援**：`flutter build ipa` + `flutter drive --use-application-binary`
- ✅ **免費帳號可使用**：[`flutter drive` 直接運行](#單次測試)（配合佔位 app）
- 📦 **本專案的自動化腳本**需要付費 Apple 開發者帳號

## 效能測試說明

本專案包含兩個獨立的集成測試，用於分別測量優化版本和低效能版本的滾動效能：

1. `efficient_list_test.dart` - 測試優化版本列表的滾動效能
2. `inefficient_list_test.dart` - 測試低效能版本列表的滾動效能

## 運行測試

### 單次測試

#### 測試 iOS 上的優化版本

```bash
fvm flutter drive \
  --driver=test_driver/efficient_list_test_driver.dart \
  --target=integration_test/efficient_list_test.dart \
  --no-dds \
  --profile \
  -d 00008130-001435102EC0001C
```

#### 測試 iOS 上的低效能版本

```bash
fvm flutter drive \
  --driver=test_driver/inefficient_driver.dart \
  --target=integration_test/inefficient_list_test.dart \
  --no-dds \
  --profile \
  -d 00008130-001435102EC0001C
```

#### 測試 Android 上的優化版本

```bash
fvm flutter drive \
  --driver=test_driver/efficient_driver.dart \
  --target=integration_test/efficient_list_test.dart \
  --no-dds \
  --profile \
  -d 39181FDJG006N3
```

#### 測試 Android 上的低效能版本

```bash
fvm flutter drive \
  --driver=test_driver/inefficient_driver.dart \
  --target=integration_test/inefficient_list_test.dart \
  --no-dds \
  --profile \
  -d 39181FDJG006N3
```

### 批量測試

> ⚠️ **iOS 注意**：批量測試腳本使用 pre-build IPA 功能，需要**付費的 Apple 開發者帳號**。免費帳號請使用上方「單次測試」的 `flutter drive` 命令。

我們也提供了一個腳本，可以自動連續執行多次測試，並整理結果：

```bash
# 確保腳本有執行權限
chmod +x ./scripts/run_all.sh

# 執行完整測試流程（構建二進制檔案並運行測試）
./scripts/run_all.sh --platform ios    # 運行 iOS 測試（需要付費 Apple 開發者帳號）
./scripts/run_all.sh --platform android  # 運行 Android 測試

# 或者單獨執行各個步驟
./scripts/build_ipa.sh          # 僅構建 iOS IPA 檔案（需要付費 Apple 開發者帳號）
./scripts/build_apk.sh          # 僅構建 Android APK 檔案
./scripts/run_performance_tests.sh --platform ios    # 僅運行 iOS 測試(需要已構建的 IPA，需要付費帳號)
./scripts/run_performance_tests.sh --platform android  # 僅運行 Android 測試(需要已構建的 APK)
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

> ⚠️ **重要提醒：此功能需要付費的 Apple 開發者帳號**
> 
> 免費的 Apple 開發者帳號**無法使用** pre-build IPA 功能！
> 使用免費帳號的開發者請使用 `flutter drive` 直接運行測試（參見上方「單次測試」章節）。
> 
> 詳細說明請參閱「注意事項」中的「免費 Apple 開發者帳號」章節。

## iOS 平台

### Pre-build IPA

> ⚠️ **此功能僅適用於付費 Apple 開發者帳號**
```bash
fvm flutter build ipa \
--target=integration_test/inefficient_list_test.dart \
--profile \
--export-method development
```

### Run test with pre-build IPA
```bash
# `--target` option seems can be ignored because the `build ipa` command already specifies the target.
fvm flutter drive \
  --driver=test_driver/inefficient_list_test_driver.dart \
  --target=integration_test/inefficient_list_test.dart \
  --no-dds \
  --profile \
  --use-application-binary /Users/wingchan/Project/Learning/Flutter/study_flutter_performance_test/build/inefficient_list_test_ipa/study_flutter_performance_test.ipa \
  -d 00008130-001435102EC0001C

fvm flutter drive \
  --driver=test_driver/efficient_list_test_driver.dart \
  --target=integration_test/efficient_list_test.dart \
  --no-dds \
  --profile \
  --use-application-binary /Users/wingchan/Project/Learning/Flutter/study_flutter_performance_test/build/efficient_list_test_ipa/study_flutter_performance_test.ipa \
  -d 00008130-001435102EC0001C

```

## Android 平台

### Pre-build APK
```bash
fvm flutter build apk \
--target=integration_test/inefficient_list_test.dart \
--profile
```

### Run test with pre-build APK
```bash
fvm flutter drive \
  --driver=test_driver/inefficient_list_test_driver.dart \
  --target=integration_test/inefficient_list_test.dart \
  --no-dds \
  --profile \
  --use-application-binary /Users/wingchan/Project/Learning/Flutter/study_flutter_performance_test/build/app/outputs/flutter-apk/app-profile.apk \
  -d 39181FDJG006N3
```

## 通用測試指令

### If no need TimelineSummary, just run test (don't support pre-build binary)
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

## 配置設備 ID

為了方便測試，必須通過 `scripts/.env` 文件設置 iOS 和 Android 設備的 ID。

### 設置方法

1. 複製 `scripts/.env.template` 文件為 `scripts/.env`：

```bash
cp scripts/.env.template scripts/.env
```

2. 編輯 `scripts/.env` 文件，填入你的設備 ID：

```bash
# 設備 ID 環境設定

# iOS 設備 ID (可通過 xcrun xctrace list devices 獲取)
IOS_DEVICE_ID=你的iOS設備ID

# Android 設備 ID (可通過 adb devices 獲取)
ANDROID_DEVICE_ID=你的Android設備ID
```

3. 獲取設備 ID 的方法：
   - iOS 設備：執行 `xcrun xctrace list devices` 命令
   - Android 設備：執行 `adb devices` 命令

所有測試腳本現在都必須使用 `.env` 文件中設定的設備 ID，不再支援自動檢測或手動輸入設備 ID。
