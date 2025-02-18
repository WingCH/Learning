import 'package:flutter/material.dart';
import 'package:native_video_player/native_video_player.dart';

class Case7Page extends StatefulWidget {
  const Case7Page({super.key});

  @override
  State<Case7Page> createState() => _Case7PageState();
}

class _Case7PageState extends State<Case7Page> {
  NativeVideoPlayerController? _controller;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('native_video_player'),
          AspectRatio(
            aspectRatio: _controller?.videoInfo?.aspectRatio ?? 16 / 9,
            child: NativeVideoPlayerView(
              onViewReady: (controller) async {
                _controller = controller;
                final videoSource = await VideoSource.init(
                  // path: 'https://live5.hengbeixingtech.com/live/52423_nsd.m3u8',
                  // path: 'assets/home_video.mp4',
                  // type: VideoSourceType.asset,
                  path: 'https://file-examples.com/storage/fea8fc38fd63bc5c39cf20b/2017/04/file_example_MP4_480_1_5MG.mp4',
                  type: VideoSourceType.network,
                );
                await _controller?.loadVideoSource(videoSource);
                setState(() {});
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller?.play();
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
