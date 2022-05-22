import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() {
    debugPrint('$runtimeType -- createState');
    return _HomePageState(title: runtimeType.toString());
  }
}

class _HomePageState extends State<HomePage> {
  final String title;
  _HomePageState({required this.title});

  int _counter = 0;


  void _incrementCounter() {
    debugPrint('$title -- _incrementCounter');

    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    debugPrint('$title -- initState');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('$title -- build');

    return Scaffold(
      appBar: AppBar(
        title:  Text(title),
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
