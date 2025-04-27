import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// A [DismissiblePane] motion which animates actions as if they were scrolling
/// out during dismissal, with the furthest action emphasized.
/// A [DismissiblePane] motion which will make the furthest action grows faster
/// as the [Slidable] scrolls.
class InversedScrollMotion extends StatelessWidget {
  /// Creates a [InversedScrollMotion].
  const InversedScrollMotion({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final paneData = ActionPane.of(context)!;
    final controller = Slidable.of(context)!;

    final scrollingOutOffset =
        Offset(paneData.extentRatio, paneData.alignment.y);

    final endAnimation = controller.animation
        .drive(CurveTween(curve: Interval(0, paneData.extentRatio)))
        .drive(Tween(begin: scrollingOutOffset, end: Offset.zero));

    return SlideTransition(
      position: endAnimation,
      child: const InversedDrawerMotion(),
    );
  }
}
