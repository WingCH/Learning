import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'demo_list.dart';
import 'overlay_base/overlay_base_demo.dart';
import 'stack_base/stack_base_demo.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const DemoList();
      },
      routes: [
        GoRoute(
          path: 'stack-base',
          builder: (BuildContext context, GoRouterState state) {
            return const StackBaseDemo();
          },
        ),
        GoRoute(
          path: 'overlay-base',
          builder: (BuildContext context, GoRouterState state) {
            return const OverlayBaseDemo();
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}
