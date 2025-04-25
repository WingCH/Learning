import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:slidable_bookmarks/slidable_blocker.dart';

// Animation state enum
enum TutorialAnimationState {
  idle,      // Initial or idle state
  animating, // Animation in progress
  completed  // Animation completed
}

// Widget that handles animation playback for slidable tutorial
class SlidablePlayer extends StatefulWidget {
  const SlidablePlayer({
    super.key,
    required this.child,
    required this.enableTutorial,
    required this.tutorialCount,
  });

  final Widget child;
  final bool enableTutorial;
  final int tutorialCount;

  @override
  SlidablePlayerState createState() => SlidablePlayerState();

  // Helper method to find the SlidablePlayer ancestor from a context
  static SlidablePlayerState? of(BuildContext context) {
    return context.findAncestorStateOfType<SlidablePlayerState>();
  }
}

class SlidablePlayerState extends State<SlidablePlayer>
    with SingleTickerProviderStateMixin {
  // Set to store all registered slidable controllers
  final Set<SlidableController?> controllers = <SlidableController?>{};
  
  // List of animation state change listeners
  final List<void Function(TutorialAnimationState)> _animationStateListeners = [];

  late AnimationController? controller;
  late Animation<double>? animation;
  
  // Current animation state
  TutorialAnimationState _animationState = TutorialAnimationState.idle;
  
  // Get current animation state
  TutorialAnimationState get animationState => _animationState;

  // Add animation state change listener
  void addAnimationStateListener(void Function(TutorialAnimationState) listener) {
    _animationStateListeners.add(listener);
  }
  
  // Remove animation state change listener
  void removeAnimationStateListener(void Function(TutorialAnimationState) listener) {
    _animationStateListeners.remove(listener);
  }
  
  // Register a slidable controller
  void registerController(SlidableController? controller) {
    if (controller != null) {
      controllers.add(controller);
    }
  }
  
  // Unregister a slidable controller
  void unregisterController(SlidableController? controller) {
    if (controller != null) {
      controllers.remove(controller);
    }
  }
  
  // Update animation state and notify all listeners
  void _updateAnimationState(TutorialAnimationState newState) {
    if (_animationState != newState) {
      _animationState = newState;
      for (var listener in _animationStateListeners) {
        listener(newState);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (!widget.enableTutorial) {
      controller = null;
      animation = null;
      return;
    }

    // Initialize animation controller
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      upperBound: 1.0,
    );

    // Create animation for tutorial sliding effect
    animation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(
        parent: controller!,
        curve: Curves.easeInOut,
      ),
    );

    // Listen to animation changes
    animation!.addListener(handleAnimationChanged);

    // Start tutorial sequence after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTutorialSequence();
    });

    // Update tutorial state when animation is complete
    controller!.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        _updateAnimationState(TutorialAnimationState.animating);
      } else if (status == AnimationStatus.dismissed) {
        _updateAnimationState(TutorialAnimationState.completed);
      }
    });
  }

  // Handle the tutorial animation sequence
  void _startTutorialSequence() async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.forward().orCancel;
      await Future.delayed(const Duration(milliseconds: 600));
      await controller!.reverse().orCancel;
    } on TickerCanceled {
      // The animation got canceled, probably because we were disposed.
    }
  }

  @override
  void dispose() {
    // Clean up animation listener
    animation?.removeListener(handleAnimationChanged);
    controller?.dispose();
    _animationStateListeners.clear();
    super.dispose();
  }

  // Update all registered controllers based on animation value
  void handleAnimationChanged() {
    if (animation == null) {
      return;
    }

    final value = animation!.value;
    final animationCount = widget.tutorialCount;
    for (var controller in controllers.take(animationCount)) {
      if (controller == null) {
        continue;
      }
      // Apply animation to right side (negative value)
      controller.ratio = -value;
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
 
  TutorialAnimationState animationState = TutorialAnimationState.idle;


  void _handleAnimationStateChanged(TutorialAnimationState state) {
    setState(() {
      animationState = state;
    });
  }

  @override
  void initState() {
    super.initState();
    // Get the parent slidable controller
    slidableController = Slidable.of(context);
    // Get the player state and register this controller
    slidablePlayerState = SlidablePlayer.of(context);
    slidablePlayerState?.registerController(slidableController);
    slidablePlayerState?.addAnimationStateListener(_handleAnimationStateChanged);
    
    if (slidablePlayerState != null) {
      animationState = slidablePlayerState!.animationState;
    }
  }
  
  @override
  void dispose() {
    slidablePlayerState?.removeAnimationStateListener(_handleAnimationStateChanged);
    slidablePlayerState?.unregisterController(slidableController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     bool blockUserInteraction = animationState == TutorialAnimationState.animating;
    // Intercept gesture events and prevent user interaction during tutorial
    return SlidableBlocker(
      enabled: blockUserInteraction,
      // AbsorbPointer seems cannot prevent user swiping the slidable item, so we use SlidableBlocker to block the gesture events
      child: AbsorbPointer(
        absorbing: blockUserInteraction,
        child: widget.child,
      ),
    );
  }
}
