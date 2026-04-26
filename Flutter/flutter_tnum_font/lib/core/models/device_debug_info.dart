class DeviceDebugInfo {
  const DeviceDebugInfo({
    required this.manufacturer,
    required this.model,
    required this.androidRelease,
    required this.sdkInt,
    required this.requestedFamily,
    required this.usingBundledFont,
    required this.bundledFontFamilyName,
  });

  final String manufacturer;
  final String model;
  final String androidRelease;
  final int sdkInt;
  final String? requestedFamily;
  final bool usingBundledFont;
  final String? bundledFontFamilyName;

  String get configuredFamilyLabel {
    if (requestedFamily == null || requestedFamily!.isEmpty) {
      return '系統預設';
    }

    return requestedFamily!;
  }

  String get renderPathLabel {
    if (usingBundledFont && bundledFontFamilyName != null) {
      return '隨附自訂字體';
    }

    return '系統 / Android 字體路徑';
  }
}
