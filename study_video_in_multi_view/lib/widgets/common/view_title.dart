import 'package:flutter/material.dart';

/// 視圖標題 - 純函數組件
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

