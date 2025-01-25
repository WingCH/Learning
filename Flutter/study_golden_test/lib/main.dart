import 'package:flutter/material.dart';

import 'widgets/custom_button.dart';
import 'widgets/custom_star_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Golden Test Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Golden Test Demo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CustomButton'),
              CustomButton(
                onPressed: () {},
                child: const Text('Enabled'),
              ),
              const CustomButton(
                onPressed: null,
                child: Text('Disabled'),
              ),
              const SizedBox(height: 16),
              const Text('CustomStarImage'),
              const CustomStarImage(
                imagePath: 'assets/images/dog.webp',
                height: 100,
                width: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
