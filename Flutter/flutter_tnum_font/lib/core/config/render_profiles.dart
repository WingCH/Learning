class RenderProfile {
  const RenderProfile({
    required this.id,
    required this.label,
    required this.description,
    required this.requestedFamily,
    required this.usingBundledFont,
    required this.bundledFontFamilyName,
  });

  final String id;
  final String label;
  final String description;
  final String? requestedFamily;
  final bool usingBundledFont;
  final String? bundledFontFamilyName;

  static List<RenderProfile> defaults() {
    return const [
      RenderProfile(
        id: 'system-default',
        label: '系統預設',
        description: '不指定 family，讓 Android 自行解析預設路徑。',
        requestedFamily: null,
        usingBundledFont: false,
        bundledFontFamilyName: null,
      ),
      RenderProfile(
        id: 'sans-serif',
        label: 'sans-serif',
        description: '明確要求 Android 使用 sans-serif family。',
        requestedFamily: 'sans-serif',
        usingBundledFont: false,
        bundledFontFamilyName: null,
      ),
      RenderProfile(
        id: 'serif',
        label: 'serif',
        description: '明確要求 Android 使用 serif family。',
        requestedFamily: 'serif',
        usingBundledFont: false,
        bundledFontFamilyName: null,
      ),
      RenderProfile(
        id: 'monospace',
        label: 'monospace',
        description: '明確要求 Android 使用 monospace family。',
        requestedFamily: 'monospace',
        usingBundledFont: false,
        bundledFontFamilyName: null,
      ),
      RenderProfile(
        id: 'roboto',
        label: 'Roboto',
        description: '明確要求使用 Roboto family 作對照。',
        requestedFamily: 'Roboto',
        usingBundledFont: false,
        bundledFontFamilyName: null,
      ),
    ];
  }

  static RenderProfile systemDefault() {
    return defaults().firstWhere((profile) => profile.id == 'system-default');
  }

  static RenderProfile systemSans() {
    return defaults().firstWhere((profile) => profile.id == 'sans-serif');
  }
}
