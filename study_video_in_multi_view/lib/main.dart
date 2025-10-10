import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Multi-View Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VideoMultiViewPage(),
    );
  }
}

// ============================================================================
// 視頻管理器 - 封裝視頻控制器的生命週期管理
// ============================================================================
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

// ============================================================================
// 主頁面 - PIP 模式視圖
// ============================================================================
class VideoMultiViewPage extends StatefulWidget {
  const VideoMultiViewPage({super.key});

  @override
  State<VideoMultiViewPage> createState() => _VideoMultiViewPageState();
}

class _VideoMultiViewPageState extends State<VideoMultiViewPage> {
  late final VideoPlayerManager _videoManager;
  bool _isViewA = true; // true = View A (紅色), false = View B (綠色)

  @override
  void initState() {
    super.initState();
    _videoManager = VideoPlayerManager();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    await _videoManager.initialize(
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      () {
        if (mounted) setState(() {});
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoManager.dispose();
    super.dispose();
  }

  void _switchView() {
    setState(() {
      _isViewA = !_isViewA;
    });
  }

  void _togglePlayPause() {
    final controller = _videoManager.controller;
    if (controller != null) {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('PIP 模式 - 視頻在: ${_isViewA ? "紅色格" : "綠色格"}'),
      ),
      body: PipViewLayout(
        isViewA: _isViewA,
        videoManager: _videoManager,
        onRetry: _initializeVideo,
      ),
      floatingActionButton: VideoControlButtons(
        onSwitch: _switchView,
        onPlayPause: _togglePlayPause,
        isPlaying: _videoManager.controller?.value.isPlaying ?? false,
      ),
    );
  }
}


// ============================================================================
// 視圖標題 - 純函數組件
// ============================================================================
class ViewTitle extends StatelessWidget {
  final String title;
  final bool isActive;

  const ViewTitle({
    super.key,
    required this.title,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (isActive) ...[
          const SizedBox(width: 10),
          const Icon(
            Icons.play_circle_filled,
            color: Colors.white,
            size: 32,
          ),
        ],
      ],
    );
  }
}

// ============================================================================
// 視頻播放器組件（僅播放器，不含信息框）- 依賴注入 VideoPlayerManager
// ============================================================================
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

// ============================================================================
// 視頻錯誤視圖 - 純組件
// ============================================================================
class VideoErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const VideoErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('重試'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 視頻載入視圖 - 純組件
// ============================================================================
class VideoLoadingView extends StatelessWidget {
  const VideoLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '載入中...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 視頻佔位符 - 純組件
// ============================================================================
class VideoPlaceholder extends StatelessWidget {
  const VideoPlaceholder({super.key});

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
          color: Colors.black26,
        ),
        child: const AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam_off,
                  color: Colors.white54,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  '視頻在另一個格子播放',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 視頻信息顯示 - 固定在底部的信息框
// ============================================================================
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

// ============================================================================
// 視頻信息內容 - 純組件（緊湊橫向佈局）
// ============================================================================
class VideoInfoContent extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isBuffering;

  const VideoInfoContent({
    super.key,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isBuffering,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 時間信息
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time, color: Colors.white70, size: 16),
            const SizedBox(width: 8),
            Text(
              '${formatDuration(position)} / ${formatDuration(duration)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 狀態信息
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPlaying ? Icons.play_circle_filled : Icons.pause_circle_filled,
              color: isPlaying ? Colors.green : Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              isPlaying ? '播放中' : '已暫停',
              style: TextStyle(
                color: isPlaying ? Colors.green : Colors.orange,
                fontSize: 14,
              ),
            ),
            if (isBuffering) ...[
              const SizedBox(width: 16),
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Buffering...',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// PIP 視圖佈局 - Stack 佈局實現
// ============================================================================
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
  Offset _pipPosition = const Offset(20, 100); // PIP 窗口初始位置

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // 確定哪個是主視圖，哪個是 PIP
    // isViewA = true 表示視頻在紅色格（View A）
    final mainColor = widget.isViewA ? Colors.red.shade300 : Colors.green.shade300;
    final mainTitle = widget.isViewA ? '紅色格' : '綠色格';
    final mainIsActive = widget.isViewA; // 主視圖是否有視頻
    
    final pipColor = widget.isViewA ? Colors.green.shade300 : Colors.red.shade300;
    final pipTitle = widget.isViewA ? '綠色格' : '紅色格';
    final pipIsActive = !widget.isViewA; // PIP 視圖是否有視頻

    return Stack(
      children: [
        // 主視圖（全屏背景）
        Container(
          width: double.infinity,
          height: double.infinity,
          color: mainColor,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  ViewTitle(title: mainTitle, isActive: mainIsActive),
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
        
        // PIP 浮動窗口（可拖動）
        Positioned(
          left: _pipPosition.dx,
          top: _pipPosition.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _pipPosition = Offset(
                  (_pipPosition.dx + details.delta.dx).clamp(0.0, screenSize.width - 200),
                  (_pipPosition.dy + details.delta.dy).clamp(0.0, screenSize.height - 200),
                );
              });
            },
            child: PipFloatingWindow(
              color: pipColor,
              title: pipTitle,
              isActive: pipIsActive,
              videoManager: widget.videoManager,
              onRetry: widget.onRetry,
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

// ============================================================================
// PIP 浮動窗口組件
// ============================================================================
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
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: const BorderRadius.only(
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

// ============================================================================
// 視頻控制按鈕 - 純組件
// ============================================================================
class VideoControlButtons extends StatelessWidget {
  final VoidCallback onSwitch;
  final VoidCallback onPlayPause;
  final bool isPlaying;

  const VideoControlButtons({
    super.key,
    required this.onSwitch,
    required this.onPlayPause,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'switch',
          onPressed: onSwitch,
          tooltip: '切換播放格子',
          child: const Icon(Icons.swap_horiz),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: 'playPause',
          onPressed: onPlayPause,
          tooltip: '播放/暫停',
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 純函數 - 時間格式化
// ============================================================================
String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return '$minutes:$seconds';
}
