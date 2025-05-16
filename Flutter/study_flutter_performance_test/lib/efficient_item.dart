import 'package:flutter/material.dart';

/// 效能優化的列表項組件
class EfficientListItem extends StatelessWidget {
  final String text;
  // 預先計算常用顏色
  static const List<Color> predefinedColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

  const EfficientListItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0, // 降低陰影複雜度
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // 簡化邊距
      child: Padding(
        padding: const EdgeInsets.all(8.0), // 減少填充空間
        child: Column(
          children: List.generate(5, (index) {
            // 使用預定義的顏色而不是每次重新計算
            final color = predefinedColors[index % predefinedColors.length];
            
            return Row(
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  radius: 16.0, // 減小尺寸
                  child: Text('$index'),
                ),
                const SizedBox(width: 8.0), // 減少間距
                Expanded(
                  child: Text(
                    '$text - $index',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
} 