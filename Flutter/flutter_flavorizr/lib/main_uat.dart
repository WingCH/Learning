import 'package:flutter/material.dart';
import 'app.dart';
import 'env_config.dart';

void main() {
  EnvConfig.appFlavor = Flavor.UAT;
  runApp(App());
}
