import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PerformanceTestPage(),
    );
  }
}

class AAA extends StatefulWidget {
  const AAA({super.key});

  @override
  State<AAA> createState() => _AAAState();
}

class _AAAState extends State<AAA> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class PerformanceTestPage extends StatefulWidget {
  const PerformanceTestPage({super.key});

  @override
  State<PerformanceTestPage> createState() => _PerformanceTestPageState();
}

class _PerformanceTestPageState extends State<PerformanceTestPage> {
  String _testResult = 'Click the button to start the performance test';

  // Function to simulate a performance test, runs asynchronously
  Future<void> _performanceTest() async {
    const int dataSize = 100001; // Using a smaller number for quicker results
    final List<int> testData = List.generate(dataSize, (index) => Random().nextInt(dataSize));
    final startTime = DateTime.now();

    // Performing the test steps
    testData.sort();
    final double mean = testData.reduce((a, b) => a + b) / testData.length;
    final closestToMean = testData.reduce((a, b) => (mean - a).abs() < (mean - b).abs() ? a : b);
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    // Updating the UI
    setState(() {
      _testResult = 'Done! Mean: $mean, Number closest to mean: $closestToMean, Total duration: $duration';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Performance Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _performanceTest();
              },
              child: const Text('Start Test v2'),
            ),
            const SizedBox(height: 20),
            Text(_testResult),
          ],
        ),
      ),
    );
  }
}
