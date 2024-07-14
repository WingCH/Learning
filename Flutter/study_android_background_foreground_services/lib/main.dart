import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ForegroundServiceHelper.dart';
import 'HealthDataHelper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  ReceivePort? _receivePort;
  Position? position;
  int? step;

  @override
  void initState() {
    super.initState();
    Health().configure(useHealthConnectIfAvailable: true);
  }

  Future<void> _requestPermissionForAndroid() async {
    if (!Platform.isAndroid) {
      return;
    }

    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
      await FlutterForegroundTask.openSystemAlertWindowSettings();
    }

    // Android 12 or higher, there are restrictions on starting a foreground service.
    //
    // To restart the service on device reboot or unexpected problem, you need to allow below permission.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
    final NotificationPermission notificationPermissionStatus =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  Future<void> _requestLocation() async {
    position = await Geolocator.getCurrentPosition();
    setState(() {});
  }

  Future<void> authorize() async {
    // If we are trying to read Step Count, Workout, Sleep or other data that requires
    // the ACTIVITY_RECOGNITION permission, we need to request the permission first.
    // This requires a special request authorization call.
    //
    // The location permission is requested for Workouts using the Distance information.
    await Permission.activityRecognition.request();
    await Permission.location.request();

    final types = [HealthDataType.STEPS];
    final permissions = types.map((type) => HealthDataAccess.READ).toList();

    // Check if we have health permissions
    bool? hasPermissions =
        await Health().hasPermissions(types, permissions: permissions);

    // hasPermissions = false because the hasPermission cannot disclose if WRITE access exists.
    // Hence, we have to request with WRITE as well.
    hasPermissions = false;

    if (!hasPermissions) {
      // requesting access to the data types before reading them
      try {
        await Health().requestAuthorization(types, permissions: permissions);
      } catch (error) {
        debugPrint("Exception in authorize: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                onPressed: _requestPermissionForAndroid,
                child: const Text('1. Request Permission'),
              ),
              TextButton(
                onPressed: ForegroundServiceHelper.instance.startForegroundTask,
                child: const Text('2. Start Foreground Task'),
              ),
              TextButton(
                onPressed: ForegroundServiceHelper.instance.stopForegroundTask,
                child: const Text('3. Stop Foreground Task'),
              ),
              TextButton(
                onPressed: authorize,
                child: const Text('Authorize Health, Location Permissions'),
              ),
              TextButton(
                onPressed: _requestLocation,
                child: const Text('Request Location'),
              ),
              Text('Location: ${position?.latitude}, ${position?.longitude}'),
              TextButton(
                onPressed: () async {
                  step = await HealthDataHelper().fetchStepData();
                  setState(() {});
                },
                child: const Text('Fetch Step Data'),
              ),
              Text('Step: $step'),
            ],
          ),
        ),
      ),
    );
  }
}
