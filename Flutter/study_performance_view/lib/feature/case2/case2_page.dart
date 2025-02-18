import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Case2Page extends StatefulWidget {
  const Case2Page({super.key});

  @override
  State<Case2Page> createState() => _Case2PageState();
}

class _Case2PageState extends State<Case2Page> {
  bool show10Lottie = true;

  // List of additional Lottie asset paths when toggle is on.
  static const List<String> extraLottieAssets = [
    'assets/game_in.json',
    'assets/game_out.json',
    'assets/home_in.json',
    'assets/home_out.json',
    'assets/inplay_continued_blue.json',
    'assets/inplay_continued_gray.json',
    'assets/inplay_in.json',
    'assets/inplay_out.json',
    'assets/mine_in.json',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 封裝為獨立組件來管理各自的 AnimationController
  Widget buildLottie(String assetPath) {
    return AnimatedLottieWidget(assetPath: assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case2 Page'),
        actions: [
          // Button to stop all Lottie animations
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () {
              // _lottieController.stop();
            },
          ),
          // Button to resume all Lottie animations
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              // _lottieController.repeat();
            },
          ),
          // Button to navigate to a subpage
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: () async {
              // _lottieController.stop();
              context.go('/case2/sub');
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Toggle switch for additional animations.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Switch(
                    value: show10Lottie,
                    onChanged: (value) {
                      setState(() {
                        show10Lottie = value;
                      });
                    },
                  ),
                  const Text('Show 10 Lottie'),
                ],
              ),
              // Primary Lottie animation
              buildLottie('assets/favoriteActive.json'),
              // Display additional Lottie animations when toggle is on.
              if (show10Lottie)
                ...extraLottieAssets.map((asset) => buildLottie(asset)),
            ],
          ),
        ],
      ),
    );
  }
}

/// 新的獨立組件用於管理自己的 AnimationController
class AnimatedLottieWidget extends StatefulWidget {
  final String assetPath;

  const AnimatedLottieWidget({super.key, required this.assetPath});

  @override
  State<AnimatedLottieWidget> createState() => _AnimatedLottieWidgetState();
}

class _AnimatedLottieWidgetState extends State<AnimatedLottieWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.assetPath),
      onVisibilityChanged: (VisibilityInfo info) {
        debugPrint(
            '${widget.assetPath} is ${info.visibleFraction * 100}% visible');
        if (info.visibleFraction == 0) {
          _controller.stop();
        } else {
          _controller.repeat();
        }
      },
      child: Lottie.asset(
        widget.assetPath,
        controller: _controller,
        renderCache: RenderCache.raster,
      ),
    );
  }
}
