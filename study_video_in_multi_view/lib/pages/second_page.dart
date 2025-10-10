import 'package:flutter/material.dart';
import '../controllers/global_pip_controller.dart';
import '../widgets/video/video_info/video_info_display.dart';

/// 第二頁面 - 展示 PIP 跨頁面顯示
class SecondPage extends StatelessWidget {
  final GlobalPipController pipController;

  const SecondPage({
    super.key,
    required this.pipController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade300,
        title: const Text('第二頁'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.purple.shade100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.video_library,
                size: 100,
                color: Colors.purple,
              ),
              const SizedBox(height: 30),
              const Text(
                '這是第二頁',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'PIP 窗口仍然顯示在最上層！',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('返回主頁面'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: pipController,
                builder: (context, _) {
                  return ElevatedButton.icon(
                    onPressed: pipController.switchView,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('切換視頻位置'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      // 底部信息框
      bottomSheet: pipController.videoManager != null
          ? VideoInfoDisplay(videoManager: pipController.videoManager!)
          : null,
    );
  }
}

