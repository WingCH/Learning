import 'package:flutter/material.dart';
import 'package:study_rebuild_mechanism/case/case1_page.dart';
import 'package:study_rebuild_mechanism/case/case2_page.dart';
import 'package:study_rebuild_mechanism/case/case3_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('study rebuild mechanism'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Case 1'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Case1Page()),
              );
            },
          ),
          ListTile(
            title: const Text('Case 2'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Case2Page()),
              );
            },
          ),
          ListTile(
            title: const Text('Case 3'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Case3Page()),
              );
            },
          ),
        ],
      ),
    );
  }
}
