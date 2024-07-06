import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BottomScrollViewExample(),
    );
  }
}

class BottomScrollViewExample extends StatefulWidget {
  const BottomScrollViewExample({super.key});

  @override
  State<BottomScrollViewExample> createState() => _BottomScrollViewExampleState();
}

class _BottomScrollViewExampleState extends State<BottomScrollViewExample> {
  final bottomHeight = 100.0;

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < 20; i++)
                    TextField(
                      scrollPadding: EdgeInsets.only(bottom: keyboardHeight),
                      decoration: InputDecoration(
                        labelText: 'Text Field $i',
                      ),
                    ),
                  SizedBox(
                    height: max(keyboardHeight, bottomHeight),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                color: Colors.blue,
                height: bottomHeight,
                padding: const EdgeInsets.all(16.0),
                child: const Center(
                  child: Text(
                    'Bottom Container',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
