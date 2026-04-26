import 'package:flutter/material.dart';
import 'package:flutter_tnum_font/core/services/font_debug_service.dart';
import 'package:flutter_tnum_font/features/font_debug/font_debug_screen.dart';

class TnumDebugApp extends StatelessWidget {
  const TnumDebugApp({required this.service, super.key});

  final FontDebugService service;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0B7285),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Android tnum 偵測工具',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF4F1EA),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: FontDebugScreen(service: service),
    );
  }
}
