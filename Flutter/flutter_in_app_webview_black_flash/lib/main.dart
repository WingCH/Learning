import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'example.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: const Text("Example"),
            onTap: () {
              Navigator.push(
                context,
                // CupertinoPageRoute(
                //   builder: (context) => ExamplePage(),
                // ),
                // MaterialPageRoute(
                //   builder: (context) => ExamplePage(),
                // ),
                CustomTransitionRoute(
                  builder: (context) => const ExamplePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// https://github.com/pichillilorenzo/flutter_inappwebview/issues/1098
class CustomTransitionRoute extends CupertinoPageRoute<void> {
  CustomTransitionRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(builder: builder, settings: settings, fullscreenDialog: false);

  @override
  bool get opaque => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(seconds: 5);
}
