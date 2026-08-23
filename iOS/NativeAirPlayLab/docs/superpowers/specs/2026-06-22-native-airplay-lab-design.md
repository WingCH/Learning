# Native AirPlay Lab 設計

## 背景

此 project 是全新的 iOS native AirPlay 測試 app，用來快速驗證 iPhone / iPad 上的系統 AirPlay 路由選擇與影片播放流程。實作方向參考 OpenAI Codex「Build for iOS」use case：先以 greenfield SwiftUI app scaffold，保持 `xcodebuild` CLI-first build loop，第一版不引入 Tuist、XcodeBuildMCP 或其他額外自動化工具。

官方參考：<https://developers.openai.com/codex/use-cases/native-ios-apps>

## 目標

- 建立 `/Users/wingchan/Project/NativeAirPlayLab` 作為獨立 iOS project。
- 使用 SwiftUI 建立 iPhone / iPad app。
- 使用 `AVPlayer` 播放測試影片。
- 使用 native `AVRoutePickerView` 提供 AirPlay 選擇入口。
- 提供 `scripts/build-and-launch.sh`，讓 Codex 或人手都可以透過 CLI build 並啟動 simulator。
- 保持第一版可讀、可改、可用於真機 AirPlay 測試。

## 非目標

- 不做自訂 AirPlay protocol 或私有 API。
- 不做 DRM、FairPlay、字幕、多音軌或播放清單。
- 不做 App Store 發佈設定。
- 不在第一版加入 Tuist、XcodeBuildMCP 或第三方 dependency。
- 不承諾 simulator 可以完成 AirPlay 投放驗證；實際投放需要真機與同網路 AirPlay receiver。

## 推薦方案

採用 SwiftUI app + `AVPlayer` + `AVRoutePickerView` bridge。

此方案足夠貼近實際 native AirPlay 使用情境，同時保持 scaffold 小而清楚。SwiftUI 負責主畫面與狀態展示，UIKit bridge 只包住 `AVRoutePickerView`，避免把整個播放器改成 UIKit 架構。

## 架構

- `NativeAirPlayLabApp`
  - App 入口。
- `ContentView`
  - 顯示播放器、AirPlay route picker、播放控制、目前測試 URL 與簡短狀態。
- `AirPlayRoutePicker`
  - `UIViewRepresentable` wrapper，包裝 `AVRoutePickerView`。
- `PlayerView`
  - SwiftUI wrapper，顯示 `AVPlayer` 影片內容。
- `scripts/build-and-launch.sh`
  - CLI build / boot simulator / install / launch 流程。

## 使用者流程

1. 使用者開啟 app。
2. App 載入預設測試影片 URL。
3. 使用者可以播放或暫停影片。
4. 使用者點擊 AirPlay button 開啟系統 route picker。
5. 真機環境下，使用者選擇 AirPlay receiver 後由系統處理投放。

## 驗證方式

- 先用 `xcodebuild -list` 確認 project 與 scheme 可被 CLI 讀取。
- 用 `xcodebuild build` 驗證 app 可編譯。
- 用 build-and-launch script 驗證 simulator 可安裝與啟動 app。
- 若有 booted simulator，可用 `simctl launch` 做最小啟動驗證。
- AirPlay 實際投放驗證需在真機執行，並連到同網路 AirPlay receiver。

## 風險與限制

- Simulator 不等同真機 AirPlay 能力，只能驗證基本 build 與 UI。
- AirPlay receiver 可見性受 Wi-Fi、Bonjour、隔離網路與裝置權限影響。
- 測試影片 URL 若失效，app 需要改用新的公開 MP4 / HLS URL。
- `AVRoutePickerView` 的實際彈窗與 route 狀態由系統控制，app 只能提供入口與播放狀態。
