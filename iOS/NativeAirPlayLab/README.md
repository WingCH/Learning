# Native AirPlay Lab

SwiftUI iOS app，用來測試 Apple 原生 `AVRoutePickerView` 與 `AVPlayer` 的 AirPlay 影片播放流程。

本專案依照 OpenAI Codex native iOS app 工作流建立：保留 Xcode project，並以 `xcodebuild` 和 `xcrun simctl` 作為主要 build、install、launch 迴圈。

## Project Generation

`project.yml` 是 Xcode project 的 source of truth。需要新增 target、調整 signing、改 source membership 或 scheme 時，先修改 `project.yml`，再重新產生 project：

```sh
./scripts/generate-xcodeproj.sh
```

如果本機未安裝 XcodeGen：

```sh
brew install xcodegen
```

`NativeAirPlayLab.xcodeproj` 會一併 commit，方便直接用 Xcode 開啟；但它屬於 generated artifact，review 時應優先檢查 `project.yml`。

## Build

```sh
xcodebuild build -project NativeAirPlayLab.xcodeproj -scheme NativeAirPlayLab -destination 'generic/platform=iOS Simulator'
```

## Launch On Simulator

```sh
./scripts/build-and-launch.sh
```

指定 simulator 名稱：

```sh
DESTINATION_NAME='iPad Pro 11-inch (M4)' ./scripts/build-and-launch.sh
```

指定 simulator UDID：

```sh
DESTINATION_ID='YOUR-SIMULATOR-UDID' ./scripts/build-and-launch.sh
```

## Test Build

```sh
xcodebuild build-for-testing -project NativeAirPlayLab.xcodeproj -scheme NativeAirPlayLab -destination 'generic/platform=iOS Simulator'
```

## AirPlay Notes

Simulator 只適合驗證 build、install、launch 與基本 UI。實際 AirPlay 投放需要使用實體 iPhone 或 iPad，並和 AirPlay receiver 連到同一個網路。

### 關鍵成功位

這個實驗成功不是單靠畫面上有 AirPlay 按鈕，而是幾個條件同時成立：

- `AVRoutePickerView.prioritizesVideoDevices = true`：優先選擇支援影片的 AirPlay 裝置。
- `AVPlayer.allowsExternalPlayback = true`：播放器明確允許外部播放。
- `AVPlayer.usesExternalPlaybackWhileExternalScreenIsActive = true`：外部螢幕或 AirPlay video route 可用時，自動切換同一個 player item。
- `AVAudioSession` 使用 `.playback`、`.moviePlayback`、`.longFormVideo`：向系統表明這是長影片播放，不是一般音訊輸出。
- `AVInitialRouteSharingPolicy = LongFormVideo`：App 啟動時即以 long-form video route sharing 作為初始策略。
- `AVPlayerViewController`：使用 Apple 原生影片播放 controller，保留完整 AirPlay、PiP 和 Now Playing 行為。

判斷是否真的成功，應看 `AVPlayer.isExternalPlaybackActive`，而不是只看 route picker 是否打勾。route picker 打勾只代表已選擇 route；`AirPlay video active` 才代表 AVPlayer 已經切到外部影片播放。

畫面會顯示目前 `AVPlayer.isExternalPlaybackActive` 狀態：

- `AirPlay video active`：iOS 已經把 AVPlayer 切到 external video playback。
- `AirPlay video not active`：route picker 可能已選到裝置，但 AVPlayer 仍未切到外部影片播放；這通常代表目前 route 只接到 audio、receiver 未接受 video，或 Mac 的 AirPlay Receiver 設定未允許該 iPhone。

如果使用 MacBook 作為 receiver，請確認 Mac 已開啟 AirPlay Receiver、兩部裝置在同一網路、Mac 未鎖定，並且 System Settings 允許該 iPhone 使用 AirPlay。

目前 App 使用 Apple 範例 HLS 影片串流：

```text
https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8
```
