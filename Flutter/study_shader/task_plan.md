# Task Plan: Flutter Web Topographic Shader

## Goal
將 `/Users/wingchan/Downloads/topographic.html` 轉寫成 Flutter web 版本，並以 Flutter fragment shader 重現主要 topographic contour 動態視覺與互動。

## Current Phase
Phase 5

## Phases

### Phase 1: Requirements & Discovery
- [x] Understand user intent
- [x] Identify constraints and requirements
- [x] Document findings in findings.md
- **Status:** complete

### Phase 2: Planning & Structure
- [x] Define technical approach
- [x] Create project structure if needed
- [x] Document decisions with rationale
- **Status:** complete

### Phase 3: Implementation
- [x] Execute the plan step by step
- [x] Write code to files before executing
- [x] Test incrementally
- **Status:** complete

### Phase 4: Testing & Verification
- [x] Verify all requirements met
- [x] Document test results in progress.md
- [x] Fix any issues found
- **Status:** complete

### Phase 5: Delivery
- [x] Review all output files
- [x] Ensure deliverables are complete
- [ ] Deliver to user
- **Status:** in_progress

## Key Questions
1. 用 shader 還原時，哪些效果必須保留，哪些可以改用近似算法？
2. Flutter web 現況下，fragment shader 需要哪些 asset/config 才能正常載入？
3. 專案目前沒有 `web/` 目錄，應如何最小代價補上 web platform？

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 先研究原始 HTML 與 Flutter shader 官方文件 | 避免直接實作後撞 API 或 web renderer 限制 |
| 以 fullscreen fragment shader 重現 contour 主效果 | 滿足「要用 Shader」且最接近原本即時背景視覺 |
| 補 `web/` 平台並直接用 `fvm flutter run -d chrome` 啟動 | Flutter 3.38 的 `flutter run` 已無 `--web-renderer` 可用，先採用當前預設 web 啟動流程 |

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
| 初次讀取 planning-with-files skill 用錯路徑 | 1 | 改讀 `/Users/wingchan/.codex/skills/planning-with-files/SKILL.md` |
| `PointerExitEvent` 類型在目前匯入組合下無法解析 | 1 | 改成 `MouseRegion(onExit: (_) => ...)`，避免顯式依賴該型別 |
| `fvm flutter run -d chrome --web-renderer canvaskit` 失敗 | 1 | 查 `fvm flutter run -h`，確認 Flutter 3.38 已不接受該 flag，改用 `fvm flutter run -d chrome` |

## Notes
- 必須使用 `fvm` 前綴執行 Flutter 命令
- 禁止執行 `fvm flutter build` 類建置命令
- 需要遵守 shader asset 宣告與 web scaffold 流程
