import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Level 2: 圓形佈局 (Circular Layout)
///
/// 這個範例展示了 CustomMultiChildLayout 的進階用途：
/// 父組件控制整體的幾何形狀，並根據數學公式 (Sin/Cos) 來決定每個子組件的位置。
///
/// 場景：我們有一組圖標，想要將它們排列成一個圓形選單。

class Level2CircleExample extends StatefulWidget {
  const Level2CircleExample({super.key});

  @override
  State<Level2CircleExample> createState() => _Level2CircleExampleState();
}

class _Level2CircleExampleState extends State<Level2CircleExample> {
  // 控制項目的數量
  int _itemCount = 6;

  // 控制圓形的半徑 (相對於可用寬度的一半的比例)
  double _radiusPercent = 0.7;

  // 控制旋轉偏移量 (弧度)
  double _rotationOffset = 0.0;
  // 記錄手勢開始時的基礎偏移量
  double _baseRotationOffset = 0.0;
  // 記錄手勢開始時的手指角度
  double _startGestureAngle = 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("項目數量: $_itemCount"),
              Slider(
                value: _itemCount.toDouble(),
                min: 3,
                max: 12,
                divisions: 9,
                label: "$_itemCount",
                onChanged: (v) => setState(() => _itemCount = v.toInt()),
              ),
              const SizedBox(height: 10),
              Text("圓形半徑: ${(_radiusPercent * 100).toStringAsFixed(0)}%"),
              Slider(
                value: _radiusPercent,
                min: 0.3,
                max: 0.9,
                onChanged: (v) =>
                    setState(() => _radiusPercent = v.clamp(0.3, 0.9)),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                // 監聽拖曳手勢來改變旋轉角度
                onPanStart: (details) {
                  // 計算圓心位置
                  final center = Offset(
                    constraints.maxWidth / 2,
                    constraints.maxHeight / 2,
                  );
                  // 計算手指相對於圓心的角度 (atan2)
                  final touchOffset = details.localPosition - center;
                  _startGestureAngle = touchOffset.direction;
                  // 記錄當前的旋轉偏移量
                  _baseRotationOffset = _rotationOffset;
                },
                onPanUpdate: (details) {
                  final center = Offset(
                    constraints.maxWidth / 2,
                    constraints.maxHeight / 2,
                  );
                  final touchOffset = details.localPosition - center;
                  final currentAngle = touchOffset.direction;

                  // 計算角度差值
                  // 這裡不需要處理跨越 PI 的問題，因為 direction 是 -PI 到 PI，
                  // 但相減後的差值在連續滑動中是正確的。
                  final deltaAngle = currentAngle - _startGestureAngle;

                  setState(() {
                    _rotationOffset = _baseRotationOffset + deltaAngle;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: _itemCount.toDouble()),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack, // 使用彈性曲線讓效果更生動
                    builder: (context, effectiveCount, child) {
                      return CustomMultiChildLayout(
                        delegate: CircleLayoutDelegate(
                          itemCount: _itemCount,
                          effectiveItemCount: effectiveCount,
                          radiusPercent: _radiusPercent,
                          rotationOffset: _rotationOffset,
                        ),
                        children: [
                          // 根據當前的數量動態產生子組件
                          for (int i = 0; i < _itemCount; i++)
                            LayoutId(
                              id: i, // 使用索引作為 ID，方便 Delegate 使用迴圈存取
                              child: CircleItem(index: i),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CircleItem extends StatelessWidget {
  final int index;
  const CircleItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    // 為了讓視覺更有趣，我們給每個項目不同的顏色
    final color = Colors.primaries[index % Colors.primaries.length];

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        "${index + 1}",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

class CircleLayoutDelegate extends MultiChildLayoutDelegate {
  final int itemCount;
  final double effectiveItemCount; // 用於動畫的有效數量
  final double radiusPercent;
  final double rotationOffset;

  CircleLayoutDelegate({
    required this.itemCount,
    required this.effectiveItemCount,
    required this.radiusPercent,
    required this.rotationOffset,
  });

  @override
  void performLayout(Size size) {
    // 計算圓心
    final Offset center = Offset(size.width / 2, size.height / 2);

    // 計算半徑: 取寬高較小值的一半，再乘上百分比
    final double radius =
        (math.min(size.width, size.height) / 2) * radiusPercent;

    for (int i = 0; i < itemCount; i++) {
      if (hasChild(i)) {
        // --- 第一步：測量 ---
        // 我們給子組件鬆散的限制，但其實這範例中子組件是固定大小 (50x50)
        final Size childSize = layoutChild(i, BoxConstraints.loose(size));

        // --- 第二步：計算位置 ---
        // 角度 = (2 * pi / 數量) * 索引
        // 這裡使用 effectiveItemCount 來計算每一步的角度，實現平滑過渡
        final double angleStep = 2 * math.pi / effectiveItemCount;

        // 加入 -pi/2 是為了讓第一個項目從 "正上方" 開始，而不是右邊
        // 加入 rotationOffset 實現旋轉
        final double angle = angleStep * i - (math.pi / 2) + rotationOffset;

        // 圓參數式:
        // x = r * cos(theta)
        // y = r * sin(theta)
        final double x = center.dx + radius * math.cos(angle);
        final double y = center.dy + radius * math.sin(angle);

        // positionChild 設定的是子組件的 "左上角" 位置。
        // 為了讓子組件的 "中心點" 對齊圓周，我們需要減去子組件寬高的一半。
        final Offset topLeftPosition = Offset(
          x - childSize.width / 2,
          y - childSize.height / 2,
        );

        positionChild(i, topLeftPosition);
      }
    }
  }

  @override
  bool shouldRelayout(covariant CircleLayoutDelegate oldDelegate) {
    // 當數量、半徑或旋轉角度改變時，我們需要重新佈局
    return oldDelegate.itemCount != itemCount ||
        oldDelegate.effectiveItemCount != effectiveItemCount ||
        oldDelegate.radiusPercent != radiusPercent ||
        oldDelegate.rotationOffset != rotationOffset;
  }
}
