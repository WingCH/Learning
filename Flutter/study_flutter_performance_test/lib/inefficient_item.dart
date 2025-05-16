import 'package:flutter/material.dart';

/// 效能較差的列表項組件
class InefficientListItem extends StatelessWidget {
  final String text;

  const InefficientListItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // 使用複雜的佈局和不必要的計算來模擬效能問題
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(5, (index) {
            // 不必要的複雜計算
            int calculatedValue = 0;
            for (int i = 0; i < 10000; i++) {
              calculatedValue += i % (index + 1);
            }
            
            return Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color.fromRGBO(
                    (calculatedValue % 255),
                    (calculatedValue * 2) % 255,
                    (calculatedValue * 3) % 255,
                    1.0,
                  ),
                  radius: 20.0,
                  child: Text('$index'),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$text - $index',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('計算結果: $calculatedValue'),
                    ],
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