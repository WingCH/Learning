# Findings & Decisions

## Requirements
- 將 `/Users/wingchan/Downloads/topographic.html` 改寫成 Flutter web 版本
- 必須使用 Shader
- 盡量保留原始頁面的 topographic contour 視覺語言
- Flutter 指令必須使用 `fvm` 前綴
- 驗證只能用 `fvm flutter analyze` / `fvm flutter test`，不能用 build

## Research Findings
- 原始 HTML 主要由三部分組成：`fbm/simplex noise` 場、`marching squares` contour 線、以及滑鼠/觸控造成的 elevation 擾動。
- 原始畫面基底是全螢幕深色背景，搭配 amber/coral/gold 線條、glow、vignette，以及左上角 `Topographic` label。
- Flutter 官方 fragment shader 流程是：在 `pubspec.yaml` 的 `flutter.shaders` 宣告 `.frag` 檔，再以 `FragmentProgram.fromAsset(...)` 載入。
- Flutter shader 可以透過 `Paint()..shader = shader` 畫滿整個 canvas；uniform 順序由 GLSL 宣告順序決定，`vecN` 需要逐一 `setFloat`。
- 專案目前沒有 `web/` 目錄，需要補上 web platform scaffold 才能作為 Flutter web 專案。
- Flutter 3.38 的 `flutter run -h` 顯示 web 相關旗標以 `--wasm` 為主，`--web-renderer` 已不再是可直接使用的公開參數。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 使用 fullscreen fragment shader 而非在 Dart 端完整重做 marching squares | 較符合 Flutter shader 能力，也更容易在 web 端保持流暢 |
| 以 shader 近似 contour lines、major/minor 線寬與滑鼠擾動 | 可保留主視覺語言，不需要把原始 JS 演算法逐行搬運 |
| UI label 由 Flutter widget 疊加 | 純文字疊加比放進 shader 更易維護與響應式排版 |
| 保留 shader load fallback 與簡單 fallback painter | 令 widget test 與 shader 載入失敗情況仍可正常顯示基本畫面 |
| 改成「shader 做底、Dart marching squares 畫主體 contour」 | Flutter web shader 在目前環境可作背景，但主線條直接用 Dart 繪製更穩定，而且更接近原始 HTML |
| 加右上角 `Shader` switch 做 A/B 比較 | 用戶可以直接比較「背景 shader 開 / 關」時嘅視覺差異，而唔使重新執行 app |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| `planning-with-files` skill 例子路徑與實際安裝位置不同 | 直接檢查 `~/.codex/skills` 後改用實際 `SKILL.md` 路徑 |
| `PointerExitEvent` 型別導致 analyze/test 失敗 | 改成 closure callback，不在 State method signature 中引用該型別 |
| `--web-renderer` flag 在 Flutter 3.38 不可用 | 依 `flutter run -h` 改採預設 web 啟動方式 |
| 使用者實際畫面幾乎全黑 | 保留 shader 背景，但以 Dart 端重新實作 contour extraction 與 label，避免主效果完全依賴 web shader 呈現 |

## Resources
- Original HTML in project: `/Users/wingchan/Project/Learning/Flutter/study_shader/topographic.html`
- Original source file from Downloads: `/Users/wingchan/Downloads/topographic.html`
- Flutter shader guide: Context7 `/flutter/website` `fragment-shaders.md`
- Flutter API refs: Context7 `/websites/api_flutter_dev`

## Visual/Browser Findings
- 原始畫面不是填色地形，而是黑底上的等高線網絡。
- contour 線有明顯 major/minor 層級，major 線更粗更亮，外面有柔和 glow。
- 滑鼠 hover 會推高地形，按下時會形成 valley；互動半徑大約是短邊的 20%。
- 左上角 label 使用小字 monospace、字距加大、低透明 amber 色。
- Flutter 版本採用 fullscreen shader 疊上 Flutter 文本 HUD，互動文案會按 hover/press 切換成 `Move to elevate` / `Pressing to carve`。
- 使用者截圖顯示：文字 HUD 正常，但背景主視覺幾乎不可見，證明之前的 shader-only 線條方案在實際瀏覽器中唔夠可靠。
- 最新版本右上角提供 `Shader` 開關；關掉後仍會保留 contour 主體，證明主效果已經唔再依賴 shader 生存。
