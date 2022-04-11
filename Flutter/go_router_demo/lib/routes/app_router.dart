import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_demo/modules/user_info/view.dart';

import '../modules/home/logic.dart';
import '../modules/home/view.dart';
import '../modules/login/logic.dart';
import '../modules/login/view.dart';
import '../modules/user_info/logic.dart';
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
          builder: (context, state) {
            Get.put(HomeLogic());
            return const HomePage();
          },
          routes: [
            GoRoute(
              name: AppRouteName.userInfo,
              path: 'userInfo',
              builder: (context, state) {
                Get.put(UserInfoLogic());
                return const UserInfoPage();
              },
            ),
          ]),
      GoRoute(
        name: AppRouteName.login,
        path: '/login',
        builder: (context, state) {
          Get.put(LoginLogic());
          return const LoginPage();
        },
      ),
    ],
  );
}
