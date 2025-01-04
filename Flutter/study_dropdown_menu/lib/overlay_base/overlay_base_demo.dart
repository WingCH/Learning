import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/filter_menu_model.dart';
import '../widgets/filter_menu_view.dart';
import 'overlay_base_controller.dart';
import 'overlay_base_view.dart';

class OverlayBaseDemo extends StatefulWidget {
  const OverlayBaseDemo({super.key});

  @override
  State<OverlayBaseDemo> createState() => _OverlayBaseDemoState();
}

class _OverlayBaseDemoState extends State<OverlayBaseDemo> {
  late final OverlayBaseController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OverlayBaseController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      appBar: AppBar(
        title: const Text('Overlay Dropdown Demo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: OverlayBaseView(
        controller: _controller,
        onOverlayTap: () => _controller.toggle(),
        overlayContent: FilterMenuView(
          initialValue: FilterMenuModel.dummy(),
          onConfirm: (selectedItemIds) {
            debugPrint('selectedItemIds: $selectedItemIds');
          },
          onReset: () {
            debugPrint('reset');
          },
        ),
        child: Container(
          height: 50,
          color: Colors.red,
          child: Center(
            child: IconButton(
              onPressed: () => _controller.toggle(),
              icon: const Icon(Icons.filter_list),
            ),
          ),
        ),
      ),
    );
  }
}
