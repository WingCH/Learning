import 'package:flutter/material.dart';

import 'dart_timezone_example.dart';
import 'flutter_native_timezone_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const FlutterNativeTimezoneExample(),
      home: const ExampleList(),
    );
  }
}

class ExampleList extends StatefulWidget {
  const ExampleList({Key? key}) : super(key: key);

  @override
  State<ExampleList> createState() => _ExampleListState();
}

class _ExampleListState extends State<ExampleList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: const Text('flutter_native_timezone'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FlutterNativeTimezoneExample(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Dart Timezone'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DartTimezoneExample(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
