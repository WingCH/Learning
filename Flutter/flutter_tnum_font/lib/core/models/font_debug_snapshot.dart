import 'package:flutter_tnum_font/core/config/render_profiles.dart';
import 'package:flutter_tnum_font/core/models/device_debug_info.dart';
import 'package:flutter_tnum_font/core/models/font_evidence_summary.dart';
import 'package:flutter_tnum_font/core/models/sample_string_case.dart';

class FontDebugSnapshot {
  const FontDebugSnapshot({
    required this.deviceInfo,
    required this.evidenceSummary,
    required this.activeProfile,
    required this.sampleCases,
  });

  final DeviceDebugInfo deviceInfo;
  final FontEvidenceSummary evidenceSummary;
  final RenderProfile activeProfile;
  final List<SampleStringCase> sampleCases;
}
