import 'package:flutter/material.dart';
import 'package:study_rebuild_mechanism/case/case2_page.dart';
import 'package:study_rebuild_mechanism/widget_cache.dart';

class Case5Page extends StatefulWidget {
  const Case5Page({super.key});

  @override
  State<Case5Page> createState() => _Case5PageState();
}

class _Case5PageState extends State<Case5Page> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        WidgetCache(
          value: 'test',
          builder: (context, value) => const Case2Page(),
        ),
        // const Case2Page(),
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
