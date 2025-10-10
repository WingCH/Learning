import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../managers/video_player_manager.dart';

/// PIP 浮動窗口組件
class PipFloatingWindow extends StatelessWidget {
  final Color color;
  final String title;
  final bool isActive;
  final VideoPlayerManager videoManager;
  final VoidCallback onRetry;

  const PipFloatingWindow({
    super.key,
    required this.color,
    required this.title,
    required this.isActive,
    required this.videoManager,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.white, width: 3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 標題欄
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: const BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(9),
                topRight: Radius.circular(9),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.picture_in_picture_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
          // 視頻內容區域
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isActive
                ? _buildPipVideoPlayer()
                : _buildPipPlaceholder(),
          ),
        ],
      ),
    );
  }

  // PIP 視頻播放器
  Widget _buildPipVideoPlayer() {
    if (videoManager.errorMessage != null) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 24),
              SizedBox(height: 4),
              Text(
                '載入錯誤',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
      );
    }

    if (!videoManager.isInitialized) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(height: 8),
              Text(
                '載入中...',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
      );
    }

    final controller = videoManager.controller;
    if (controller != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    }

    return _buildPipPlaceholder();
  }

  // PIP 佔位符
  Widget _buildPipPlaceholder() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white38, width: 1),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              color: Colors.white54,
              size: 32,
            ),
            SizedBox(height: 4),
            Text(
              '主視圖播放中',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

