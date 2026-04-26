import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tnum_font/app.dart';
import 'package:flutter_tnum_font/infrastructure/platform_font_debug_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    TnumDebugApp(
      service: PlatformFontDebugService(
        channel: const MethodChannel('flutter_tnum_font/debug'),
      ),
    ),
  );
}
