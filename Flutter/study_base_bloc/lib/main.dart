import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_bloc_observer.dart';
import 'pages/counter/counter_page.dart';
import 'pages/login/login_page.dart';

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
      onGenerateRoute: (settings) {
        if (settings.name == CounterPage.routeName) {
          return CounterPage.route(settings);
        }
        if (settings.name == LoginPage.routeName) {
          return LoginPage.route(settings);
        }
        return null;
      },
      initialRoute: LoginPage.routeName,
    );
  }
}
