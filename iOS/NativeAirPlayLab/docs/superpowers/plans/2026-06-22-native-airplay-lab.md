# Native AirPlay Lab Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立一個可用 `xcodebuild` 編譯與啟動的 SwiftUI iOS app，用來測試 native AirPlay route picker 與影片播放。

**Architecture:** 這是 greenfield SwiftUI app。App 使用 `AVPlayer` 播放固定測試媒體，並以 `UIViewRepresentable` 包裝 `AVRoutePickerView`，讓 UI 保持 SwiftUI-first，但 AirPlay 入口仍使用 Apple 原生元件。

**Tech Stack:** SwiftUI、AVKit、XCTest、Xcode project、`xcodebuild`、`xcrun simctl`

## Global Constraints

- Project path 固定為 `/Users/wingchan/Project/NativeAirPlayLab`。
- App 聚焦 iPhone 與 iPad，不建立共用 macOS target。
- 第一版不加入 Tuist、XcodeBuildMCP 或第三方 dependency。
- Build loop 必須 CLI-first，使用 `xcodebuild`。
- AirPlay 實際投放驗證需要真機與同網路 AirPlay receiver；simulator 只驗證 build、install、launch 與基本 UI。
- 文件使用繁體中文畫面語撰寫。

---

## File Structure

- `NativeAirPlayLab.xcodeproj/project.pbxproj`
  - Xcode project，包含 app target 與 unit test target。
- `NativeAirPlayLab/NativeAirPlayLabApp.swift`
  - SwiftUI app 入口。
- `NativeAirPlayLab/ContentView.swift`
  - 主畫面，組合播放器、AirPlay route picker、播放按鈕與測試 URL。
- `NativeAirPlayLab/PlaybackConfiguration.swift`
  - 提供預設測試媒體 URL。
- `NativeAirPlayLab/AirPlayRoutePicker.swift`
  - `AVRoutePickerView` 的 SwiftUI wrapper。
- `NativeAirPlayLab/Info.plist`
  - App bundle metadata。
- `NativeAirPlayLabTests/PlaybackConfigurationTests.swift`
  - 驗證預設媒體 URL 是有效 HTTPS URL。
- `NativeAirPlayLabTests/AirPlayRoutePickerTests.swift`
  - 驗證 route picker 使用 video route 設定。
- `scripts/build-and-launch.sh`
  - CLI build、boot simulator、install、launch。
- `README.md`
  - 簡短說明如何 build、launch，以及真機 AirPlay 測試限制。

---

### Task 1: Xcode Project Skeleton

**Files:**
- Create: `NativeAirPlayLab.xcodeproj/project.pbxproj`
- Create: `NativeAirPlayLab/Info.plist`
- Create: `NativeAirPlayLab/NativeAirPlayLabApp.swift`
- Create: `NativeAirPlayLab/ContentView.swift`
- Create: `NativeAirPlayLabTests/PlaybackConfigurationTests.swift`

**Interfaces:**
- Produces: scheme `NativeAirPlayLab`
- Produces: bundle identifier `com.wingchan.NativeAirPlayLab`

- [ ] **Step 1: Create app entry and placeholder view**

```swift
import SwiftUI

@main
struct NativeAirPlayLabApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Native AirPlay Lab")
            .padding()
    }
}

#Preview {
    ContentView()
}
```

- [ ] **Step 2: Create minimal Xcode project**

Create an Xcode project with one app target and one unit test target:

- Project: `NativeAirPlayLab`
- App target: `NativeAirPlayLab`
- Test target: `NativeAirPlayLabTests`
- SDK: `iphoneos`
- Deployment target: `17.0`
- Supported destinations: iPhone and iPad

- [ ] **Step 3: Run project discovery**

Run:

```bash
xcodebuild -list -project NativeAirPlayLab.xcodeproj
```

Expected: output contains scheme `NativeAirPlayLab`.

- [ ] **Step 4: Commit**

