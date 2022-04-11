import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({Key? key}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final logic = Get.put(UserInfoLogic());
  final state = Get.find<UserInfoLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('UserInfoPage'),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<UserInfoLogic>();
    super.dispose();
  }
}
