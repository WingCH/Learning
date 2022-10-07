import 'package:flutter/material.dart';

// ref: https://juejin.cn/post/7134510980905566238

// clone by ErrorWidget.builder -> _defaultErrorWidgetBuilder
Widget _defaultErrorWidgetBuilder(FlutterErrorDetails details) {
  String message =
      '${details.exception}\nSee also: https://flutter.dev/docs/testing/errors';

  // In production code, assertions are ignored, and the arguments to assert aren’t evaluated.
  // https://dart.dev/guides/language/language-tour#assert
  // assert(() {
  //   message = '${_stringify(details.exception)}\nSee also: https://flutter.dev/docs/testing/errors';
  //   return true;
  // }());

  print('_defaultErrorWidgetBuilder');
  final Object exception = details.exception;
  return ErrorWidget.withDetails(
      message: message, error: exception is FlutterError ? exception : null);
}

void main() {
  ErrorWidget.builder = _defaultErrorWidgetBuilder;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      appBar: AppBar(),
      body: Stack(
        children: <Widget>[
          GestureDetector(
            child: Positioned(
              child: Container(
                height: 250,
                width: 250,
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }
}
