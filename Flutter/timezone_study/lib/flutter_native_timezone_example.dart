import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class FlutterNativeTimezoneExample extends StatefulWidget {
  const FlutterNativeTimezoneExample({Key? key}) : super(key: key);

  @override
  State<FlutterNativeTimezoneExample> createState() =>
      _FlutterNativeTimezoneExampleState();
}

class _FlutterNativeTimezoneExampleState
    extends State<FlutterNativeTimezoneExample> {
  String _timezone = 'Unknown';
  List<String> _availableTimezones = <String>[];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      _timezone = await FlutterNativeTimezone.getLocalTimezone();
    } catch (e) {
      print('Could not get the local timezone');
    }
    try {
      _availableTimezones = await FlutterNativeTimezone.getAvailableTimezones();
      _availableTimezones.sort();
    } catch (e) {
      print('Could not get available timezones');
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('flutter_native_timezone'),
      ),
      body: Column(
        children: <Widget>[
          Text('Local timezone: $_timezone\n'),
          const Text('Available timezones:'),
          Expanded(
            child: ListView.builder(
              itemCount: _availableTimezones.length,
              itemBuilder: (_, index) => Text(_availableTimezones[index]),
            ),
          )
        ],
      ),
    );
  }
}
