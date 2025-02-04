import 'dart:async';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Example'),
      ),
      body: Center(
        child: Column(
          children: [
            TimerText(),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/detail');
              },
              child: const Text('Detail'),
            ),
          ],
        ),
      ),
    );
  }
}

class TimerText extends StatefulWidget {
  const TimerText({super.key});

  @override
  State<TimerText> createState() => _TimerTextState();
}

class _TimerTextState extends State<TimerText> {
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
    return Text(
      'Timer: $_seconds s',
      style: const TextStyle(fontSize: 32),
    );
  }
}
