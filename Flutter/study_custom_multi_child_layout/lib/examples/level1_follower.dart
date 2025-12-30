import 'package:flutter/material.dart';

/// Level 1: 基礎依賴佈局 (Dependent Layout)
///
/// 這個範例展示了 CustomMultiChildLayout 最常見的用途：
/// 一個子組件的位置 "依賴" 於另一個子組件的尺寸或位置。
///
/// 場景：我們想要一個 "Tooltip" (提示框) 永遠顯示在一個 "Target" (目標) 的正上方。
/// 無論 Target 的大小如何變化，Tooltip 都要保持水平置中，並貼在 Target 上方。

// 1. 定義 Layout ID
// 這些 ID 用來唯一標識每個子組件，讓我們在 Delegate 中可以區分它們。
enum Section {
  // target, // 下面的方塊 -> Replaced by Dynamic IDs ('target_0', 'target_1', ...)
  tooltip, // 上面的提示文字
}

class Level1FollowerExample extends StatefulWidget {
  const Level1FollowerExample({super.key});

  @override
  State<Level1FollowerExample> createState() => _Level1FollowerExampleState();
}

class _Level1FollowerExampleState extends State<Level1FollowerExample> {
  // 用來動態改變 Target 的大小，測試佈局是否會自動更新
  double _targetSize = 60.0; // Reduced default size for multiple targets
  // 動態改變 Tooltip 文字
  String _tooltipText = 'We are following you!';
  // NEW: 控制 Target 數量
  int _targetCount = 3;

  // 1. Tooltip Size: 將寬高合併為一個 Size 對象 passed, 唔使分開 pass.
  static const Size _tooltipSize = Size(120, 48);
  // 2. Spacing: Padding 都要 inject 埋入去，唔好 hard code.
  static const double _spacing = 10.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 控制面板
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text("Target Count / Size:"),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text("Count"),
                        Slider(
                          value: _targetCount.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: _targetCount.toString(),
                          onChanged: (v) =>
                              setState(() => _targetCount = v.toInt()),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text("Size"),
                        Slider(
                          value: _targetSize,
                          min: 30,
                          max: 100,
                          onChanged: (v) => setState(() => _targetSize = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(),
              // 新增文字輸入
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Tooltip Text',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) =>
                      setState(() => _tooltipText = v.isEmpty ? ' ' : v),
                  controller: TextEditingController(text: _tooltipText),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          // 因為 requirement 係 "其實全部都係要Shrink Wrap"，
          // 所以我們永遠使用 Center 來展示它如何 "剛好" 包住內容
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                color: Colors.grey.shade200,
                child: _buildLayout(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLayout() {
    return CustomMultiChildLayout(
      delegate: FollowerLayoutDelegate(
        targetSize: _targetSize,
        tooltipSize: _tooltipSize,
        spacing: _spacing,
        targetCount: _targetCount, // Pass count
      ),
      children: [
        // 動態產生多個 Target
        for (int i = 0; i < _targetCount; i++)
          LayoutId(
            id: 'target_$i', // Dynamic String ID
            child: Container(
              width: _targetSize,
              height: _targetSize,
              color: Colors.blue[(i + 1) * 100 % 900], // 不同顏色
              alignment: Alignment.center,
              child: Text(
                '${i + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),

        LayoutId(
          id: Section.tooltip,
          child: Container(
            width: _tooltipSize.width,
            height: _tooltipSize.height,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _tooltipText,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// 4. 實作 Delegate
class FollowerLayoutDelegate extends MultiChildLayoutDelegate {
  final double targetSize;
  final Size tooltipSize;
  final double spacing;
  final int targetCount; // New parameter

  FollowerLayoutDelegate({
    required this.targetSize,
    required this.tooltipSize,
    required this.spacing,
    required this.targetCount,
  });

  @override
  void performLayout(Size size) {
    // --- 第一步：佈局 Targets (Row Layout) ---

    // 計算 Targets 群組總寬度
    final double targetsGroupWidth =
        (targetCount * targetSize) + ((targetCount - 1) * spacing);

    // --- 第二步：佈局 Tooltip ---

    if (hasChild(Section.tooltip)) {
      layoutChild(Section.tooltip, BoxConstraints.tight(tooltipSize));
    }

    // --- 第三步：決定位置 ---

    // 整個 Layout 的總寬度
    final double maxLayoutWidth = targetsGroupWidth > tooltipSize.width
        ? targetsGroupWidth
        : tooltipSize.width;

    // 1. Position Tooltip (Top Centered)
    if (hasChild(Section.tooltip)) {
      final double tooltipX = (maxLayoutWidth - tooltipSize.width) / 2;
      final double tooltipY = 0;
      positionChild(Section.tooltip, Offset(tooltipX, tooltipY));
    }

    // 2. Position Targets (Bottom Centered Row)
    double startX = (maxLayoutWidth - targetsGroupWidth) / 2;
    double targetY = tooltipSize.height + spacing;

    for (int i = 0; i < targetCount; i++) {
      final String id = 'target_$i';
      if (hasChild(id)) {
        layoutChild(id, BoxConstraints.tight(Size(targetSize, targetSize)));
        positionChild(id, Offset(startX, targetY));
        startX += targetSize + spacing;
      }
    }
  }

  @override
  Size getSize(BoxConstraints constraints) {
    // 計算 Targets 群組總寬度
    final double targetsGroupWidth =
        (targetCount * targetSize) + ((targetCount - 1) * spacing);

    // 總高度
    final double totalHeight = tooltipSize.height + spacing + targetSize;

    // 總寬度
    final double totalWidth = targetsGroupWidth > tooltipSize.width
        ? targetsGroupWidth
        : tooltipSize.width;

    return Size(totalWidth, totalHeight);
  }

  @override
  bool shouldRelayout(covariant FollowerLayoutDelegate oldDelegate) {
    return oldDelegate.targetSize != targetSize ||
        oldDelegate.tooltipSize != tooltipSize ||
        oldDelegate.spacing != spacing ||
        oldDelegate.targetCount != targetCount;
  }
}
