import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../managers/video_player_manager.dart';
import 'video_error_view.dart';
import 'video_loading_view.dart';

/// 視頻播放器組件（僅播放器，不含信息框）- 依賴注入 VideoPlayerManager
class VideoPlayerWidgetOnly extends StatelessWidget {
  final VideoPlayerManager videoManager;
  final VoidCallback onRetry;

  const VideoPlayerWidgetOnly({
    super.key,
    required this.videoManager,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 400,
        maxHeight: 250,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (videoManager.errorMessage != null) {
      return VideoErrorView(
        errorMessage: videoManager.errorMessage!,
        onRetry: onRetry,
      );
    }

    if (!videoManager.isInitialized) {
      return const VideoLoadingView();
    }

    final controller = videoManager.controller;
    if (controller != null) {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      );
    }

    return const VideoLoadingView();
  }
}

