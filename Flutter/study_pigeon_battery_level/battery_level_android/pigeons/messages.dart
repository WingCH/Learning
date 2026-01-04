// Copyright 2024 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    kotlinOut:
        'android/src/main/kotlin/com/example/battery_level/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.example.battery_level'),
  ),
)
/// Represents the battery charging state.
enum PlatformBatteryState { charging, discharging, full, unknown }

/// Result containing battery information.
class BatteryInfo {
  BatteryInfo({required this.level, required this.state});

  /// Battery level as percentage (0-100), or -1 if unknown.
  final int level;

  /// Current battery state.
  final PlatformBatteryState state;
}

/// Host API for battery level operations.
/// Flutter calls these methods to get battery information from native Android.
@HostApi()
abstract class BatteryLevelApi {
  /// Returns the current battery level as percentage (0-100).
  /// Returns -1 if the battery level cannot be determined.
  int getBatteryLevel();

  /// Returns the current battery state.
  PlatformBatteryState getBatteryState();

  /// Returns both battery level and state.
  BatteryInfo getBatteryInfo();
}
