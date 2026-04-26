import 'package:flutter_tnum_font/core/config/render_profiles.dart';
import 'package:flutter_tnum_font/core/models/font_debug_snapshot.dart';
import 'package:flutter_tnum_font/core/models/sample_string_case.dart';

abstract class FontDebugService {
  Future<FontDebugSnapshot> loadSnapshot({
    required RenderProfile profile,
    required List<SampleStringCase> sampleCases,
  });
}
