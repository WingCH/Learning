import 'dart:async';

import 'package:alchemist/alchemist.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      ciGoldensConfig: CiGoldensConfig(
        enabled: true,
      ),
      platformGoldensConfig: PlatformGoldensConfig(
        
        enabled: true,
      ),

    ),
    run: testMain,
  );
}
