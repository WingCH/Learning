import 'package:flutter/material.dart';

/// Level 3: 錦標賽對陣圖 (Tournament Bracket)
///
/// 需求：
/// 1. 僅限左右滑動 (Horizontal Scrolling)。
/// 2. 生長方向：由左至右 (16強 -> 8強 -> ... -> 決賽)。
/// 3. 卡片大小固定。
/// 4. 高度隨層級縮小 (因為層級越高，節點越少)。
/// 5. 連線使用 S 型貝茲曲線 (Bezier Curves)。

// 定義一個簡單的比賽節點數據結構
class MatchNode {
  final String id;
  final int round; // 0: 16強, 1: 8強 ...
  final int indexInRound;
  final String label;

  MatchNode({
    required this.id,
    required this.round,
    required this.indexInRound,
    required this.label,
  });
}

class Level3TournamentExample extends StatefulWidget {
  const Level3TournamentExample({super.key});

  @override
  State<Level3TournamentExample> createState() =>
      _Level3TournamentExampleState();
}

class _Level3TournamentExampleState extends State<Level3TournamentExample> {
  // 模擬數據
  late List<MatchNode> _nodes;
  final int _totalRounds = 5; // 16 -> 8 -> 4 -> 2 -> 1 (5 rounds)

  // 配置參數
  final double _cardWidth = 120;
  final double _cardHeight = 60;
  final double _horizontalGap = 60;
  final double _verticalGap = 20; // 第一輪卡片之間的間距

  @override
  void initState() {
    super.initState();
    _nodes = _generateNodes();
  }

  List<MatchNode> _generateNodes() {
    List<MatchNode> nodes = [];
    int matchesInRound = 16;
    for (int r = 0; r < _totalRounds; r++) {
      for (int i = 0; i < matchesInRound; i++) {
        String roundName;
        if (matchesInRound == 16) {
          roundName = "16強";
        } else if (matchesInRound == 8) {
          roundName = "8強";
        } else if (matchesInRound == 4) {
          roundName = "4強";
        } else if (matchesInRound == 2) {
          roundName = "準決賽";
        } else {
          roundName = "決賽";
        }

        nodes.add(
          MatchNode(
            id: "$r-$i",
            round: r,
            indexInRound: i,
            label: "$roundName ${i + 1}",
          ),
        );
      }
      matchesInRound ~/= 2;
    }
    return nodes;
  }

