import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_performance_view/feature/case1/case1_sub_page.dart';
import 'package:study_performance_view/feature/case1/case1_page.dart';
import 'package:study_performance_view/feature/case2/case2_page.dart';
import 'package:study_performance_view/feature/case3/case3_page.dart';
import 'package:study_performance_view/feature/case3/case3_sub_page.dart';
import 'package:study_performance_view/feature/case4/case4_page.dart';
import 'package:study_performance_view/feature/home_page.dart';

void main() {
  runApp(const MainApp());
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'case1',
          builder: (context, state) => const Case1Page(),
          routes: [
            GoRoute(
              path: 'sub',
              builder: (context, state) => const Case1SubPage(),
            ),
          ],
        ),
        GoRoute(
          path: 'case2',
          builder: (context, state) => const Case2Page(),
        ),
        GoRoute(
          path: 'case3',
          builder: (context, state) => const Case3Page(),
          routes: [
            GoRoute(
              path: 'sub',
              builder: (context, state) {
                return Case3SubPage(
                  withLottie: state.uri.queryParameters['withLottie'] == 'true',
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'case4',
          builder: (context, state) => const Case4Page(),
        ),
      ],
    ),
  ],
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}
