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
  List<FocusNode> _focusNodes = [];
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 20; i++) {
      FocusNode focusNode = FocusNode();
      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          // delay to ensure the keyboard is shown
          Future.delayed(const Duration(milliseconds: 250), () {
            _scrollController.animateTo(
              focusNode.context?.findRenderObject()?.getTransformTo(null).getTranslation().y ?? 0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.linear,
            );
          });
        }
      });
      _focusNodes.add(focusNode);
    }
  }

  @override
  void dispose() {
    for (FocusNode focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: max(MediaQuery.of(context).viewInsets.bottom - 100, 0)),
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < _focusNodes.length; i++)
                    TextField(
                      focusNode: _focusNodes[i],
                      decoration: InputDecoration(
                        labelText: 'Text Field $i',
                      ),
                    ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            bottom: false,
            child: Container(
              color: Colors.blue,
              height: 100.0,
              padding: const EdgeInsets.all(16.0),
              child: const Center(
                child: Text(
                  'Bottom Container',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
