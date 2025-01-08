import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'stack_base/stack_base_demo_controller.dart';

class StackBaseDemo extends StatefulWidget {
  const StackBaseDemo({super.key});

  @override
  State<StackBaseDemo> createState() => _StackBaseDemoState();
}

class _StackBaseDemoState extends State<StackBaseDemo> {
  late final StackBaseDropdownController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StackBaseDropdownController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dropdown Menu Demo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: StackBaseDropdownMenu(
        controller: _controller,
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

class StackBaseDropdownMenu extends StatefulWidget {
  const StackBaseDropdownMenu({
    super.key,
    required this.child,
    required this.controller,
  });

  final Widget child;
  final StackBaseDropdownController controller;

  @override
  State<StackBaseDropdownMenu> createState() => _StackBaseDropdownMenuState();
}

class _StackBaseDropdownMenuState extends State<StackBaseDropdownMenu> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleStateChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleStateChange);
    super.dispose();
  }

  void _handleStateChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: widget.child,
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: widget.controller.isOpen ? 50 : -500,
          left: 0,
          right: 0,
          child: Container(
            height: 500,
            color: Colors.blue.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
