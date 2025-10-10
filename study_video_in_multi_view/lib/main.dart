import 'package:flutter/material.dart';
import 'controllers/global_pip_controller.dart';
import 'widgets/pip/global_pip_overlay.dart';
import 'pages/video_multi_view_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GlobalPipController _pipController;

  @override
  void initState() {
    super.initState();
    _pipController = GlobalPipController();
  }

  @override
  void dispose() {
    _pipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Multi-View Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return GlobalPipOverlay(
          pipController: _pipController,
          child: child ?? const SizedBox(),
        );
      },
      home: VideoMultiViewPage(pipController: _pipController),
    );
  }
}
