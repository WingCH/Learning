import 'package:flutter/material.dart';

import 'pages/login_page.dart';
import 'utils/routes.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/login",
      routes: {
        MyRoutes.loginRoute: (context) => const LoginPage(),
      },
    );
  }
}
