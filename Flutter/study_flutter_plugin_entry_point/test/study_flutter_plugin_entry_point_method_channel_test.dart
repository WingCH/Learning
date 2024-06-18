import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flutter_plugin_entry_point/study_flutter_plugin_entry_point_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelStudyFlutterPluginEntryPoint platform = MethodChannelStudyFlutterPluginEntryPoint();
  const MethodChannel channel = MethodChannel('study_flutter_plugin_entry_point');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
