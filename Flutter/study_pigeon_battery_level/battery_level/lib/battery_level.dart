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
