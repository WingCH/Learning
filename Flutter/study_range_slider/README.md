# Custom Range Slider Demo

這個專案展示了如何在 Flutter 中實現一個自定義的 RangeSlider，特別解決了以下問題：

## 主要功能

1. **選擇性的值指示器顯示**
   - 只在當前操作的滑塊上顯示值指示器
   - 另一個滑塊的值指示器保持隱藏
   - 提供更清晰的視覺反饋

2. **自定義值指示器樣式**
   - 實現了矩形樣式的值指示器
   - 提供更好的可讀性和視覺效果
   - 支援自定義顏色和大小

## 技術實現

### 核心問題解決
1. **滑塊識別**
   - 透過計算觸摸位置與滑塊的距離來判斷用戶正在操作哪個滑塊
   - 在拖動開始時準確識別目標滑塊

2. **值指示器控制**
   - 使用自定義的 `CustomRectangularRangeSliderValueIndicatorShape`
   - 根據當前活動的滑塊來控制值指示器的顯示

### 關鍵元件
1. **CustomRectangularRangeSliderValueIndicatorShape**
   - 繼承自 `RangeSliderValueIndicatorShape`
   - 實現自定義的矩形指示器繪製邏輯
   - 支援動態顯示/隱藏

2. **事件處理**
   - `onPanDown`: 識別初始滑塊
   - `onChanged`: 更新滑塊值
   - `onChangeEnd`: 重置活動狀態

## 使用方式

```dart
SliderTheme(
  data: SliderTheme.of(context).copyWith(
    rangeValueIndicatorShape: CustomRectangularRangeSliderValueIndicatorShape(_activeThumb),
    showValueIndicator: ShowValueIndicator.always,
  ),
  child: RangeSlider(
    values: _currentRangeValues,
    // ... 其他配置
  ),
)
```

## 調試功能

專案包含完整的調試輸出，可以追踪：
- 滑塊選擇過程
- 值的變化
- 值指示器的繪製狀態

## 注意事項

1. 確保在使用時正確處理滑塊的狀態
2. 注意性能優化，特別是在繪製值指示器時
3. 考慮邊界情況的處理

## 未來改進方向

1. 支援更多自定義樣式
2. 添加動畫效果
3. 優化觸摸判斷邏輯
4. 支援更多的交互方式
