import 'package:flutter/material.dart';
import '../../../utils/formatters.dart';

/// 視頻信息內容 - 純組件（緊湊橫向佈局）
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

