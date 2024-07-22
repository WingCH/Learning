import 'dart:ui';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const foregroundChannel =
    MethodChannel('samples.flutter.dev/foregroundChannel');
const backgroundChannel =
    MethodChannel("samples.flutter.dev/backgroundChannel");

@pragma('vm:entry-point')
void customEntryPoint() {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  backgroundChannel.setMethodCallHandler((call) async {
    final method = call.method;
    final args = call.arguments;
    print('Received call from background: $method, Args: $args');
    if (method == 'waitResult') {
      print('Sleeping for 1 seconds..., Date: ${DateTime.now()}');
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Demo use other flutter plugin in background isolate
        var battery = Battery();
        final batteryLevel = await battery.batteryLevel;
        return batteryLevel;
      } catch (e) {
        return e.toString();
      }
    }
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String result = 'initial';

  @override
  void initState() {
    super.initState();
    getBatteryLevel();
  }

  void getBatteryLevel() async {
    try {
      var battery = Battery();
      final batteryLevel = await battery.batteryLevel;
      result = 'Battery level: $batteryLevel';
    } catch (e) {
      result = e.toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {
                initial(customEntryPoint);
              },
              child: Text(result),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> initial(
    final Function callbackDispatcher,
  ) async {
    CallbackHandle? callbackHandle =
        PluginUtilities.getCallbackHandle(callbackDispatcher);
    if (callbackHandle == null) {
      print('Failed to get callback handle');
      return;
    }
    foregroundChannel.invokeMethod<void>('initialize', <String, dynamic>{
      'callbackHandle': callbackHandle.toRawHandle(),
    });

    print('Got callback handle: ${callbackHandle.toRawHandle()}');
  }
}
