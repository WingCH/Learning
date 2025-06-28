# Flutter 巢狀橫向滾動手勢傳遞問題研究

## 📋 專案概述

本專案用於研究和解決 Flutter 中巢狀橫向滾動元件的手勢傳遞問題。當內層滾動元件滾動到邊緣時，無法順暢地將滑動手勢傳遞給外層滑動元件，影響使用者體驗。

## 🔍 問題描述

### 場景設定
- **外層元件**：`flutter_slidable` 的 `Slidable` 元件（支援橫向滑動顯示操作選單）
- **內層元件**：`SingleChildScrollView` 設定為橫向滾動（顯示水平列表）

### 問題現象
當使用者在內層橫向列表中滑動到最左或最右邊緣後，繼續滑動的手勢無法自動傳遞到外層的 `Slidable` 元件，導致：
1. 無法觸發 `Slidable` 的滑動操作
2. 使用者體驗不連貫，需要重新開始滑動手勢

### 技術原因
Flutter 的手勢識別系統在處理巢狀滾動時，內層滾動元件會持續攔截手勢，即使已經到達滾動邊界。

## 📁 專案結構

```
lib/
├── main.dart                    # 問題展示（原始問題重現）
├── solution1_gesture_detector.dart    # 解決方案 1：使用 GestureDetector
├── solution2_notification.dart        # 解決方案 2：使用 ScrollNotification
├── solution3_custom_physics.dart      # 解決方案 3：自定義 ScrollPhysics
└── solution4_nested_scroll.dart       # 解決方案 4：使用 NestedScrollView

test/
└── scroll_behavior_test.dart    # 滾動行為測試
```

## 🎯 問題重現步驟

1. 執行 `fvm flutter run`
2. 在內層橫向列表中向左滑動直到到達最右邊
3. 繼續向左滑動，觀察是否能觸發外層 Slidable 的動作面板
4. 發現：手勢被內層滾動元件持續攔截，無法傳遞到外層

## 💡 解決方案概覽

### Solution 1: GestureDetector 手勢控制
- **檔案**：`solution1_gesture_detector.dart`
- **原理**：使用 GestureDetector 包裝內層滾動元件，手動管理手勢傳遞
- **優點**：直接控制手勢行為
- **缺點**：實作複雜，需要處理各種邊界情況

### Solution 2: ScrollNotification 監聽
- **檔案**：`solution2_notification.dart`
- **原理**：監聽滾動通知，在到達邊界時動態調整手勢處理
- **優點**：利用 Flutter 內建機制
- **缺點**：可能需要額外狀態管理

### Solution 3: 自定義 ScrollPhysics
- **檔案**：`solution3_custom_physics.dart`
- **原理**：建立自定義的 ScrollPhysics，在邊界時改變滾動行為
- **優點**：更自然的滾動體驗
- **缺點**：需要深入理解 ScrollPhysics 運作機制

### Solution 4: NestedScrollView 方案
- **檔案**：`solution4_nested_scroll.dart`
- **原理**：使用 Flutter 的 NestedScrollView 處理巢狀滾動
- **優點**：官方支援的巢狀滾動解決方案
- **缺點**：可能需要調整現有佈局結構

## 🚀 如何使用

### 查看原始問題
```bash
fvm flutter run
```

### 測試不同解決方案
```bash
# 修改 main.dart 中的 import 來測試不同方案
# 例如：import 'solution1_gesture_detector.dart';
fvm flutter run
```

## 📊 方案對比

| 方案 | 複雜度 | 效能影響 | 相容性 | 推薦場景 |
|------|--------|----------|--------|----------|
| GestureDetector | 高 | 中 | 好 | 需要精細控制 |
| ScrollNotification | 中 | 低 | 好 | 一般應用 |
| Custom ScrollPhysics | 高 | 低 | 優 | 追求自然體驗 |
| NestedScrollView | 低 | 低 | 需調整 | 標準巢狀滾動 |

## 🔗 相關資源

- [Flutter Gestures 文檔](https://flutter.dev/docs/development/ui/advanced/gestures)
- [flutter_slidable 套件](https://pub.dev/packages/flutter_slidable)
- [ScrollPhysics 深入解析](https://flutter.dev/docs/development/ui/advanced/scrolling)

## 📝 筆記

此專案僅用於學習和研究目的，展示了 Flutter 中處理複雜手勢互動的不同方法。實際專案中應根據具體需求選擇合適的解決方案。
