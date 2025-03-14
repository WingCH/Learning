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
  final Stream<Color> _colorStream =
      Stream.periodic(const Duration(seconds: 1), (count) {
    return count.isEven ? Colors.blue : Colors.red;
  }).take(10);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          child: StreamBuilder<Color>(
            stream: _colorStream,
            builder: (context, snapshot) {
              return ColoredBoxWrapper(
                color: snapshot.data,
              );
            },
          ),
        ),
      ],
    );
  }
}

class ColoredBoxWrapper extends StatelessWidget {
  final Color? color;

  const ColoredBoxWrapper({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: ColoredBox(
        color: color ?? Colors.red,
      ),
    );
  }
}
