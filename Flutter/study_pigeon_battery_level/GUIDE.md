# Flutter Federated Plugin 開發實戰指南：Battery Level 範例

本指南將逐步說明如何使用 **Federated Plugin 架構** 建立一個從 Native 端獲取電池電量的 Flutter Plugin。

---

## 專案結構總覽

```
battery_level/
├── battery_level/                      # App-Facing Package (給開發者用)
│   ├── lib/
│   │   └── battery_level.dart
│   └── pubspec.yaml
├── battery_level_platform_interface/   # Platform Interface (定義標準)
│   ├── lib/
│   │   └── battery_level_platform_interface.dart
│   └── pubspec.yaml
├── battery_level_android/              # Android Implementation
│   ├── android/
│   │   ├── build.gradle
│   │   └── src/main/kotlin/com/example/battery_level/
│   │       ├── BatteryLevelPlugin.kt
│   │       └── Messages.g.kt
│   ├── lib/
│   │   ├── battery_level_android.dart
│   │   └── src/messages.g.dart
│   ├── pigeons/
│   │   └── messages.dart
│   └── pubspec.yaml
└── battery_level_ios/                  # iOS Implementation
    ├── ios/
    │   ├── Classes/
    │   │   ├── BatteryLevelPlugin.swift
    │   │   └── messages.g.swift
    │   └── battery_level_ios.podspec
    ├── lib/
    │   ├── battery_level_ios.dart
    │   └── src/messages.g.dart
    ├── pigeons/
    │   └── messages.dart
    └── pubspec.yaml
```

---

## Step 1: 建立專案結構

```bash
mkdir -p battery_level/{battery_level,battery_level_platform_interface,battery_level_android,battery_level_ios}
```

---

## Step 2: 建立 Platform Interface Package

這是最重要的一步！定義所有平台都必須遵守的介面。

### 2.1 建立 pubspec.yaml

**檔案**: `battery_level_platform_interface/pubspec.yaml`

```yaml
name: battery_level_platform_interface
description: A common platform interface for the battery_level plugin.
version: 1.0.0

environment:
  sdk: ^3.7.0
  flutter: ">=3.29.0"

dependencies:
  flutter:
    sdk: flutter
  plugin_platform_interface: ^2.1.7

dev_dependencies:
  flutter_test:
    sdk: flutter
```

### 2.2 建立 Platform Interface 類別

**檔案**: `battery_level_platform_interface/lib/battery_level_platform_interface.dart`

```dart
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class BatteryLevelPlatform extends PlatformInterface {
  BatteryLevelPlatform() : super(token: _token);

  static final Object _token = Object();
  static BatteryLevelPlatform _instance = _PlaceholderImplementation();

  static BatteryLevelPlatform get instance => _instance;

  static set instance(BatteryLevelPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  Future<int> getBatteryLevel() {
    throw UnimplementedError('getBatteryLevel() has not been implemented.');
  }

  Future<BatteryState> getBatteryState() {
    throw UnimplementedError('getBatteryState() has not been implemented.');
  }
}

class _PlaceholderImplementation extends BatteryLevelPlatform {}

enum BatteryState {
  charging,
  discharging,
  full,
  unknown,
}
```

**重點說明**:
- 繼承 `PlatformInterface` 確保安全性
- 使用 `_token` 進行實作驗證
- 方法預設拋出 `UnimplementedError`

---

## Step 3: 建立 Android Implementation Package

### 3.1 建立 pubspec.yaml

**檔案**: `battery_level_android/pubspec.yaml`

```yaml
name: battery_level_android
description: Android implementation of the battery_level plugin.
version: 1.0.0

environment:
  sdk: ^3.7.0
  flutter: ">=3.29.0"

flutter:
  plugin:
    implements: battery_level
    platforms:
      android:
        dartPluginClass: BatteryLevelAndroid
        package: com.example.battery_level
        pluginClass: BatteryLevelPlugin

dependencies:
  flutter:
    sdk: flutter
  battery_level_platform_interface:
    path: ../battery_level_platform_interface

dev_dependencies:
  flutter_test:
    sdk: flutter
  pigeon: ^22.7.0
```

### 3.2 定義 Pigeon 訊息

**檔案**: `battery_level_android/pigeons/messages.dart`

```dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    kotlinOut: 'android/src/main/kotlin/com/example/battery_level/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.example.battery_level'),
  ),
)

enum PlatformBatteryState {
  charging,
  discharging,
  full,
  unknown,
}

class BatteryInfo {
  BatteryInfo({required this.level, required this.state});
  final int level;
  final PlatformBatteryState state;
}

@HostApi()
abstract class BatteryLevelApi {
  int getBatteryLevel();
  PlatformBatteryState getBatteryState();
  BatteryInfo getBatteryInfo();
}
```

### 3.3 生成程式碼

```bash
cd battery_level_android
dart run pigeon --input pigeons/messages.dart
```

### 3.4 實作 Dart 端

**檔案**: `battery_level_android/lib/battery_level_android.dart`

```dart
import 'package:battery_level_platform_interface/battery_level_platform_interface.dart';
import 'src/messages.g.dart';

class BatteryLevelAndroid extends BatteryLevelPlatform {
  BatteryLevelAndroid({BatteryLevelApi? api}) : _api = api ?? BatteryLevelApi();

  final BatteryLevelApi _api;

  static void registerWith() {
    BatteryLevelPlatform.instance = BatteryLevelAndroid();
  }

  @override
  Future<int> getBatteryLevel() async {
    return _api.getBatteryLevel();
  }

  @override
  Future<BatteryState> getBatteryState() async {
    final PlatformBatteryState state = await _api.getBatteryState();
    return _convertState(state);
  }

  BatteryState _convertState(PlatformBatteryState state) {
    switch (state) {
      case PlatformBatteryState.charging:
        return BatteryState.charging;
      case PlatformBatteryState.discharging:
        return BatteryState.discharging;
      case PlatformBatteryState.full:
        return BatteryState.full;
      case PlatformBatteryState.unknown:
        return BatteryState.unknown;
    }
  }
}
```

### 3.5 實作 Native 端 (Kotlin)

**檔案**: `android/src/main/kotlin/com/example/battery_level/BatteryLevelPlugin.kt`

```kotlin
package com.example.battery_level

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

class BatteryLevelPlugin : FlutterPlugin, BatteryLevelApi {
    private var context: Context? = null

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        context = binding.applicationContext
        BatteryLevelApi.setUp(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        context = null
        BatteryLevelApi.setUp(binding.binaryMessenger, null)
    }

    override fun getBatteryLevel(): Long {
        val batteryLevel: Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = context?.getSystemService(Context.BATTERY_SERVICE) as? BatteryManager
            batteryManager?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY) ?: -1
        } else {
            val intent = context?.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
            val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
            if (level != -1 && scale != -1) (level * 100 / scale) else -1
        }
        return batteryLevel.toLong()
    }

    override fun getBatteryState(): PlatformBatteryState {
        val intent = context?.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        
        return when (status) {
            BatteryManager.BATTERY_STATUS_CHARGING -> PlatformBatteryState.CHARGING
            BatteryManager.BATTERY_STATUS_DISCHARGING -> PlatformBatteryState.DISCHARGING
            BatteryManager.BATTERY_STATUS_FULL -> PlatformBatteryState.FULL
            else -> PlatformBatteryState.UNKNOWN
        }
    }

    override fun getBatteryInfo(): BatteryInfo {
        return BatteryInfo(level = getBatteryLevel(), state = getBatteryState())
    }
}
```

---

## Step 4: 建立 iOS Implementation Package

### 4.1 建立 pubspec.yaml

**檔案**: `battery_level_ios/pubspec.yaml`

```yaml
name: battery_level_ios
description: iOS implementation of the battery_level plugin.
version: 1.0.0

environment:
  sdk: ^3.7.0
  flutter: ">=3.29.0"

flutter:
  plugin:
    implements: battery_level
    platforms:
      ios:
        dartPluginClass: BatteryLevelIOS
        pluginClass: BatteryLevelPlugin

dependencies:
  flutter:
    sdk: flutter
  battery_level_platform_interface:
    path: ../battery_level_platform_interface

dev_dependencies:
  flutter_test:
    sdk: flutter
  pigeon: ^22.7.0
```

### 4.2 定義 Pigeon 訊息

**檔案**: `battery_level_ios/pigeons/messages.dart`

```dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    swiftOut: 'ios/Classes/messages.g.swift',
    swiftOptions: SwiftOptions(),
  ),
)

enum PlatformBatteryState {
  charging,
  discharging,
  full,
  unknown,
}

class BatteryInfo {
  BatteryInfo({required this.level, required this.state});
  final int level;
  final PlatformBatteryState state;
}

@HostApi()
abstract class BatteryLevelApi {
  int getBatteryLevel();
  PlatformBatteryState getBatteryState();
  BatteryInfo getBatteryInfo();
}
```

### 4.3 實作 Native 端 (Swift)

**檔案**: `ios/Classes/BatteryLevelPlugin.swift`

```swift
import Flutter
import UIKit

public class BatteryLevelPlugin: NSObject, FlutterPlugin, BatteryLevelApi {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = BatteryLevelPlugin()
        BatteryLevelApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
    }
    
    func getBatteryLevel() throws -> Int64 {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        
        if batteryLevel < 0 {
            return -1
        }
        return Int64(batteryLevel * 100)
    }
    
    func getBatteryState() throws -> PlatformBatteryState {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let state = UIDevice.current.batteryState
        
        switch state {
        case .charging:
            return .charging
        case .full:
            return .full
        case .unplugged:
            return .discharging
        case .unknown:
            return .unknown
        @unknown default:
            return .unknown
        }
    }
    
    func getBatteryInfo() throws -> BatteryInfo {
        let level = try getBatteryLevel()
        let state = try getBatteryState()
        
        return BatteryInfo(level: level, state: state)
    }
}
```

---

## Step 5: 建立 App-Facing Package

這是開發者直接使用的 Package。

### 5.1 建立 pubspec.yaml

**檔案**: `battery_level/pubspec.yaml`

```yaml
name: battery_level
description: Flutter plugin for getting battery level from native platforms.
version: 1.0.0

environment:
  sdk: ^3.7.0
  flutter: ">=3.29.0"

flutter:
  plugin:
    platforms:
      android:
        default_package: battery_level_android
      ios:
        default_package: battery_level_ios

dependencies:
  flutter:
    sdk: flutter
  battery_level_android:
    path: ../battery_level_android
  battery_level_ios:
    path: ../battery_level_ios
  battery_level_platform_interface:
    path: ../battery_level_platform_interface
```

### 5.2 建立 API 類別

**檔案**: `battery_level/lib/battery_level.dart`

```dart
import 'package:battery_level_platform_interface/battery_level_platform_interface.dart';

export 'package:battery_level_platform_interface/battery_level_platform_interface.dart'
    show BatteryState;

class BatteryLevel {
  static BatteryLevelPlatform get _platform => BatteryLevelPlatform.instance;

  static Future<int> getBatteryLevel() {
    return _platform.getBatteryLevel();
  }

  static Future<BatteryState> getBatteryState() {
    return _platform.getBatteryState();
  }
}
```

---

## Step 6: 使用方式

在你的 Flutter App 中：

```dart
import 'package:battery_level/battery_level.dart';

void getBattery() async {
  final int level = await BatteryLevel.getBatteryLevel();
  final BatteryState state = await BatteryLevel.getBatteryState();
  
  print('Battery Level: $level%');
  print('Battery State: $state');
}
```

---

## 開發順序檢核表

1. ✅ **Platform Interface**: 定義 `PlatformInterface` 抽象類別
2. ✅ **Pigeon 定義**: 在各平台實作層定義 `messages.dart`
3. ✅ **生成程式碼**: 執行 `dart run pigeon --input pigeons/messages.dart`
4. ✅ **Dart 實作**: 繼承 `PlatformInterface`，用 Pigeon 呼叫 Native
5. ✅ **Native 實作**: 實作 Pigeon 產生的 Interface
6. ✅ **App-Facing**: 建立開發者使用的 API 類別
7. ✅ **pubspec.yaml**: 設定 `implements` 和 `dartPluginClass`

---

## 架構優點

| 特性 | 說明 |
|------|------|
| **解耦** | App 開發者只需引用主 Package，不需關心底層實作 |
| **可擴充** | 輕鬆新增 Web、Windows 等平台支援 |
| **型別安全** | Pigeon 自動生成型別安全的通訊層 |
| **可測試** | 各層可獨立測試 |
| **可替換** | 第三方可提供自己的平台實作 |
