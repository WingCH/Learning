import 'package:flutter/material.dart';
import 'overlay_base_controller.dart';

class OverlayBaseView extends StatefulWidget {
  final Widget child;
  final Widget overlayContent;
  final Duration animationDuration;
  final VoidCallback? onOverlayTap;
  final double overlayOpacity;
  final OverlayBaseController controller;

  const OverlayBaseView({
    super.key,
    required this.child,
    required this.overlayContent,
    required this.controller,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onOverlayTap,
    this.overlayOpacity = 0.5,
  });

  @override
  State<OverlayBaseView> createState() => _OverlayBaseViewState();
}

class _OverlayBaseViewState extends State<OverlayBaseView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final LayerLink _layerLink = LayerLink();
  late final OverlayPortalController _overlayPortalController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _overlayPortalController = OverlayPortalController();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    _handleOverlayState();
  }

  void _handleOverlayState() {
    if (widget.controller.isOpen) {
      _overlayPortalController.show();
      _animationController.forward(from: 0.0);
    } else {
      _animationController.reverse().then((_) {
        _overlayPortalController.hide();
      });
    }
  }

  Widget _buildOverlayContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Transparent overlay for handling tap events
            CompositedTransformFollower(
              link: _layerLink,
              targetAnchor: Alignment.bottomCenter,
              followerAnchor: Alignment.topCenter,
              child: GestureDetector(
                onTap: widget.onOverlayTap,
                child: Container(color: Colors.transparent),
              ),
            ),
            // Animated overlay content
            CompositedTransformFollower(
              link: _layerLink,
              targetAnchor: Alignment.topCenter,
              followerAnchor: Alignment.topCenter,
              offset: const Offset(0, 0),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: _animationController.value,
                      child: Opacity(
                        opacity: _animationController.value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: widget.overlayContent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: _overlayPortalController,
        overlayChildBuilder: (context) => _buildOverlayContent(),
        child: widget.child,
      ),
    );
  }
}
