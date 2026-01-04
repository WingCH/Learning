import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    swiftOut: 'ios/Classes/messages.g.swift',
    swiftOptions: SwiftOptions(),
  ),
)
enum PlatformBatteryState { charging, discharging, full, unknown }

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
