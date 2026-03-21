# Topographic Shader Study

呢個專案係將你提供嘅原始檔案 [topographic.html](./topographic.html) 轉成 Flutter web 版本。最後成品保留咗原本嘅 topographic contour 視覺、滑鼠 elevation / valley 互動，同時提供一個 `Shader` 開關，方便直接比較「有 shader 背景」同「淨 Dart contour」兩種效果。

## 參考來源

### 視覺來源

- 主視覺來源唔係我另外抄返嚟嘅公開網站，而係你提供、而家已經收進 project 嘅原始檔案 [topographic.html](./topographic.html)。
- 我實際上係根據呢個 HTML 裏面嘅：
  - `simplex noise`
  - `fbm`
  - `marching squares`
  - glow / sharp 雙層 contour
  - label placement
  - pointer interaction
  去重建 Flutter 版本。

### 技術來源

- Flutter shader 實作流程參考 Flutter 官方文件：
  - Context7 `flutter/website` fragment shaders 指南
  - Context7 `api_flutter_dev` 關於 `FragmentProgram` / `FragmentShader` 的 API 說明
- `Switch` 控件與 Material overlay 寫法亦依照 Flutter 官方 widget 用法處理。

簡單講：

- 設計來源：你提供嘅 `topographic.html`
- 技術來源：Flutter 官方文件
- 唔係照搬另一個網站成頁複製

## 心路歷程

### 1. 一開始我判斷錯咗原始效果嘅本質

你一開始講得好清楚：要 Flutter web，而且要用 `Shader`。

所以我第一個方向係：

- 用 fullscreen fragment shader 重做成個效果
- 將 noise、contour、interaction 都盡量塞入 shader

呢個方向喺需求層面好合理，但後來證明我對原始 HTML 嘅理解有偏差。

原始 HTML 真正嘅核心唔係「每個 pixel 點計色」，而係：

1. 用 `simplex noise + fbm` 生出一個 field
2. 用 `marching squares` 由 field 抽 contour line segments
3. 用 2D canvas 畫 glow / sharp 兩層線條

即係話，原稿本質上係幾何抽線，再唔係純 fragment shader 視覺。

### 2. 第一個難處係 Flutter web 嘅 shader runtime 冇我預期咁直接

我一開始想用舊式 web 啟動方法處理 renderer，但你呢個環境用嘅 Flutter 3.38.7 已經唔再接受 `--web-renderer`。

之後直接用：

```bash
fvm flutter run -d chrome
```

又見到 `RuntimeEffect error`。

呢一步令我確認：

- 問題唔係 app structure
- 問題係 web 端 shader runtime 同我原先假設唔一致

最後改用：

```bash
fvm flutter run -d chrome --wasm
```

web 啟動穩定咗，但仍然未解決主畫面效果。

### 3. 第二個難處係畫面雖然開到，但幾乎全黑

就算 app 成功起到，實際畫面都只係見到 `Topographic` 同右下角文案，背景幾乎全黑。

呢個情況說明兩件事：

- app 冇死
- shader 亦唔係完全冇執行

但我最初個 shader-only 方案只係做「近似 contour」，唔係真正重新實作 `marching squares`。

原始 HTML 的 contour 係由格點資料抽線得出，線條結構本身係演算法結果。  
我第一版 shader 只係用 noise + contour mask 去模擬，喺真實 Chrome / Flutter web 呈現下，對比度同穩定性都唔夠，所以畫面睇落接近冇畫。

### 4. 真正轉捩點係我改咗架構，而唔係只係改參數

後來我唔再死守「全部都要 shader 畫」。

我改成 hybrid：

- `Shader` 保留，用嚟做背景氣氛
  - 深色底
  - subtle noise
  - vignette
- Dart `CustomPainter` 重建原始主體
  - `_SimplexNoise3d`
  - `fbm`
  - field normalization
  - `marching squares`
  - glow / sharp contour
  - label placement
  - pointer 擾動

呢一步先係真正令畫面變得穩定而且似原稿。

### 5. 點解之後就得咗

因為責任分工終於正確：

- shader 做佢擅長嘅：背景氛圍
- Dart painter 做佢擅長嘅：抽 contour 幾何同畫線

原始 HTML 本身都係 CPU 端抽線再畫 canvas。  
而家 Flutter 版本只係用同樣思路搬去 Flutter `Canvas`，自然會比「全 shader 模擬」更穩定。

### 6. 最後我加咗 `Shader` 開關

因為你想直接比較效果，所以我再加咗一個右上角 `Shader` 開關：

- 開：shader 背景 + Dart contour
- 關：淨 Dart contour + fallback background

呢個開關本身好有用，因為佢可以直接證明：

- 主體 contour 已經唔再依賴 web shader 生存
- shader 而家係加分項，而唔係單點失效點

## 現況

- 主體 contour：Dart `CustomPainter`
- 背景氣氛：Flutter fragment shader
- 比較控制：右上角 `Shader` switch
- 啟動建議：

```bash
fvm flutter run -d chrome --wasm
```

## 驗證

以下檢查已通過：

```bash
fvm flutter analyze
fvm flutter test
```
