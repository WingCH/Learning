# XcodeGen Conversion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 將 Native AirPlay Lab 的 Xcode project 改為由 XcodeGen `project.yml` 產生。

**Architecture:** `project.yml` 定義 project、targets、scheme、build settings 與 source membership。`scripts/generate-xcodeproj.sh` 是唯一 project generation entrypoint。生成後仍 commit `.xcodeproj`，方便 Xcode 使用。

**Tech Stack:** XcodeGen、Xcode project、SwiftUI、AVKit、XCTest、`xcodebuild`、`codesign`

## Global Constraints

- 文件使用繁體中文畫面語撰寫。
- 不手動修改 generated `.pbxproj` 以外的必要驗證差異。
- Team ID 固定為 `AL869FRMV6`。
- Bundle ID 固定為 `com.wingchan.NativeAirPlayLab`。
- iOS deployment target 固定為 `17.0`。
- Test target 維持 hostless 編譯模式。

---

### Task 1: Add XcodeGen Source Of Truth

**Files:**
- Create: `project.yml`
- Create: `scripts/generate-xcodeproj.sh`
- Modify: `README.md`

**Interfaces:**
- Produces: `./scripts/generate-xcodeproj.sh`
- Produces: XcodeGen spec for scheme `NativeAirPlayLab`

- [ ] **Step 1: Create `project.yml`**

Add `project.yml` with app target, hostless unit test target, automatic signing, iOS 17 deployment target, and generated scheme.

- [ ] **Step 2: Create generator script**

Add `scripts/generate-xcodeproj.sh` that fails clearly when `xcodegen` is missing and otherwise runs `xcodegen generate --spec project.yml`.

- [ ] **Step 3: Update README**

Document that `project.yml` is the source of truth and `.xcodeproj` is generated.

### Task 2: Generate Project And Verify

**Files:**
- Modify: `NativeAirPlayLab.xcodeproj/project.pbxproj`
- Modify: `NativeAirPlayLab.xcodeproj/xcshareddata/xcschemes/NativeAirPlayLab.xcscheme`

**Interfaces:**
- Consumes: `project.yml`
- Produces: regenerated `NativeAirPlayLab.xcodeproj`

- [ ] **Step 1: Ensure XcodeGen is installed**

Run `xcodegen --version`. If missing, install it with Homebrew.

- [ ] **Step 2: Generate project**

Run `./scripts/generate-xcodeproj.sh`.

- [ ] **Step 3: Verify project discovery**

Run `xcodebuild -list -project NativeAirPlayLab.xcodeproj`. Expected: scheme `NativeAirPlayLab`.

- [ ] **Step 4: Verify simulator test build**

Run `xcodebuild build-for-testing -quiet -project NativeAirPlayLab.xcodeproj -scheme NativeAirPlayLab -destination 'generic/platform=iOS Simulator' -derivedDataPath .derivedData/xcodegen-test-build`. Expected: exit 0.

- [ ] **Step 5: Verify simulator app build**

Run `xcodebuild build -quiet -project NativeAirPlayLab.xcodeproj -scheme NativeAirPlayLab -destination 'generic/platform=iOS Simulator' -derivedDataPath .derivedData/xcodegen-sim-build`. Expected: exit 0.

- [ ] **Step 6: Verify device signing build**

Run `xcodebuild build -quiet -project NativeAirPlayLab.xcodeproj -scheme NativeAirPlayLab -destination 'generic/platform=iOS' -derivedDataPath .derivedData/xcodegen-device-build`. Expected: exit 0.

- [ ] **Step 7: Verify code signature**

Run `codesign --verify --deep --strict --verbose=2 .derivedData/xcodegen-device-build/Build/Products/Debug-iphoneos/NativeAirPlayLab.app`. Expected: valid on disk and satisfies designated requirement.

- [ ] **Step 8: Commit**

Commit all XcodeGen conversion changes with message `Convert project to XcodeGen`.
