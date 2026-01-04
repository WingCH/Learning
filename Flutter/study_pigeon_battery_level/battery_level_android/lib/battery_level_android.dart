// Copyright 2024 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:battery_level_platform_interface/battery_level_platform_interface.dart';

import 'src/messages.g.dart';

/// An Android implementation of [BatteryLevelPlatform] that uses Pigeon.
class BatteryLevelAndroid extends BatteryLevelPlatform {
  /// Creates a new Android battery level implementation instance.
  BatteryLevelAndroid({BatteryLevelApi? api}) : _api = api ?? BatteryLevelApi();

  final BatteryLevelApi _api;

  /// Registers this class as the default instance of [BatteryLevelPlatform].
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

  // Note: Stream-based battery monitoring would require EventChannel
  // which can be added as an enhancement.
}
