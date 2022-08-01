import 'dart:js' as js;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter PageView Keep Page State'),
        actions: [
          IconButton(
            onPressed: () {
              js.context.callMethod('open', ['https://github.com/WingCH/Learning/tree/main/Flutter/pageview_keep_state']);
            },
            icon: const Icon(Icons.code),
          ),
        ],
      ),
      body: PageView(
        children: const [
          SubView1(),
          SubView2(),
          SubView1(),
          SubView2(),
        ],
      ),
    );
  }
}

class SubView1 extends StatefulWidget {
  const SubView1({Key? key}) : super(key: key);

  @override
  State<SubView1> createState() => _SubView1State();
}

class _SubView1State extends State<SubView1> with AutomaticKeepAliveClientMixin {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(count.toString(), style: Theme.of(context).textTheme.headline4),
        IconButton(
          onPressed: () {
            setState(() {
              count++;
            });
          },
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SubView2 extends StatefulWidget {
  const SubView2({Key? key}) : super(key: key);

  @override
  State<SubView2> createState() => _SubView2State();
}

class _SubView2State extends State<SubView2> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      itemCount: 100,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Item $index'),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
