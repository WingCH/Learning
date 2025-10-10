import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 視頻管理器 - 封裝視頻控制器的生命週期管理
class VideoPlayerManager {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  VideoPlayerController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  Future<void> initialize(String videoUrl, VoidCallback onStateChanged) async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      // 添加監聽器來更新UI
      _controller!.addListener(() {
        if (_controller!.value.hasError) {
          _errorMessage = _controller!.value.errorDescription ?? '播放錯誤';
          debugPrint('Video Error: ${_controller!.value.errorDescription}');
        }
        onStateChanged();
      });

      await _controller!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('視頻加載超時，請檢查網絡連接'),
      );

      _isInitialized = true;
      _errorMessage = null;
      _controller!.play();
      _controller!.setLooping(true);
    } catch (e) {
      debugPrint('Initialize Error: $e');
      _errorMessage = '視頻加載失敗: $e';
      _isInitialized = false;
    }
  }

  void dispose() {
    _controller?.dispose();
  }
}

