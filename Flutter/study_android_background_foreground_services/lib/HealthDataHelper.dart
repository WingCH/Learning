import 'package:flutter/cupertino.dart';
import 'package:health/health.dart';

class HealthDataHelper {
  Future<int?> fetchStepData() async {
    int? steps;

    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    final week = DateTime(now.year, now.month, now.day - 7);

    bool stepsPermission = await Health().hasPermissions([HealthDataType.STEPS]) ?? false;
    if (!stepsPermission) {
      stepsPermission = await Health().requestAuthorization([HealthDataType.STEPS]);
    }

    if (stepsPermission) {
      try {
        steps = await Health().getTotalStepsInInterval(week, now);
      } catch (error) {
        debugPrint("Exception in getTotalStepsInInterval: $error");
      }

      debugPrint('Total number of steps: $steps');

      return steps;
    } else {
      debugPrint("Authorization not granted - error in authorization");
      return null;
    }
  }
}
