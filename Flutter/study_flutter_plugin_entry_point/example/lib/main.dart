import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:study_flutter_plugin_entry_point/study_flutter_plugin_entry_point.dart';

@pragma('vm:entry-point')
void appCallbackDispatcher() {
  print("appCallbackDispatcher called");
  WidgetsFlutterBinding.ensureInitialized();
  // Register the plugin
  DartPluginRegistrant.ensureInitialized();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  StudyFlutterPluginEntryPoint.instance.registerCallbackDispatcher(appCallbackDispatcher);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await StudyFlutterPluginEntryPoint.instance.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Text('Running on: $_platformVersion\n'),
            // button
            TextButton(
                onPressed: () {
                  StudyFlutterPluginEntryPoint.instance.triggerVmEntryPoint();
                },
                child: const Text("Trigger vm:entry-point")
            )
          ],
        ),
      ),
    );
  }
}
