import 'package:flutter/material.dart';
import '../controllers/global_pip_controller.dart';
import '../managers/video_player_manager.dart';
import 'layouts/pip_view_layout.dart';
import 'second_page.dart';

/// 主頁面 - PIP 模式視圖
class VideoMultiViewPage extends StatefulWidget {
  final GlobalPipController pipController;

  const VideoMultiViewPage({
    super.key,
    required this.pipController,
  });

  @override
  State<VideoMultiViewPage> createState() => _VideoMultiViewPageState();
}

class _VideoMultiViewPageState extends State<VideoMultiViewPage> {
  late final VideoPlayerManager _videoManager;

  @override
  void initState() {
    super.initState();
    _videoManager = VideoPlayerManager();
    _initializeVideo();
    widget.pipController.initialize(_videoManager);
  }

  Future<void> _initializeVideo() async {
    await _videoManager.initialize(
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      () {
        if (mounted) setState(() {});
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    // 不在這裡 dispose videoManager，由 GlobalPipController 管理
    super.dispose();
  }

  void _togglePlayPause() {
    final controller = _videoManager.controller;
    if (controller != null) {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
      setState(() {});
    }
  }

  void _navigateToSecondPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecondPage(pipController: widget.pipController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.pipController,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text('PIP 模式 - 視頻在: ${widget.pipController.isViewA ? "紅色格" : "綠色格"}'),
          ),
          body: PipViewLayout(
            isViewA: widget.pipController.isViewA,
            videoManager: _videoManager,
            onRetry: _initializeVideo,
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'navigate',
                onPressed: _navigateToSecondPage,
                tooltip: '前往第二頁',
                child: const Icon(Icons.arrow_forward),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: 'switch',
                onPressed: widget.pipController.switchView,
                tooltip: '切換播放格子',
                child: const Icon(Icons.swap_horiz),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: 'playPause',
                onPressed: _togglePlayPause,
                tooltip: '播放/暫停',
                child: Icon(
                  _videoManager.controller?.value.isPlaying ?? false
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

