import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_performance_view/feature/case2/case2_page.dart';
import 'package:video_player/video_player.dart';

class Case6Page extends StatefulWidget {
  const Case6Page({super.key});

  @override
  State<Case6Page> createState() => _Case6PageState();
}

class _Case6PageState extends State<Case6Page> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset('assets/home_video_reduce_bitrate.mp4')
          ..initialize().then(
            (_) async {
              await _controller!.play();
              await _controller!.setLooping(true);
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
