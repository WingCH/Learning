import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class Case5Page extends StatefulWidget {
  const Case5Page({super.key});

  @override
  State<Case5Page> createState() => _Case5PageState();
}

class _Case5PageState extends State<Case5Page> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
        Uri.parse('https://live5.hengbeixingtech.com/live/52423_nsd.m3u8'))
      ..initialize().then(
        (_) async {
          await _controller!.play();
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              _controller?.value.isInitialized ?? false
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : Container(),
            ],
          ),
          TextButton(
            onPressed: () {
              // _controller?.pause();
              // _controller?.dispose();
              // _controller = null;
              context.go('/case5/sub');
            },
            child: const Text('Sub Page'),
          ),
          // Expanded(child: Case2Page()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller?.value.isPlaying ?? false
                ? _controller?.pause()
                : _controller?.play();
          });
        },
        child: Icon(
          _controller?.value.isPlaying ?? false
              ? Icons.pause
              : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
