import 'package:flutter/material.dart';

class DartTimezoneExample extends StatefulWidget {
  const DartTimezoneExample({Key? key}) : super(key: key);

  @override
  State<DartTimezoneExample> createState() => _DartTimezoneExampleState();
}

class _DartTimezoneExampleState extends State<DartTimezoneExample> {
  final DateTime dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dart Timezone'),
      ),
      body: Center(
        child: Text(dateTime.timeZoneName),
      ),
    );
  }
}
