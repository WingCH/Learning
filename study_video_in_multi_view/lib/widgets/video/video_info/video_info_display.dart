import 'package:flutter/material.dart';
import '../../../managers/video_player_manager.dart';
import 'video_info_content.dart';

/// 視頻信息顯示 - 固定在底部的信息框
class VideoInfoDisplay extends StatelessWidget {
  final VideoPlayerManager videoManager;

  const VideoInfoDisplay({
    super.key,
    required this.videoManager,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (videoManager.errorMessage != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '錯誤: ${videoManager.errorMessage}',
              style: const TextStyle(color: Colors.red, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    if (!videoManager.isInitialized) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
          SizedBox(width: 12),
          Text(
            '正在載入視頻...',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      );
    }

    final controller = videoManager.controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return VideoInfoContent(
      position: controller.value.position,
      duration: controller.value.duration,
      isPlaying: controller.value.isPlaying,
      isBuffering: controller.value.isBuffering,
    );
  }
}

