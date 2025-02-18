import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Case1Page extends StatefulWidget {
  const Case1Page({super.key});

  @override
  State<Case1Page> createState() => _Case1PageState();
}

class _Case1PageState extends State<Case1Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case1 Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _TimerText(),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                context.go('/detail');
              },
              child: const Text('Detail'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerText extends StatefulWidget {
  const _TimerText();

  @override
  State<_TimerText> createState() => _TimerTextState();
}

class _TimerTextState extends State<_TimerText> {
  Timer? _timer; // Timer instance.
  int _seconds = 0; // Counter for seconds.

  @override
  void initState() {
    super.initState();
    // Initializes a timer that updates the seconds counter every second.
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Text(
        'Timer: $_seconds s',
        style: const TextStyle(fontSize: 32),
      ),
    );
  }
}
