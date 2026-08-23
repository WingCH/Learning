# Native AirPlay Lab XcodeGen 轉換設計

## 目標

將 `NativeAirPlayLab.xcodeproj` 改為由 XcodeGen 產生，避免再手動維護 `.pbxproj`。現有 SwiftUI、AVKit、AirPlay 診斷、測試、README 與 build script 保留。

## 決策

- `project.yml` 作為 Xcode project 結構與 build settings 的 source of truth。
- `NativeAirPlayLab.xcodeproj` 繼續 commit，方便直接用 Xcode 開啟；但它是 generated artifact。
- App target 使用 automatic signing，Team 固定為 `AL869FRMV6`。
- Unit test target 維持 hostless test bundle：測試 target 直接編入 `PlaybackConfiguration.swift`、`AirPlayRoutePicker.swift`、`MediaPlaybackConfiguration.swift`，避開目前本機 XCTest runner host app 不穩定問題。
- `scripts/generate-xcodeproj.sh` 包裝 `xcodegen generate`，先檢查 CLI 是否存在。

## 成功條件

- `xcodegen generate` 可以重新產生 `NativeAirPlayLab.xcodeproj`。
- `xcodebuild -list` 顯示 scheme `NativeAirPlayLab`。
- simulator app build 通過。
- simulator `build-for-testing` 通過。
- generic iphoneos build 通過，且 `.app` code signature 驗證有效。
- README 交代 XcodeGen workflow。
