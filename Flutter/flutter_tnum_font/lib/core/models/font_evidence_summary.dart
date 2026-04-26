enum FontEvidenceState { confirmed, candidate, inconclusive }

enum FontEvidenceTone { evidence, limitation }

class FontEvidenceItem {
  const FontEvidenceItem({
    required this.label,
    required this.detail,
    required this.tone,
  });

  final String label;
  final String detail;
  final FontEvidenceTone tone;
}

class FontEvidenceSummary {
  const FontEvidenceSummary({
    required this.state,
    required this.headline,
    required this.items,
  });

  final FontEvidenceState state;
  final String headline;
  final List<FontEvidenceItem> items;

  factory FontEvidenceSummary.fromProbe({
    required String? requestedFamily,
    required bool usesBundledFont,
    required String? bundledFontFamilyName,
    required List<String> systemCandidates,
    required List<String> nativeEvidence,
    required List<String> readableConfigPaths,
    required List<String> limitations,
  }) {
    final distinctCandidates = systemCandidates.toSet().toList();
    final distinctNativeEvidence = nativeEvidence.toSet().toList();
    final distinctPaths = readableConfigPaths.toSet().toList();
    final distinctLimitations = limitations.toSet().toList();
    final items = <FontEvidenceItem>[
      FontEvidenceItem(
        label: '指定 family',
        detail: requestedFamily ?? '系統預設',
        tone: FontEvidenceTone.evidence,
      ),
      FontEvidenceItem(
        label: 'Render 路徑',
        detail: usesBundledFont ? '隨附自訂字體' : '系統 / Android 字體路徑',
        tone: FontEvidenceTone.evidence,
      ),
    ];

    if (usesBundledFont && bundledFontFamilyName != null) {
      items.add(
        FontEvidenceItem(
          label: '隨附字體',
          detail: bundledFontFamilyName,
          tone: FontEvidenceTone.evidence,
        ),
      );
    }

    if (distinctNativeEvidence.isNotEmpty) {
      items.add(
        FontEvidenceItem(
          label: 'Android native API',
          detail: distinctNativeEvidence.join('\n'),
          tone: FontEvidenceTone.evidence,
        ),
      );
    }

    if (distinctPaths.isNotEmpty) {
      items.add(
        FontEvidenceItem(
          label: '可讀取的 config',
          detail: distinctPaths.join('\n'),
          tone: FontEvidenceTone.evidence,
        ),
      );
    }

    if (distinctCandidates.isNotEmpty) {
      items.add(
        FontEvidenceItem(
          label: '系統候選',
          detail: distinctCandidates.join('\n'),
          tone: FontEvidenceTone.evidence,
        ),
      );
    }

    for (final limitation in distinctLimitations) {
      items.add(
        FontEvidenceItem(
          label: '限制',
          detail: limitation,
          tone: FontEvidenceTone.limitation,
        ),
      );
    }

    final state = _resolveState(
      usesBundledFont: usesBundledFont,
      bundledFontFamilyName: bundledFontFamilyName,
      distinctCandidates: distinctCandidates,
    );

    return FontEvidenceSummary(
      state: state,
      headline: _headlineForState(state),
      items: List<FontEvidenceItem>.unmodifiable(items),
    );
  }

  static FontEvidenceState _resolveState({
    required bool usesBundledFont,
    required String? bundledFontFamilyName,
    required List<String> distinctCandidates,
  }) {
    if (usesBundledFont && bundledFontFamilyName != null) {
      return FontEvidenceState.confirmed;
    }

    if (distinctCandidates.isNotEmpty) {
      return FontEvidenceState.candidate;
    }

    return FontEvidenceState.inconclusive;
  }

  static String _headlineForState(FontEvidenceState state) {
    switch (state) {
      case FontEvidenceState.confirmed:
        return 'confirmed / 已確認';
      case FontEvidenceState.candidate:
        return 'candidate / 候選';
      case FontEvidenceState.inconclusive:
        return 'inconclusive / 無法確認';
    }
  }
}
