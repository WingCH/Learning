import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'study_flutter_plugin_entry_point_method_channel.dart';

abstract class StudyFlutterPluginEntryPointPlatform extends PlatformInterface {
  /// Constructs a StudyFlutterPluginEntryPointPlatform.
  StudyFlutterPluginEntryPointPlatform() : super(token: _token);

  static final Object _token = Object();

  static StudyFlutterPluginEntryPointPlatform _instance = MethodChannelStudyFlutterPluginEntryPoint();

  /// The default instance of [StudyFlutterPluginEntryPointPlatform] to use.
  ///
  /// Defaults to [MethodChannelStudyFlutterPluginEntryPoint].
  static StudyFlutterPluginEntryPointPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [StudyFlutterPluginEntryPointPlatform] when
  /// they register themselves.
  static set instance(StudyFlutterPluginEntryPointPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  //

  Future registerCallbackDispatcher(Function dispatcher) async {
    throw UnimplementedError('registerCallbackDispatcher() has not been implemented.');
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  triggerVmEntryPoint() {
    throw UnimplementedError('triggerVmEntryPoint() has not been implemented.');
  }
}
