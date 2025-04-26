import 'package:flutter/material.dart';

/// A wrapper that prevents horizontal swipe events from propagating to parent Slidable
class SlidableBlocker extends StatelessWidget {
  /// The child widget to be protected
  final Widget child;

  /// Whether blocking is enabled
  final bool enabled;

  /// Creates a wrapper that blocks horizontal swipe events from reaching the parent Slidable
  ///
  /// By intercepting horizontal drag events, it ensures these events won't trigger
  /// the sliding behavior of the parent Slidable
  const SlidableBlocker({
    super.key,
    required this.child,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return enabled
        ? GestureDetector(
            // These empty implementations intercept horizontal drag events,
            // preventing them from propagating to the parent Slidable
            onHorizontalDragCancel: () {},
            onHorizontalDragStart: (_) {},
            onHorizontalDragUpdate: (_) {},
            onHorizontalDragEnd: (_) {},
            // AbsorbPointer seems cannot prevent user swiping the slidable item, so we use GestureDetector to block the gesture events
            child: AbsorbPointer(
              absorbing: enabled,
              child: child,
            ),
          )
        : child;
  }
}
