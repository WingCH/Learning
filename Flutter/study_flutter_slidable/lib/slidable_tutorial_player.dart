import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:slidable_bookmarks/slidable_blocker.dart';

// Widget that handles animation playback for slidable tutorial
class SlidablePlayer extends StatefulWidget {
  const SlidablePlayer({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double>? animation;
  final Widget child;

  @override
  SlidablePlayerState createState() => SlidablePlayerState();

  // Helper method to find the SlidablePlayer ancestor from a context
  static SlidablePlayerState? of(BuildContext context) {
    return context.findAncestorStateOfType<SlidablePlayerState>();
  }
}

class SlidablePlayerState extends State<SlidablePlayer> {
  // Set to store all registered slidable controllers
  final Set<SlidableController?> controllers = <SlidableController?>{};

  @override
  void initState() {
    super.initState();
    // Listen to animation changes
    widget.animation?.addListener(handleAnimationChanged);
  }

  @override
  void dispose() {
    // Clean up animation listener
    widget.animation?.removeListener(handleAnimationChanged);
    super.dispose();
  }

  // Update all registered controllers based on animation value
  void handleAnimationChanged() {
    final value = widget.animation?.value;
    if (value == null) return;
    for (var controller in controllers) {
      // Apply animation to right side (negative value)
      controller!.ratio = -value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Widget that connects a slidable item to the SlidablePlayer for automated tutorials
class SlidableControllerSender extends StatefulWidget {
  const SlidableControllerSender({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  SlidableControllerSenderState createState() =>
      SlidableControllerSenderState();
}

class SlidableControllerSenderState extends State<SlidableControllerSender> {
  SlidableController? slidableController;
  SlidablePlayerState? slidablePlayerState;

  @override
  void initState() {
    super.initState();
    // Get the parent slidable controller
    slidableController = Slidable.of(context);
    // Get the player state and register this controller
    slidablePlayerState = SlidablePlayer.of(context);
    slidablePlayerState?.controllers.add(slidableController);
  }

  @override
  Widget build(BuildContext context) {
    // Intercept gesture events and prevent user interaction during tutorial
    return SlidableBlocker(
      enabled: true,
      // AbsorbPointer seems cannot prevent user swiping the slidable item, so we use SlidableBlocker to block the gesture events
      child: AbsorbPointer(
        absorbing: true,
        child: widget.child,
      ),
    );
  }
}
