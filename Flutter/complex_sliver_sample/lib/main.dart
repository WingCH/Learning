import 'package:flutter/material.dart';

import 'samople/sample_1_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Pages'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Sample 1'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Sample1Page()),
              );
            },
          ),
        ],
      ),
    );
  }
}
