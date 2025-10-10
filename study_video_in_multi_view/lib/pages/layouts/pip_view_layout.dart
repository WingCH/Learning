import 'package:flutter/material.dart';
import '../../managers/video_player_manager.dart';
import '../../widgets/common/view_title.dart';
import '../../widgets/video/video_player_widget_only.dart';
import '../../widgets/video/video_placeholder.dart';
import '../../widgets/video/video_info/video_info_display.dart';

/// PIP 視圖佈局 - Stack 佈局實現
class PipViewLayout extends StatefulWidget {
  final bool isViewA;
  final VideoPlayerManager videoManager;
  final VoidCallback onRetry;

  const PipViewLayout({
    super.key,
    required this.isViewA,
    required this.videoManager,
    required this.onRetry,
  });

  @override
  State<PipViewLayout> createState() => _PipViewLayoutState();
}

class _PipViewLayoutState extends State<PipViewLayout> {
  @override
  Widget build(BuildContext context) {
    // 主視圖固定為紅色
    final mainIsActive = widget.isViewA; // 主視圖是否有視頻

    return Stack(
      children: [
        // 主視圖（全屏背景 - 固定紅色）
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.red.shade300, // 固定紅色
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  ViewTitle(title: '紅色格', isActive: mainIsActive), // 固定標題
                  const SizedBox(height: 20),
                  // 根據狀態顯示視頻或佔位符（不包含信息框）
                  mainIsActive
                      ? VideoPlayerWidgetOnly(
                          videoManager: widget.videoManager,
                          onRetry: widget.onRetry,
                        )
                      : const VideoPlaceholder(),
                  const SizedBox(height: 120), // 為底部信息框預留空間
                ],
              ),
            ),
          ),
        ),
        
        // 固定在底部的視頻信息框
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: VideoInfoDisplay(videoManager: widget.videoManager),
        ),
      ],
    );
  }
}

