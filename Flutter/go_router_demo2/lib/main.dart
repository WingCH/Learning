import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_demo2/pages/login.dart';
import 'package:go_router_demo2/pages/menu.dart';
import 'package:go_router_demo2/pages/redemption.dart';
import 'package:go_router_demo2/pages/register.dart';

import 'pages/home.dart';
import 'pages/redemption_enter_code.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final _router = GoRouter(
    urlPathStrategy: UrlPathStrategy.path,
    debugLogDiagnostics: true,
    // routerNeglect: true,
    routes: [
      GoRoute(
        path: '/',
        redirect: (_) => '/home',
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'menu',
            builder: (context, state) => const MenuPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
        routes: [
          GoRoute(
            path: 'register',
            builder: (context, state) => const RegisterPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/redemption',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: RedemptionPage(
            queryParams: state.queryParams,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
        routes: [
          GoRoute(
            path: 'enter_code',
            builder: (context, state) => const RedemptionEnterCodePage(),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      title: 'go_router demo 2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
