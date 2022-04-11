import 'package:go_router/go_router.dart';
import 'package:go_router_demo/modules/user_info/view.dart';

import '../modules/home/view.dart';
import '../modules/login/view.dart';
import 'app_route_names.dart';

class AppRouter {
  late final router = GoRouter(
    // TODO: https://gorouter.dev/redirection#refreshing-with-a-stream
    // refreshListenable:
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        redirect: (_) => '/home',
      ),
      GoRoute(
        name: AppRouteName.home,
        path: '/home',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            name: AppRouteName.userInfo,
            path: 'userInfo',
            builder: (context, state) => const UserInfoPage(),
          ),
        ]
      ),
      GoRoute(
        name: AppRouteName.login,
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );
}
