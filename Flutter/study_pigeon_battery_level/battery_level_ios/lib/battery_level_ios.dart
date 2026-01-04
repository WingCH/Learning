import 'dart:async';

import 'package:battery_level_platform_interface/battery_level_platform_interface.dart';

import 'src/messages.g.dart';

class BatteryLevelIOS extends BatteryLevelPlatform {
  BatteryLevelIOS({BatteryLevelApi? api}) : _api = api ?? BatteryLevelApi();

  final BatteryLevelApi _api;

  static void registerWith() {
    BatteryLevelPlatform.instance = BatteryLevelIOS();
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
