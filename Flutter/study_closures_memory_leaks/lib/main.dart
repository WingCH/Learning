import 'package:flutter/material.dart';

// not work now
// OtherPage will always in memory, not sure why
// MemoryLeakButton is released, but i expect it will memory leak, since use closure with context
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/other': (context) => const OtherPage(),
      },
      home: Scaffold(
        body: Builder(builder: (context) {
          return Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/other'),
              child: const Text('Go to Other Page'),
            ),
          );
        }),
      ),
    );
  }
}

class OtherPage extends StatelessWidget {
  const OtherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Other Page'),
      ),
      // body: const Center(
      //   child: MemoryLeakButton(),
      // ),
    );
  }
}

class MemoryLeakButton extends StatelessWidget {
  const MemoryLeakButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    myHandler() => print(theme);

    return ElevatedButton(
      onPressed: myHandler,
      child: const Text('Apply Theme'),
    );
  }
}
