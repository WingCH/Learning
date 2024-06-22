import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_base_bloc/pages/counter/view.dart';

import 'app_bloc_observer.dart';
import 'pages/login/view.dart';

void main() {
  Bloc.observer = const AppBlocObserver();
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        LoginPage.routeName: (context) => const LoginPage(),
        CounterPage.routeName: (context) => const CounterPage(),
      },
      initialRoute: LoginPage.routeName,
    );
  }
}
