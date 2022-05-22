import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() {
    debugPrint('$runtimeType -- createState');
    return _LoginPageState(title: runtimeType.toString());
  }
}

class _LoginPageState extends State<LoginPage> {
  final String title;

  _LoginPageState({required this.title});

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
              child: const Text('login, go to home page'),
              onPressed: () {
                context.go('/home');
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('register'),
              onPressed: () {
                context.push('/login/register');
              },
            ),
          ],
        ),
      ),
    );
  }
}
