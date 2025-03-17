import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_go_router_page_confirm_popup/current_route_display.dart';
import 'package:study_go_router_page_confirm_popup/custom_go_router.dart';
import 'package:study_go_router_page_confirm_popup/pages.dart';

import 'services/navigation_confirmation_service.dart';

void main() => runApp(const MyApp());
final navigationKey = GlobalKey<NavigatorState>();

/// The route configuration.
final GoRouter _router = CustomGoRouter(
  navigatorKey: navigationKey,
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/pageA',
      builder: (BuildContext context, GoRouterState state) {
        return const PageA();
      },
    ),
    GoRoute(
      path: '/pageB',
      builder: (BuildContext context, GoRouterState state) {
        return const PageB();
      },
    ),
  ],
  confirmationService: NavigationConfirmationService(
    navigationKey: navigationKey,
  ),
);

/// The main app.
class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: CurrentRouteDisplay(router: _router),
            ),
          ],
        );
      },
    );
  }
}
