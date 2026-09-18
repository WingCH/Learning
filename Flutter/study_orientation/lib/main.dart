import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OrientationTestPage(),
    );
  }
}

class OrientationTestPage extends StatelessWidget {
  const OrientationTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.orientationOf(context);
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Orientation: ${orientation.name}\n'
            'Size: ${size.width.toStringAsFixed(0)} x ${size.height.toStringAsFixed(0)}\n\n'
            'Already set:\n'
            'await SystemChrome.setPreferredOrientations([\n'
            '  DeviceOrientation.portraitUp,\n'
            '  DeviceOrientation.portraitDown,\n'
            ']);',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
