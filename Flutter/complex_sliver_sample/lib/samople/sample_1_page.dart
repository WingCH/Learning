import 'package:flutter/material.dart';

class Sample1Page extends StatefulWidget {
  const Sample1Page({Key? key}) : super(key: key);

  @override
  State<Sample1Page> createState() => _Sample1PageState();
}

class _Sample1PageState extends State<Sample1Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('Sample1Page'),
      ),
    );
  }
}
