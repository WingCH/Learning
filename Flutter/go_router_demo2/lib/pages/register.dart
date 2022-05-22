import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() {
    debugPrint('$runtimeType -- createState');
    return _RegisterPageState(title: runtimeType.toString());
  }
}

class _RegisterPageState extends State<RegisterPage> {
  final String title;

  _RegisterPageState({required this.title});

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
            ElevatedButton(
              child: const Text('back to login page'),
              onPressed: () {
                context.go('/login');
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('register and go to home page'),
              onPressed: () {
                context.go('/home');
              },
            )
          ],
        ),
      ),
    );
  }
}
