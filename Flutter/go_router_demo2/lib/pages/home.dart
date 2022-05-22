import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  void dispose() {
    super.dispose();
    debugPrint('$title -- dispose');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('$title -- build');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('go to menu'),
              onPressed: () {
                context.go('/home/menu');
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('redemption'),
              onPressed: () {
                context.go('/redemption');
                // context.go('/redemption');
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('logout'),
              onPressed: () {
                context.go('/login');
              },
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