  @override
  Widget build(BuildContext context) {
    // 計算 Layout 需要的總寬度和高度
    // 總寬度 = (卡片寬 + 間距) * 輪數 (最後一輪不需要間距，但這裡簡單算)
    double totalWidth =
        _totalRounds * _cardWidth + (_totalRounds - 1) * _horizontalGap;

    // 第一輪高度最高，決定了整體的滾動高度
    // 第一輪有無 16 個節點
    int firstRoundCount = 16;
    double totalHeight =
        firstRoundCount * _cardHeight + (firstRoundCount + 1) * _verticalGap;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: _SnappingScrollPhysics(itemWidth: _cardWidth + _horizontalGap),
      child: SingleChildScrollView(
        scrollDirection:
            Axis.vertical, // 雖然需求說僅限左右，但為了能看到垂直方向的內容，通常還是需要垂直滾動，或者確保父層有足夠高度
        // 根據 "16強會很高度會很長... 這個view 的高度會隨著層級而縮小" 的描述
        // 可能意味着右邊區域其實是對齊中間的，整體高度由最左邊決定。
        // 如果外層限制了高度，這裡可能只需要水平滾動。
        // 不過為了保險，先讓內容能完整顯示。
        child: Container(
          // 這裡給一個足夠大的容器，或者由 CustomMultiChildLayout 自己決定大小 (如果 Delegate 實現了 getSize)
          // 為了 ScrollView 能工作，我們最好明確指定大小，或讓 Layout 計算出大小。
          width: totalWidth + 100, // 多加點 padding
          height: totalHeight + 100,
          padding: const EdgeInsets.all(20),
          child: CustomMultiChildLayout(
            delegate: TournamentLayoutDelegate(
              nodes: _nodes,
              cardWidth: _cardWidth,
              cardHeight: _cardHeight,
              horizontalGap: _horizontalGap,
              verticalGap: _verticalGap,
            ),
            children: [
              // 繪製連線 (背景)
              LayoutId(
                id: 'lines',
                child: CustomPaint(
                  painter: TournamentLinesPainter(
                    nodes: _nodes,
                    cardWidth: _cardWidth,
                    cardHeight: _cardHeight,
                    horizontalGap: _horizontalGap,
                    verticalGap: _verticalGap,
                  ),
                ),
              ),
              // 繪製卡片 (前景)
              for (var node in _nodes)
                LayoutId(
                  id: node.id,
                  child: TournamentCard(
                    node: node,
                    width: _cardWidth,
                    height: _cardHeight,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SnappingScrollPhysics extends ScrollPhysics {
  final double itemWidth;

  const _SnappingScrollPhysics({required this.itemWidth, super.parent});

  @override
  _SnappingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SnappingScrollPhysics(
      itemWidth: itemWidth,
      parent: buildParent(ancestor),
    );
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // If we're out of range, defer to default parent physics
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final Tolerance tolerance = toleranceFor(position);
    // Calculate which item index we are closest to
    // The "pixels" is the scroll offset.
    // round(pixels / itemWidth) gives the nearest index.

    // We can use the velocity to "predict" where the user wants to go.
    // If velocity is high enough, we jump to next/prev page.

    double target = position.pixels;
    if (velocity.abs() > tolerance.velocity) {
      // User flung the list
      target += velocity * 0.3; // Simple prediction
    }

    // Find the nearest snap point
    double page = target / itemWidth;
    int index = page.round();

    double destination = index * itemWidth;

    // Ensure we don't snap outside bounds (though clamp simulation handles this mostly)
    // but good to be explicit for the destination
    // (We rely on standard physics to handle overscroll bounds mostly, but the spring target should be valid)

    return ScrollSpringSimulation(
      spring,
      position.pixels,
      destination,
      velocity,
      tolerance: tolerance,
    );
  }
}

class TournamentCard extends StatelessWidget {
  final MatchNode node;
  final double width;
  final double height;

  const TournamentCard({
    super.key,
    required this.node,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            node.label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          const Text("vs", style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class TournamentLayoutDelegate extends MultiChildLayoutDelegate {
  final List<MatchNode> nodes;
  final double cardWidth;
  final double cardHeight;
  final double horizontalGap;
  final double verticalGap;

  // 用於緩存計算出的位置，供 Painter 使用 (如果需要)
  // 但因為 Painter 和 Layout 是分開的，Painter 通常自己重算一遍或者這裏傳入位置。
  // 在這個架構下，我們簡單地讓 Layout 計算位置並擺放。
  // 由於 Painter 也是 Child，我們需要傳遞大小給它。

  TournamentLayoutDelegate({
    required this.nodes,
    required this.cardWidth,
    required this.cardHeight,
    required this.horizontalGap,
    required this.verticalGap,
  });

  @override
  void performLayout(Size size) {
    // 1. 佈局 'lines' 背景層
    if (hasChild('lines')) {
      layoutChild('lines', BoxConstraints.tight(size));
      positionChild('lines', Offset.zero);
    }

    // 2. 計算並佈局所有節點
    // 這裡我們使用一個 Map 來存儲我們計算出的每個節點的 (x, y) 中心點或左上角
    // logic:
    // Round 0 (16 nodes): 直接根據 verticalGap 排列
    // Round N (N > 0): 每個節點 i 對應 Round N-1 的節點 2*i 和 2*i+1
    // y = (child1.y + child2.y) / 2

    // 為了方便查找上一輪的位置，我們按 round 分組
    Map<int, List<Offset>> positionsByRound = {};

    // 預先產生各輪的列表架構 (其實就是傳入的 nodes 已經包含 round 資訊)
    // 我們需要確保按順序計算：Round 0 -> Round 1 -> ...

    int maxRound = 0;
    for (var node in nodes) {
      if (node.round > maxRound) maxRound = node.round;
    }

    // 逐輪處理
    for (int r = 0; r <= maxRound; r++) {
      List<MatchNode> roundNodes = nodes.where((n) => n.round == r).toList();
      // 確保按 index 排序
      roundNodes.sort((a, b) => a.indexInRound.compareTo(b.indexInRound));

      List<Offset> currentRoundPositions = [];

      for (int i = 0; i < roundNodes.length; i++) {
        var node = roundNodes[i];
        double x = r * (cardWidth + horizontalGap);
        // 這裡加上 padding 讓整體不貼邊
        x += 20; // left padding

        double y;
        if (r == 0) {
          // 第一輪：簡單垂直排列
          y = verticalGap + i * (cardHeight + verticalGap);
        } else {
          // 後續輪次：基於上一輪的兩個來源節點居中
          // 來源節點索引：2*i 和 2*i+1
          var prevRoundPositions = positionsByRound[r - 1];
          if (prevRoundPositions != null &&
              prevRoundPositions.length > 2 * i + 1) {
            double y1 = prevRoundPositions[2 * i].dy;
            double y2 = prevRoundPositions[2 * i + 1].dy;
            y = (y1 + y2) / 2;
          } else {
            y = 0; // Should not happen given the structure
          }
        }

        Offset pos = Offset(x, y);
        currentRoundPositions.add(pos);

        // 實際佈局 Flutter Widget
        if (hasChild(node.id)) {
          layoutChild(
            node.id,
            BoxConstraints.tight(Size(cardWidth, cardHeight)),
          );
          positionChild(node.id, pos);
        }
      }
      positionsByRound[r] = currentRoundPositions;
    }
  }

  @override
  bool shouldRelayout(covariant TournamentLayoutDelegate oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.cardWidth != cardWidth ||
        oldDelegate.cardHeight != cardHeight;
  }
}

class TournamentLinesPainter extends CustomPainter {
  final List<MatchNode> nodes;
  final double cardWidth;
  final double cardHeight;
  final double horizontalGap;
  final double verticalGap;

  TournamentLinesPainter({
    required this.nodes,
    required this.cardWidth,
    required this.cardHeight,
    required this.horizontalGap,
    required this.verticalGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 我們需要重新計算位置，或者理想情況下 LayoutDelegate 應該傳遞位置給 Painter
    // 為了簡單且解耦，這裡重用相同的計算邏輯 (DRY 原則在生產環境可以提取到一個 Helper class)

    Map<int, List<Offset>> positionsByRound = {};
    int maxRound = 0;
    for (var node in nodes) {
      if (node.round > maxRound) maxRound = node.round;
    }

    for (int r = 0; r <= maxRound; r++) {
      List<MatchNode> roundNodes = nodes.where((n) => n.round == r).toList();
      roundNodes.sort((a, b) => a.indexInRound.compareTo(b.indexInRound));

      List<Offset> currentRoundPositions = [];

      for (int i = 0; i < roundNodes.length; i++) {
        double x = r * (cardWidth + horizontalGap) + 20;
        double y;
        if (r == 0) {
          y = verticalGap + i * (cardHeight + verticalGap);
        } else {
          var prevRoundPositions = positionsByRound[r - 1];
          if (prevRoundPositions != null &&
              prevRoundPositions.length > 2 * i + 1) {
            double y1 = prevRoundPositions[2 * i].dy;
            double y2 = prevRoundPositions[2 * i + 1].dy;
            y = (y1 + y2) / 2;

            // Draw lines from prev round to this node
            // Prev nodes: (2*i) and (2*i+1)
            // Lines: Prev Right Center -> Current Left Center

            Offset targetLeft = Offset(x, y + cardHeight / 2);
            Offset source1Right = Offset(
              prevRoundPositions[2 * i].dx + cardWidth,
              prevRoundPositions[2 * i].dy + cardHeight / 2,
            );
            Offset source2Right = Offset(
              prevRoundPositions[2 * i + 1].dx + cardWidth,
              prevRoundPositions[2 * i + 1].dy + cardHeight / 2,
            );

            drawBezierLine(canvas, paint, source1Right, targetLeft);
            drawBezierLine(canvas, paint, source2Right, targetLeft);
          } else {
            y = 0;
          }
        }
        currentRoundPositions.add(Offset(x, y));
      }
      positionsByRound[r] = currentRoundPositions;
    }
  }

  void drawBezierLine(Canvas canvas, Paint paint, Offset p1, Offset p2) {
    final path = Path();
    path.moveTo(p1.dx, p1.dy);

    // 控制點：x 軸取中點，保持水平切線
    double midX = (p1.dx + p2.dx) / 2;
    // 使用兩個控制點的三次貝茲曲線 (Cubic Bezier) 會比二次 (Quadratic) 更平滑，形成 S 型
    path.cubicTo(
      midX,
      p1.dy, // Control point 1: 水平延伸出 p1
      midX,
      p2.dy, // Control point 2: 水平延伸進 p2
      p2.dx,
      p2.dy,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TournamentLinesPainter oldDelegate) {
    return true; // 簡單起見，總是重畫
  }
}
