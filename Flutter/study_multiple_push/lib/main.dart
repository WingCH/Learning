import 'package:flutter/material.dart';

/*
 Issue: On iOS, the back swipe gesture does not appear to work on the subclass NoAnimationPageRoutes.
 Seems need  CupertinoPageTransitionsBuilder
 */
// https://stackoverflow.com/questions/46259751/how-to-push-multiple-routes-with-flutter-navigator
class NoAnimationPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationPageRoute({required WidgetBuilder builder})
      : super(builder: builder);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}

void main() {
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
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => const HomePage(),
          );
        }
        if (settings.name == '/second') {
          // On iOS, the back swipe gesture does not appear to work on the subclass NoAnimationPageRoutes.
          return NoAnimationPageRoute(
            builder: (context) => const SecondPage(),
          );
        }
        if (settings.name == '/third') {
          return MaterialPageRoute(
            builder: (context) => const ThirdPage(),
          );
        }
        return null;
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              child: const Text('Go to second page'),
              onPressed: () {
                Navigator.of(context).pushNamed('/second');
              },
            ),
            TextButton(
              child: const Text('Go to third page'),
              onPressed: () {
                Navigator.of(context).pushNamed('/second');
                Navigator.of(context).pushNamed('/third');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: TextButton(
          child: const Text('Go to third page'),
          onPressed: () {
            Navigator.of(context).pushNamed('/third');
          },
        ),
      ),
    );
  }
}

class ThirdPage extends StatefulWidget {
  const ThirdPage({Key? key}) : super(key: key);

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: TextButton(
          child: const Text('Back'),
          onPressed: () {
            Navigator.of(context).pop(context);
          },
        ),
      ),
    );
  }
}
