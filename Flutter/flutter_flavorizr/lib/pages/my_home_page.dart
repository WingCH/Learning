import 'package:flutter/material.dart';

import '../env_config.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(EnvConfig.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              EnvConfig.title,
            ),
            Text(
              'Base Url ${EnvConfig.baseUrl}',
            ),
          ],
        ),
      ),
    );
  }
}