```bash
git add NativeAirPlayLab.xcodeproj NativeAirPlayLab NativeAirPlayLabTests
git commit -m "Scaffold Native AirPlay Lab Xcode project"
```

---

### Task 2: Playback Configuration

**Files:**
- Create: `NativeAirPlayLab/PlaybackConfiguration.swift`
- Create: `NativeAirPlayLabTests/PlaybackConfigurationTests.swift`

**Interfaces:**
- Produces: `PlaybackConfiguration.defaultMediaURL: URL`
- Consumes: none

- [ ] **Step 1: Write the failing test**

```swift
import XCTest
@testable import NativeAirPlayLab

final class PlaybackConfigurationTests: XCTestCase {
    func testDefaultMediaURLIsHTTPSVideoURL() {
        let url = PlaybackConfiguration.defaultMediaURL

        XCTAssertEqual(url.scheme, "https")
        XCTAssertFalse(url.absoluteString.isEmpty)
        XCTAssertTrue(url.pathExtension == "mp4" || url.pathExtension == "m3u8")
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
xcodebuild test -project NativeAirPlayLab.xcodeproj -scheme NativeAirPlayLab -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: FAIL because `PlaybackConfiguration` is not defined.

- [ ] **Step 3: Implement minimal configuration**

```swift
import Foundation

enum PlaybackConfiguration {
    static let defaultMediaURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
}
```

- [ ] **Step 4: Run test to verify it passes**

Run:

```bash
xcodebuild test -project NativeAirPlayLab.xcodeproj -scheme NativeAirPlayLab -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add NativeAirPlayLab/PlaybackConfiguration.swift NativeAirPlayLabTests/PlaybackConfigurationTests.swift NativeAirPlayLab.xcodeproj/project.pbxproj
git commit -m "Add playback configuration"
```

---

### Task 3: Native AirPlay Route Picker

**Files:**
- Create: `NativeAirPlayLab/AirPlayRoutePicker.swift`
- Create: `NativeAirPlayLabTests/AirPlayRoutePickerTests.swift`

**Interfaces:**
- Produces: `AirPlayRoutePicker: UIViewRepresentable`
- Produces: `AirPlayRoutePicker.makeConfiguredView() -> AVRoutePickerView`

- [ ] **Step 1: Write the failing test**

```swift
import AVKit
import XCTest
@testable import NativeAirPlayLab

