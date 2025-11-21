// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is used to extract code samples for the README.md file.
// Run update-excerpts if you modify this file.

// ignore_for_file: library_private_types_in_public_api, public_member_api_docs

// #docregion basic-example
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const VideoApp());

/// Stateful widget to fetch and then display video content.
class VideoApp extends StatefulWidget {
  const VideoApp({super.key});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  int _currentVideoIndex = 0;
  final List<String> _videoPaths = ['assets/ios_fixed_video.mp4'];
  final List<String> _videoNames = ['ios_fixed_video'];

  @override
  void initState() {
    super.initState();
    _initializeVideo(_currentVideoIndex);
  }

  void _initializeVideo(int index) {
    _controller =
        VideoPlayerController.asset(_videoPaths[index])
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          })
          ..addListener(() {
            // Update UI when video state changes
            if (mounted) {
              setState(() {});
            }
            if (_controller.value.hasError) {
              print('VideoPlayer error: ${_controller.value.errorDescription}');
            }
          });
  }

  void _switchVideo() {
    final bool wasPlaying = _controller.value.isPlaying;
    _controller.dispose();

    setState(() {
      _currentVideoIndex = (_currentVideoIndex + 1) % _videoPaths.length;
    });

    _initializeVideo(_currentVideoIndex);

    if (wasPlaying) {
      _controller.initialize().then((_) {
        _controller.play();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Video Player Demo'),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child:
              _controller.value.isInitialized
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // 顯示當前影片名稱
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(Icons.video_library, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              '當前影片: ${_videoNames[_currentVideoIndex]}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      const SizedBox(height: 20),
                      _buildVideoInfo(),
                      const SizedBox(height: 20),
                      // 切換影片按鈕
                      ElevatedButton.icon(
                        onPressed: _switchVideo,
                        icon: const Icon(Icons.swap_horiz),
                        label: const Text('切換影片'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  )
                  : const CircularProgressIndicator(),
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
      ),
    );
  }

  Widget _buildVideoInfo() {
    final Duration duration = _controller.value.duration;
    final Duration position = _controller.value.position;
    final Size size = _controller.value.size;
    final bool isPlaying = _controller.value.isPlaying;
    final bool isBuffering = _controller.value.isBuffering;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '影片資訊',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('時長', _formatDuration(duration)),
          _buildInfoRow('當前位置', _formatDuration(position)),
          _buildInfoRow(
            '影片尺寸',
            '${size.width.toInt()} x ${size.height.toInt()}',
          ),
          _buildInfoRow(
            '寬高比',
            _controller.value.aspectRatio.toStringAsFixed(2),
          ),
          _buildInfoRow('播放狀態', isPlaying ? '播放中' : '已暫停'),
          _buildInfoRow('緩衝狀態', isBuffering ? '緩衝中...' : '正常'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    return duration.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// #enddocregion basic-example
