import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() {
    debugPrint('$runtimeType -- createState');
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    debugPrint('$runtimeType -- _incrementCounter');

    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    debugPrint('$runtimeType -- initState');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('$runtimeType -- build');

    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