final class AirPlayRoutePickerTests: XCTestCase {
    func testConfiguredViewUsesVideoRoutePicker() {
        let view = AirPlayRoutePicker.makeConfiguredView()

        XCTAssertEqual(view.prioritizesVideoDevices, true)
        XCTAssertEqual(view.tintColor, .systemBlue)
        XCTAssertEqual(view.activeTintColor, .systemGreen)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
xcodebuild test -project NativeAirPlayLab.xcodeproj -scheme NativeAirPlayLab -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: FAIL because `AirPlayRoutePicker` is not defined.

- [ ] **Step 3: Implement route picker wrapper**

```swift
import AVKit
import SwiftUI

struct AirPlayRoutePicker: UIViewRepresentable {
    static func makeConfiguredView() -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.prioritizesVideoDevices = true
        view.tintColor = .systemBlue
        view.activeTintColor = .systemGreen
        return view
    }

    func makeUIView(context: Context) -> AVRoutePickerView {
        Self.makeConfiguredView()
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}
```

- [ ] **Step 4: Run test to verify it passes**

Run:

```bash
xcodebuild test -project NativeAirPlayLab.xcodeproj -scheme NativeAirPlayLab -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add NativeAirPlayLab/AirPlayRoutePicker.swift NativeAirPlayLabTests/AirPlayRoutePickerTests.swift NativeAirPlayLab.xcodeproj/project.pbxproj
git commit -m "Add native AirPlay route picker"
```

---

### Task 4: Player UI

**Files:**
- Modify: `NativeAirPlayLab/ContentView.swift`

**Interfaces:**
- Consumes: `PlaybackConfiguration.defaultMediaURL`
- Consumes: `AirPlayRoutePicker`

- [ ] **Step 1: Replace placeholder UI**

```swift
import AVKit
import SwiftUI

struct ContentView: View {
    @State private var player = AVPlayer(url: PlaybackConfiguration.defaultMediaURL)
    @State private var isPlaying = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VideoPlayer(player: player)
                    .frame(minHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                HStack(spacing: 20) {
                    Button(isPlaying ? "Pause" : "Play") {
                        if isPlaying {
                            player.pause()
                        } else {
                            player.play()
                        }
                        isPlaying.toggle()
                    }
                    .buttonStyle(.borderedProminent)

                    AirPlayRoutePicker()
                        .frame(width: 48, height: 48)
                        .accessibilityLabel("AirPlay")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Test stream")
                        .font(.headline)
                    Text(PlaybackConfiguration.defaultMediaURL.absoluteString)
                        .font(.footnote)
                        .textSelection(.enabled)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }
            .padding()
            .navigationTitle("Native AirPlay Lab")
        }
    }
}

#Preview {
    ContentView()
}
```

- [ ] **Step 2: Build**

Run:

```bash
xcodebuild build -project NativeAirPlayLab.xcodeproj -scheme NativeAirPlayLab -destination 'generic/platform=iOS Simulator'
```

Expected: BUILD SUCCEEDED.

- [ ] **Step 3: Commit**

```bash
git add NativeAirPlayLab/ContentView.swift
git commit -m "Add AirPlay player UI"
```

---

### Task 5: Build-And-Launch Script And README

**Files:**
- Create: `scripts/build-and-launch.sh`
- Create: `README.md`

**Interfaces:**
- Produces: CLI command `./scripts/build-and-launch.sh`

- [ ] **Step 1: Create script**

```bash
#!/usr/bin/env bash
set -euo pipefail

SCHEME="NativeAirPlayLab"
PROJECT="NativeAirPlayLab.xcodeproj"
APP_BUNDLE_ID="com.wingchan.NativeAirPlayLab"
DESTINATION_NAME="${DESTINATION_NAME:-iPhone 16}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$(pwd)/.derivedData}"

xcrun simctl boot "$DESTINATION_NAME" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$DESTINATION_NAME" -b

xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=$DESTINATION_NAME" \
  -derivedDataPath "$DERIVED_DATA_PATH"

APP_PATH="$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/$SCHEME.app"
xcrun simctl install "$DESTINATION_NAME" "$APP_PATH"
xcrun simctl launch "$DESTINATION_NAME" "$APP_BUNDLE_ID"
```

- [ ] **Step 2: Make script executable**

Run:

```bash
chmod +x scripts/build-and-launch.sh
```

- [ ] **Step 3: Create README**

Include:

```markdown
# Native AirPlay Lab

SwiftUI iOS app for testing native AirPlay route selection with `AVRoutePickerView` and `AVPlayer`.

## Build

```sh
xcodebuild build -project NativeAirPlayLab.xcodeproj -scheme NativeAirPlayLab -destination 'generic/platform=iOS Simulator'
```

## Launch On Simulator

```sh
./scripts/build-and-launch.sh
```

Set a different simulator:

```sh
DESTINATION_NAME='iPad Pro 11-inch (M4)' ./scripts/build-and-launch.sh
```

## AirPlay Notes

Simulator is only for build and basic UI validation. Real AirPlay output should be tested on a physical iPhone or iPad connected to the same network as an AirPlay receiver.
```

- [ ] **Step 4: Run full validation**

Run:

```bash
xcodebuild test -project NativeAirPlayLab.xcodeproj -scheme NativeAirPlayLab -destination 'platform=iOS Simulator,name=iPhone 16'
./scripts/build-and-launch.sh
```

Expected: tests pass, app installs, app launches.

- [ ] **Step 5: Commit**

```bash
git add README.md scripts/build-and-launch.sh
git commit -m "Add CLI build and launch workflow"
```
