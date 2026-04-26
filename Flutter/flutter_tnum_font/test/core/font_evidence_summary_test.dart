import 'package:flutter_tnum_font/core/models/font_evidence_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns candidate when system evidence points to possible fonts', () {
    final summary = FontEvidenceSummary.fromProbe(
      requestedFamily: 'sans-serif',
      usesBundledFont: false,
      bundledFontFamilyName: null,
      systemCandidates: const ['Roboto-Regular.ttf', 'Roboto-Bold.ttf'],
      nativeEvidence: const [
        'SystemFonts.getAvailableFonts()：120 個 system font files',
      ],
      readableConfigPaths: const ['/system/etc/fonts.xml'],
      limitations: const [],
    );

    expect(summary.state, FontEvidenceState.candidate);
    expect(summary.items.any((item) => item.label == '指定 family'), isTrue);
    expect(
      summary.items.any((item) => item.label == 'Android native API'),
      isTrue,
    );
    expect(summary.items.any((item) => item.label == '系統候選'), isTrue);
  });

  test(
    'returns inconclusive when there is no supportable font attribution',
    () {
      final summary = FontEvidenceSummary.fromProbe(
        requestedFamily: null,
        usesBundledFont: false,
        bundledFontFamilyName: null,
        systemCandidates: const [],
        nativeEvidence: const [],
        readableConfigPaths: const [],
        limitations: const ['找不到可讀取的 Android 字體 config 檔案'],
      );

      expect(summary.state, FontEvidenceState.inconclusive);
      expect(summary.headline, 'inconclusive / 無法確認');
      expect(summary.items.any((item) => item.label == '限制'), isTrue);
    },
  );
}
