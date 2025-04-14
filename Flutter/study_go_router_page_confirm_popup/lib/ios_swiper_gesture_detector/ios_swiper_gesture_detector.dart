import 'dart:math';
import 'package:flutter/material.dart';
import 'package:study_go_router_page_confirm_popup/ios_swiper_gesture_detector/drag_debug_painter.dart';

/// IOSSwiperGestureDetector is a gesture detection widget inspired by the official
/// Flutter CupertinoRouteTransitionMixin.
///
/// It primarily implements an iOS-like back gesture, allowing the user to swipe
/// right from the left edge of the screen to trigger a specific action.
///
/// Implementation details:
/// 1. Create a transparent detection area on the left edge of the screen.
/// 2. When the user starts swiping from the left edge and the swipe distance reaches the threshold, trigger the callback.
/// 3. This does not block other gesture events.
///
/// This implementation is modeled after the _CupertinoBackGestureDetector class in
/// Cupertino route transition animations, but it is simplified to focus only on
/// detecting right-swipe gestures rather than handling animations.
class IOSSwiperGestureDetector extends StatefulWidget {
  /// The main child widget.
  final Widget child;

  /// Whether to enable right-swipe detection.
  final bool enable;

  /// Called when a right-swipe gesture is detected.
  final VoidCallback onSwipe;

  /// Enable debug logs for gesture detection.
  final bool debugLog;

  const IOSSwiperGestureDetector({
    super.key,
    required this.child,
    required this.onSwipe,
    this.enable = true,
    this.debugLog = true,
  });

  @override
  State<IOSSwiperGestureDetector> createState() =>
      _IOSSwiperGestureDetectorState();
}

class _IOSSwiperGestureDetectorState extends State<IOSSwiperGestureDetector> {
  static const edgeWidth = 20.0;
  static const threshold = 0.20;

  /// Records the X coordinate of the starting point of the gesture.
  double? _startDragX;

  /// Records the current finger position.
  double? _currentDragX;

  /// Common log function that only outputs when debugLog is true.
  void _log(String message) {
    if (widget.debugLog) {
      debugPrint('IOSSwiperGestureDetector: $message');
    }
  }

  @override
  void initState() {
    super.initState();
    _log('initialized with enable=${widget.enable}');
  }

  @override
  void dispose() {
    _log('disposing');
    super.dispose();
  }

  /// Builds the gesture detection layer.
  Widget _buildGestureLayer(BuildContext context) {
    // For devices with notches, the drag area needs to be larger on the side
    // that has the notch.
    final double layerWidth =
        max(edgeWidth, MediaQuery.paddingOf(context).left);

    _log('building gesture layer with width=$layerWidth');

    return PositionedDirectional(
      start: 0.0,
      width: layerWidth,
      top: 0.0,
      bottom: 0.0,
      child: GestureDetector(
        onHorizontalDragStart: (DragStartDetails details) {
          _log('drag start at ${details.localPosition}');
          _startDragX = details.globalPosition.dx;
          _currentDragX = details.globalPosition.dx;

          // Trigger a repaint to show the visual indicator.
          if (widget.debugLog) {
            setState(() {});
          }
        },
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          _currentDragX = details.globalPosition.dx;
          _log('drag update at x=$_currentDragX');

          // Only update the visual indicator if debug mode is enabled.
          if (widget.debugLog) {
            setState(() {});
          }
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          // Ignore if there is no valid start position.
          if (_startDragX == null || _currentDragX == null) {
            _log('drag ignored - no valid start position');
            return;
          }

          // Calculate horizontal drag distance.
          final double dragDistance = _currentDragX! - _startDragX!;

          // Get screen width to calculate drag percentage.
          final double screenWidth = MediaQuery.sizeOf(context).width;
          final double dragPercentage = dragDistance / screenWidth;

          // Trigger the callback if the drag distance exceeds 20% of the screen width.
          final bool isDragEnough = dragPercentage > threshold;

          _log('drag distance=$dragDistance px, '
              'percentage=${(dragPercentage * 100).toStringAsFixed(2)}%, '
              'threshold met=$isDragEnough');

          if (isDragEnough) {
            _log('executing onSwipe callback');
            widget.onSwipe();
          }

          // Reset start position.
          _startDragX = null;
          _currentDragX = null;

          // Clear the visual indicator.
          if (widget.debugLog) {
            setState(() {});
          }
        },
        onHorizontalDragCancel: () {
          _log('drag cancelled');
          _startDragX = null;
          _currentDragX = null;

          // Clear the visual indicator.
          if (widget.debugLog) {
            setState(() {});
          }
        },
        behavior: HitTestBehavior.translucent,
      ),
    );
  }

  /// Builds the visual indicator to show the current swipe position in debug mode.
  Widget _buildDebugVisualizer() {
    if (_startDragX == null || _currentDragX == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: _startDragX!,
      top: 0,
      height: MediaQuery.sizeOf(context).height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: DragDebugPainter(
            startX: 0,
            currentX: _currentDragX! - _startDragX!,
            screenWidth: MediaQuery.sizeOf(context).width,
            showThreshold: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _log('building widget, enable=${widget.enable}');
    return Stack(
      children: [
        widget.child,
        if (widget.enable) _buildGestureLayer(context),
        if (widget.debugLog) _buildDebugVisualizer(),
      ],
    );
  }
}
