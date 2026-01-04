// Copyright 2024 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of battery_level must implement.
///
/// Platform implementations should extend this class rather than implement it
/// as `battery_level` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [BatteryLevelPlatform] methods.
abstract class BatteryLevelPlatform extends PlatformInterface {
  /// Constructs a BatteryLevelPlatform.
  BatteryLevelPlatform() : super(token: _token);

  static final Object _token = Object();

  static BatteryLevelPlatform _instance = _PlaceholderImplementation();

  /// The instance of [BatteryLevelPlatform] to use.
  ///
  /// Defaults to a placeholder that does not override any methods, and thus
  /// throws `UnimplementedError` in most cases.
  static BatteryLevelPlatform get instance => _instance;

  /// Platform-specific plugins should override this with their own
  /// platform-specific class that extends [BatteryLevelPlatform] when they
  /// register themselves.
  static set instance(BatteryLevelPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Returns the current battery level as a percentage (0-100).
  ///
  /// Returns -1 if the battery level cannot be determined.
  Future<int> getBatteryLevel() {
    throw UnimplementedError('getBatteryLevel() has not been implemented.');
  }

  /// Returns the current battery state.
  ///
  /// Possible values: charging, discharging, full, unknown
  Future<BatteryState> getBatteryState() {
    throw UnimplementedError('getBatteryState() has not been implemented.');
  }

  /// Returns a stream of battery level changes.
  Stream<int> get onBatteryLevelChanged {
    throw UnimplementedError('onBatteryLevelChanged has not been implemented.');
  }

  /// Returns a stream of battery state changes.
  Stream<BatteryState> get onBatteryStateChanged {
    throw UnimplementedError('onBatteryStateChanged has not been implemented.');
  }
}

/// Placeholder implementation that throws UnimplementedError for all methods.
class _PlaceholderImplementation extends BatteryLevelPlatform {}

/// Represents the charging state of the battery.
enum BatteryState {
  /// The battery is currently charging.
  charging,

  /// The battery is currently discharging (not connected to power).
  discharging,

  /// The battery is full.
  full,

  /// The battery state cannot be determined.
  unknown,
}
