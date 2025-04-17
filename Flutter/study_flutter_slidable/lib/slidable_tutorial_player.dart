import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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

  static SlidablePlayerState? of(BuildContext context) {
    return context.findAncestorStateOfType<SlidablePlayerState>();
  }
}

class SlidablePlayerState extends State<SlidablePlayer> {
  final Set<SlidableController?> controllers = <SlidableController?>{};

  @override
  void initState() {
    super.initState();
    widget.animation!.addListener(handleAnimationChanged);
  }

  @override
  void dispose() {
    widget.animation!.removeListener(handleAnimationChanged);
    super.dispose();
  }

  void handleAnimationChanged() {
    final value = widget.animation!.value;
    for (var controller in controllers) {
      // right side
      controller!.ratio = -value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class SlidableControllerSender extends StatefulWidget {
  const SlidableControllerSender({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  SlidableControllerSenderState createState() =>
      SlidableControllerSenderState();
}

class SlidableControllerSenderState extends State<SlidableControllerSender> {
  SlidableController? controller;
  SlidablePlayerState? playerState;

  @override
  void initState() {
    super.initState();
    controller = Slidable.of(context);
    playerState = SlidablePlayer.of(context);
    playerState!.controllers.add(controller);
  }

  @override
  void dispose() {
    playerState!.controllers.remove(controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}