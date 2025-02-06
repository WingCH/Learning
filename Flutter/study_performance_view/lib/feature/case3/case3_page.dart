import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class Case3Page extends StatefulWidget {
  const Case3Page({super.key});

  @override
  State<Case3Page> createState() => _Case3PageState();
}

class _Case3PageState extends State<Case3Page> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
        Uri.parse('https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'))
      ..initialize().then((_) async {
        await _controller.play();
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Container(),
            TextButton(
              onPressed: () async {
                _controller.pause();
                context.go('/case3/sub?withLottie=false');
              },
              child: const Text('Sub Page without Lottie'),
            ),
            TextButton(
              onPressed: () async {
                _controller.pause();
                context.go('/case3/sub?withLottie=true');
              },
              child: const Text('Sub Page with Lottie'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
