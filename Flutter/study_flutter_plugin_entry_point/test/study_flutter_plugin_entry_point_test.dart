import 'package:flutter_test/flutter_test.dart';
import 'package:study_flutter_plugin_entry_point/study_flutter_plugin_entry_point.dart';
import 'package:study_flutter_plugin_entry_point/study_flutter_plugin_entry_point_platform_interface.dart';
import 'package:study_flutter_plugin_entry_point/study_flutter_plugin_entry_point_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockStudyFlutterPluginEntryPointPlatform
    with MockPlatformInterfaceMixin
    implements StudyFlutterPluginEntryPointPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future registerCallbackDispatcher(Function dispatcher) {
    // TODO: implement registerCallbackDispatcher
    throw UnimplementedError();
  }

  @override
  triggerVmEntryPoint() {
    // TODO: implement triggerVmEntryPoint
    throw UnimplementedError();
  }
}

void main() {
  final StudyFlutterPluginEntryPointPlatform initialPlatform = StudyFlutterPluginEntryPointPlatform.instance;

  test('$MethodChannelStudyFlutterPluginEntryPoint is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelStudyFlutterPluginEntryPoint>());
  });

  test('getPlatformVersion', () async {
    StudyFlutterPluginEntryPoint studyFlutterPluginEntryPointPlugin = StudyFlutterPluginEntryPoint();
    MockStudyFlutterPluginEntryPointPlatform fakePlatform = MockStudyFlutterPluginEntryPointPlatform();
    StudyFlutterPluginEntryPointPlatform.instance = fakePlatform;

    expect(await studyFlutterPluginEntryPointPlugin.getPlatformVersion(), '42');
  });
}
