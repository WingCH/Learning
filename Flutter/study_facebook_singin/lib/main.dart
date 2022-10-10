import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LoginStatus? _loginStatus;
  Map<String, dynamic>? _userData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton(
              child: const Text('Login with Facebook'),
              onPressed: () async {
                final LoginResult result = await FacebookAuth.instance.login();
                setState(() {
                  _loginStatus = result.status;
                });
                if (result.status == LoginStatus.success) {
                  // you are logged
                  final AccessToken accessToken = result.accessToken!;

                  final userData = await FacebookAuth.instance.getUserData(
                    fields:
                        "name,email,picture.width(200),birthday,friends,gender,link",
                  );
                  setState(() {
                    _userData = userData;
                  });
                }
              },
            ),
            Text('LoginStatus', style: Theme.of(context).textTheme.headline6),
            Text(_loginStatus.toString()),
            const SizedBox(height: 16),
            Text('UserData', style: Theme.of(context).textTheme.headline6),
            Text(_userData.toString()),
          ],
        ),
      ),
    );
  }
}
