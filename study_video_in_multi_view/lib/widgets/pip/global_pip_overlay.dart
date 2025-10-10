import 'package:flutter/material.dart';
import '../../controllers/global_pip_controller.dart';
import 'pip_floating_window.dart';

/// 全局 PIP Overlay - 顯示在整個 app 最上層
class GlobalPipOverlay extends StatelessWidget {
  final GlobalPipController pipController;
  final Widget child;

  const GlobalPipOverlay({
    super.key,
    required this.pipController,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          child,
          // 全局 PIP 窗口（固定綠色背景）
          AnimatedBuilder(
            animation: pipController,
            builder: (context, _) {
              if (!pipController.isPipVisible || 
                  pipController.videoManager == null) {
                return const SizedBox.shrink();
              }
      
              final screenSize = MediaQuery.of(context).size;
              // PIP 窗口固定為綠色，不隨視頻位置改變
              final pipIsActive = !pipController.isViewA; // 視頻是否在 PIP 窗口
      
              return Positioned(
                left: pipController.pipPosition.dx,
                top: pipController.pipPosition.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    final newPosition = Offset(
                      (pipController.pipPosition.dx + details.delta.dx)
                          .clamp(0.0, screenSize.width - 200),
                      (pipController.pipPosition.dy + details.delta.dy)
                          .clamp(0.0, screenSize.height - 200),
                    );
                    pipController.updatePipPosition(newPosition);
                  },
                  child: PipFloatingWindow(
                    color: Colors.green.shade300, // 固定綠色
                    title: '綠色格', // 固定標題
                    isActive: pipIsActive,
                    videoManager: pipController.videoManager!,
                    onRetry: () {},
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

