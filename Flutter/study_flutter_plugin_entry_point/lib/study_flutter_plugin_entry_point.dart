import 'study_flutter_plugin_entry_point_platform_interface.dart';

class StudyFlutterPluginEntryPoint {
  static final StudyFlutterPluginEntryPoint instance = StudyFlutterPluginEntryPoint();

  Future<String?> getPlatformVersion() {
    return StudyFlutterPluginEntryPointPlatform.instance.getPlatformVersion();
  }

  Future registerCallbackDispatcher(Function appCallbackDispatcher) async {
    return StudyFlutterPluginEntryPointPlatform.instance.registerCallbackDispatcher(appCallbackDispatcher);
  }

  void triggerVmEntryPoint() {
     StudyFlutterPluginEntryPointPlatform.instance.triggerVmEntryPoint();
  }
}
