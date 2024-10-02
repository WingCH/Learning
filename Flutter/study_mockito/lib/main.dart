import 'package:flutter/material.dart';
import 'version_helper.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 示例：使用 VersionHelper
    bool isNewer = VersionHelper.isVersionGreaterThan('1.2.3', '1.2.0');
    String message = isNewer ? '新版本可用' : '已是最新版本';

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }
}
