import 'package:flutter/material.dart';
import 'examples/level1_follower.dart';
import 'examples/level2_circle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CustomMultiChildLayout Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExamplesHome(),
    );
  }
}

class ExamplesHome extends StatelessWidget {
  const ExamplesHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CustomMultiChildLayout 教學'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Level 1: 跟隨者'),
              Tab(text: 'Level 2: 圓形佈局'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [Level1FollowerExample(), Level2CircleExample()],
        ),
      ),
    );
  }
}
