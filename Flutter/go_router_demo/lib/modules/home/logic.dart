import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_route_names.dart';
import 'state.dart';

class HomeLogic extends GetxController {
  final HomeState state = HomeState();

  void goToUserInfoPage({
    required BuildContext context,
  }) {
    // context.goNamed(AppRouteName.login);
    context.goNamed(AppRouteName.userInfo);
  }
}
