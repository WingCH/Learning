import 'dart:math';

class VersionHelper {
  static bool isVersionGreaterThan(String newVersion, String currentVersion) {
    List<String> currentVComponents = currentVersion.split('.');
    List<String> newVComponents = newVersion.split('.');

    for (var i = 0;
        i < max(currentVComponents.length, newVComponents.length);
        i++) {
      final int newV = i < newVComponents.length
          ? int.tryParse(newVComponents[i]) ?? 0
          : 0;

      final int currentV = i < currentVComponents.length
          ? int.tryParse(currentVComponents[i]) ?? 0
          : 0;

      if (currentV == newV) continue;
      return (currentV < newV);
    }
    return false;
  }
}