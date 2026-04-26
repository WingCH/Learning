import 'package:flutter/services.dart';
import 'package:flutter_tnum_font/core/config/render_profiles.dart';
import 'package:flutter_tnum_font/core/models/device_debug_info.dart';
import 'package:flutter_tnum_font/core/models/font_debug_snapshot.dart';
import 'package:flutter_tnum_font/core/models/font_evidence_summary.dart';
import 'package:flutter_tnum_font/core/models/sample_string_case.dart';
import 'package:flutter_tnum_font/core/services/font_debug_service.dart';

class PlatformFontDebugService implements FontDebugService {
  PlatformFontDebugService({required MethodChannel channel})
    : _channel = channel;

  final MethodChannel _channel;

  @override
  Future<FontDebugSnapshot> loadSnapshot({
    required RenderProfile profile,
    required List<SampleStringCase> sampleCases,
  }) async {
    try {
      final result = await _channel.invokeMapMethod<Object?, Object?>(
        'getDebugSnapshot',
        <String, Object?>{
          'requestedFamily': profile.requestedFamily,
          'usesBundledFont': profile.usingBundledFont,
          'bundledFontFamilyName': profile.bundledFontFamilyName,
          'sampleStrings': sampleCases.map((item) => item.value).toList(),
        },
      );

      final payload = Map<Object?, Object?>.from(
        result ?? <Object?, Object?>{},
      );
      final evidenceSummary = FontEvidenceSummary.fromProbe(
        requestedFamily: profile.requestedFamily,
        usesBundledFont: profile.usingBundledFont,
        bundledFontFamilyName: profile.bundledFontFamilyName,
        systemCandidates: _asStringList(payload['systemCandidates']),
        nativeEvidence: _asStringList(payload['nativeEvidence']),
        readableConfigPaths: _asStringList(payload['readableConfigPaths']),
        limitations: _asStringList(payload['limitations']),
      );

      return FontDebugSnapshot(
        deviceInfo: DeviceDebugInfo(
          manufacturer: _asString(payload['manufacturer'], '無法取得'),
          model: _asString(payload['model'], '無法取得'),
          androidRelease: _asString(payload['androidRelease'], '無法取得'),
          sdkInt: _asInt(payload['sdkInt']),
          requestedFamily: profile.requestedFamily,
          usingBundledFont: profile.usingBundledFont,
          bundledFontFamilyName: profile.bundledFontFamilyName,
        ),
        evidenceSummary: evidenceSummary,
        activeProfile: profile,
        sampleCases: sampleCases,
      );
    } on MissingPluginException catch (error) {
      return _buildFallbackSnapshot(
        profile: profile,
        sampleCases: sampleCases,
        reason: 'Platform channel 無法使用：${error.message}',
      );
    } on PlatformException catch (error) {
      return _buildFallbackSnapshot(
        profile: profile,
        sampleCases: sampleCases,
        reason: 'Android 偵測失敗：${error.message ?? error.code}',
      );
    }
  }

  FontDebugSnapshot _buildFallbackSnapshot({
    required RenderProfile profile,
    required List<SampleStringCase> sampleCases,
    required String reason,
  }) {
    return FontDebugSnapshot(
      deviceInfo: DeviceDebugInfo(
        manufacturer: '無法取得',
        model: '無法取得',
        androidRelease: '無法取得',
        sdkInt: 0,
        requestedFamily: profile.requestedFamily,
        usingBundledFont: profile.usingBundledFont,
        bundledFontFamilyName: profile.bundledFontFamilyName,
      ),
      evidenceSummary: FontEvidenceSummary.fromProbe(
        requestedFamily: profile.requestedFamily,
        usesBundledFont: profile.usingBundledFont,
        bundledFontFamilyName: profile.bundledFontFamilyName,
        systemCandidates: const [],
        nativeEvidence: const [],
        readableConfigPaths: const [],
        limitations: <String>[reason],
      ),
      activeProfile: profile,
      sampleCases: sampleCases,
    );
  }

  static String _asString(Object? value, String fallback) {
    if (value is String && value.isNotEmpty) {
      return value;
    }

    return fallback;
  }

  static int _asInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  static List<String> _asStringList(Object? value) {
    if (value is List<Object?>) {
      return value
          .map((item) => item?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (value is List<dynamic>) {
      return value
          .map((item) => item?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return const [];
  }
}
