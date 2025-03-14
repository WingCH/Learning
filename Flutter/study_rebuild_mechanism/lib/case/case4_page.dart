import 'package:flutter/material.dart';
import 'package:study_rebuild_mechanism/case/case2_page.dart';

class Case4Page extends StatefulWidget {
  const Case4Page({super.key});

  @override
  State<Case4Page> createState() => _Case4PageState();
}

class _Case4PageState extends State<Case4Page> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Case2Page(),
        GestureDetector(
          onTap: () {
            setState(() {});
          },
          child: const Text('Click rebuild'),
        ),
      ],
    );
  }
}
