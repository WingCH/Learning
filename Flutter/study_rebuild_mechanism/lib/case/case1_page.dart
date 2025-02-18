import 'dart:async';

import 'package:flutter/material.dart';

/// 簡單 Widget 樹（僅 3 層：Align > SizedBox > ColoredBox）
/// 觀察每次build的時間
class Case1Page extends StatefulWidget {
  const Case1Page({super.key});

  @override
  State<Case1Page> createState() => _Case1PageState();
}

class _Case1PageState extends State<Case1Page> {
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 3), _update);
  }

  Color _color = Colors.red;
  int _count = 0;

  void _update(Timer timer) {
    if (_count > 10) {
      timer.cancel();
      _count = 0;
      return;
    }
    _count++;
    setState(() {
      _color = _color == Colors.blue ? Colors.red : Colors.blue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      child: SizedBox(
        width: 100,
        height: 100,
        child: ColoredBox(color: _color),
      ),
    );
  }
}
