import 'package:flutter/material.dart';

import 'custom_modal_bottom_sheet_route.dart';

class BottomPageArguments {
  final double maxHeight;
  final CapturedThemes capturedThemes;

  BottomPageArguments({
    required this.maxHeight,
    required this.capturedThemes,
  });
}

class BottomPage extends StatelessWidget {
  const BottomPage({Key? key}) : super(key: key);

  static const String routeName = '/bottom';

  static Route<void> route(RouteSettings settings) {
    BottomPageArguments arguments = settings.arguments as BottomPageArguments;
    return CustomModalBottomSheetRoute(
      settings: settings,
      capturedThemes: arguments.capturedThemes,
      isScrollControlled: false,
      constraints: BoxConstraints(maxHeight: arguments.maxHeight),
      builder: (context) {
        return const BottomPage();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('BottomPage'),
      ),
    );
  }
}
