import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'study_flutter_plugin_entry_point_platform_interface.dart';

/// An implementation of [StudyFlutterPluginEntryPointPlatform] that uses method channels.
class MethodChannelStudyFlutterPluginEntryPoint extends StudyFlutterPluginEntryPointPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('study_flutter_plugin_entry_point');
  final backgroundChannel = const MethodChannel('study_flutter_plugin_entry_point_background');

  @override
  Future registerCallbackDispatcher(Function dispatcher) async {
    CallbackHandle? callbackHandle = PluginUtilities.getCallbackHandle(dispatcher);
    if (callbackHandle != null) {
      final int dispatcherHandle = callbackHandle.toRawHandle(); //Getting the dispatcher rawHandle!!!
      print("MyPlugin: dispatcherHandle: $dispatcher");
      await backgroundChannel.invokeMethod<void>("registerCallbackDispatcher", {"dispatcherHandler": dispatcherHandle});
    }
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  void triggerVmEntryPoint() {
    methodChannel.invokeMethod<void>('triggerVmEntryPoint');
  }
}
