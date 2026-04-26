import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tnum_font/app.dart';
import 'package:flutter_tnum_font/core/config/render_profiles.dart';
import 'package:flutter_tnum_font/core/config/sample_strings.dart';
import 'package:flutter_tnum_font/core/models/device_debug_info.dart';
import 'package:flutter_tnum_font/core/models/font_debug_snapshot.dart';
import 'package:flutter_tnum_font/core/models/font_evidence_summary.dart';
import 'package:flutter_tnum_font/core/services/font_debug_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders all required investigation sections', (tester) async {
    await tester.pumpWidget(
      TnumDebugApp(
        service: FakeFontDebugService(
          snapshot: FontDebugSnapshot(
            deviceInfo: DeviceDebugInfo(
              manufacturer: 'Google',
              model: 'Pixel 9',
              androidRelease: '16',
              sdkInt: 36,
              requestedFamily: 'sans-serif',
              usingBundledFont: false,
              bundledFontFamilyName: null,
            ),
            evidenceSummary: FontEvidenceSummary.fromProbe(
              requestedFamily: 'sans-serif',
              usesBundledFont: false,
              bundledFontFamilyName: null,
              systemCandidates: const ['Roboto-Regular.ttf'],
              nativeEvidence: const [
                'SystemFonts.getAvailableFonts()：120 個 system font files',
              ],
              readableConfigPaths: const ['/system/etc/fonts.xml'],
              limitations: const [],
            ),
            activeProfile: RenderProfile.systemSans(),
            sampleCases: SampleStringCase.defaults(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('裝置資訊'), findsOneWidget);
    expect(find.text('字體證據'), findsOneWidget);
    expect(find.text('字串矩陣'), findsNothing);
    expect(find.text('tnum 對照'), findsOneWidget);
    expect(find.text('111111'), findsNothing);
    expect(find.text('888888'), findsNothing);
    expect(find.text('1234567890'), findsNothing);
    expect(find.text('00:00:00'), findsNothing);
    expect(find.text('1,111.11'), findsNothing);
    expect(find.text('04-22 中場'), findsWidgets);
    expect(find.text('04-22 點球PK'), findsWidgets);
    expect(find.text('04-22 加時賽'), findsWidgets);
    expect(find.text('tnum 開啟'), findsWidgets);
    expect(find.text('tnum 關閉'), findsWidgets);
    expect(find.text('混合字體例子'), findsOneWidget);
    expect(find.textContaining('闊度：'), findsNWidgets(6));
    for (final textWidget in tester.widgetList<Text>(find.text('04-22 加時賽'))) {
      expect(textWidget.maxLines, 1);
      expect(textWidget.style?.fontSize, 20);
    }

    for (final status in ['中場', '點球PK', '加時賽']) {
      final mixedLine = tester
          .widgetList<RichText>(
            find.byWidgetPredicate((widget) {
              if (widget is! RichText ||
                  widget.text.toPlainText() != '04-22 $status') {
                return false;
              }

              final text = widget.text;
              return text is TextSpan && text.children?.length == 2;
            }),
          )
          .single;
      final mixedLineSpan = mixedLine.text as TextSpan;
      final mixedLineChildren = mixedLineSpan.children!.cast<TextSpan>();

      expect(mixedLineChildren, hasLength(2));
      expect(mixedLineChildren.first.text, '04-22');
      expect(
        mixedLineChildren.first.style?.fontFeatures,
        anyOf(isNull, isEmpty),
      );
      expect(mixedLineChildren.last.text, ' $status');
      expect(
        mixedLineChildren.last.style?.fontFeatures?.map(
          (feature) => feature.feature,
        ),
        contains('tnum'),
      );
    }

    final tnumTop = tester.getTopLeft(find.text('tnum 對照')).dy;
    final renderTop = tester.getTopLeft(find.text('Render 設定')).dy;
    final deviceTop = tester.getTopLeft(find.text('裝置資訊')).dy;
    final evidenceTop = tester.getTopLeft(find.text('字體證據')).dy;

    expect(tnumTop, lessThan(renderTop));
    expect(tnumTop, lessThan(deviceTop));
    expect(tnumTop, lessThan(evidenceTop));
  });

  testWidgets('shows inconclusive label when attribution is unsupported', (
    tester,
  ) async {
    await tester.pumpWidget(
      TnumDebugApp(
        service: FakeFontDebugService(
          snapshot: FontDebugSnapshot(
            deviceInfo: DeviceDebugInfo(
              manufacturer: 'Samsung',
              model: 'SM-S938B',
              androidRelease: '16',
              sdkInt: 36,
              requestedFamily: null,
              usingBundledFont: false,
              bundledFontFamilyName: null,
            ),
            evidenceSummary: FontEvidenceSummary.fromProbe(
              requestedFamily: null,
              usesBundledFont: false,
              bundledFontFamilyName: null,
              systemCandidates: const [],
              nativeEvidence: const [],
              readableConfigPaths: const [],
              limitations: const ['OEM customization 無法讀取'],
            ),
            activeProfile: RenderProfile.systemDefault(),
            sampleCases: SampleStringCase.defaults(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('inconclusive / 無法確認'), findsWidgets);
  });

  testWidgets('keeps scroll position while render profile is reloading', (
    tester,
  ) async {
    final service = ControlledFontDebugService();

    await tester.pumpWidget(TnumDebugApp(service: service));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Render 設定'));
    await tester.pump();

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byKey(const ValueKey<String>('font-debug-scroll-view')),
    );
    final positionBefore = scrollView.controller!.position.pixels;
    expect(positionBefore, greaterThan(0));

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('monospace').last);
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('font-debug-scroll-view')),
      findsOneWidget,
    );
    expect(scrollView.controller!.position.pixels, positionBefore);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    service.completePending();
    await tester.pumpAndSettle();

    final updatedScrollView = tester.widget<SingleChildScrollView>(
      find.byKey(const ValueKey<String>('font-debug-scroll-view')),
    );
    expect(updatedScrollView.controller!.position.pixels, positionBefore);
  });
}

class FakeFontDebugService implements FontDebugService {
  FakeFontDebugService({required this.snapshot});

  final FontDebugSnapshot snapshot;

  @override
  Future<FontDebugSnapshot> loadSnapshot({
    required RenderProfile profile,
    required List<SampleStringCase> sampleCases,
  }) async {
    return snapshot;
  }
}

class ControlledFontDebugService implements FontDebugService {
  Completer<FontDebugSnapshot>? _pendingCompleter;
  RenderProfile? _pendingProfile;
  List<SampleStringCase> _pendingSampleCases = const [];
  int _loadCount = 0;

  @override
  Future<FontDebugSnapshot> loadSnapshot({
    required RenderProfile profile,
    required List<SampleStringCase> sampleCases,
  }) {
    _loadCount += 1;
    if (_loadCount == 1) {
      return Future<FontDebugSnapshot>.value(
        _buildSnapshot(profile: profile, sampleCases: sampleCases),
      );
    }

    _pendingProfile = profile;
    _pendingSampleCases = sampleCases;
    _pendingCompleter = Completer<FontDebugSnapshot>();
    return _pendingCompleter!.future;
  }

  void completePending() {
    final profile = _pendingProfile;
    final completer = _pendingCompleter;
    if (profile == null || completer == null || completer.isCompleted) {
      return;
    }

    completer.complete(
      _buildSnapshot(profile: profile, sampleCases: _pendingSampleCases),
    );
  }

  FontDebugSnapshot _buildSnapshot({
    required RenderProfile profile,
    required List<SampleStringCase> sampleCases,
  }) {
    return FontDebugSnapshot(
      deviceInfo: DeviceDebugInfo(
        manufacturer: 'Google',
        model: 'Pixel 9',
        androidRelease: '16',
        sdkInt: 36,
        requestedFamily: profile.requestedFamily,
        usingBundledFont: profile.usingBundledFont,
        bundledFontFamilyName: profile.bundledFontFamilyName,
      ),
      evidenceSummary: FontEvidenceSummary.fromProbe(
        requestedFamily: profile.requestedFamily,
        usesBundledFont: profile.usingBundledFont,
        bundledFontFamilyName: profile.bundledFontFamilyName,
        systemCandidates: const ['Roboto-Regular.ttf'],
        nativeEvidence: const [
          'SystemFonts.getAvailableFonts()：120 個 system font files',
        ],
        readableConfigPaths: const ['/system/etc/fonts.xml'],
        limitations: const [],
      ),
      activeProfile: profile,
      sampleCases: sampleCases,
    );
  }
}
