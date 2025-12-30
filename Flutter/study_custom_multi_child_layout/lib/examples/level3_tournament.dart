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

  // Scroll Controller to track position
  final ScrollController _scrollController = ScrollController();
  // Current "page" or "round" index based on scroll
  double _currentRoundIndex = 0.0;

  // 配置參數
  final double _cardWidth = 120;
  final double _cardHeight = 60;
  final double _horizontalGap = 60;
  final double _verticalGap = 20; // 第一輪卡片之間的間距

  @override
  void initState() {
    super.initState();
    _nodes = _generateNodes();
    // Listen to scroll changes
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 計算當前滾動位置對應的 "輪次索引" (Round Index)
    // 這裡的 itemWidth 是 "卡片寬度 + 水平間距"，代表一列的完整寬度。
    final itemWidth = _cardWidth + _horizontalGap;

    // offset / itemWidth 得到的是一個浮點數，例如 1.5 代表滾動到了 第1輪 和 第2輪 中間。
    double newRoundIndex = _scrollController.offset / itemWidth;

    // 限制範圍，確保索引不會小於 0 或大於 最大輪次。
    newRoundIndex = newRoundIndex.clamp(0.0, (_totalRounds - 1).toDouble());

    // 移除閾值檢查，確保狀態與滾動位置完全同步
    // 這解決了在整數邊界附近 (例如 0.999 vs 1.001) 因閾值導致狀態不更新，
    // 進而導致 floor() 計算錯誤，使得卡片可見性與實際滾動位置不符的問題。
    setState(() {
      _currentRoundIndex = newRoundIndex;
    });
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
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: _SnappingScrollPhysics(itemWidth: _cardWidth + _horizontalGap),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.red,
          child: CustomMultiChildLayout(
            delegate: TournamentLayoutDelegate(
              nodes: _nodes,
              cardWidth: _cardWidth,
              cardHeight: _cardHeight,
              horizontalGap: _horizontalGap,
              verticalGap: _verticalGap,
              focusRoundIndex: _currentRoundIndex,
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
                    focusRoundIndex: _currentRoundIndex,
                  ),
                ),
              ),
              // 繪製卡片 (前景)
              for (var node in _nodes)
                if (node.round >= _currentRoundIndex.floor()) // 優化：只構建可見的子節點
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
    // 如果滾動超出了邊界，使用默認的物理效果 (彈回)
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final Tolerance tolerance = toleranceFor(position);

    // 計算目標滾動位置
    // 我們希望滾動停止時，剛好停在某一列的起始位置 (Snap)

    double target = position.pixels;
    if (velocity.abs() > tolerance.velocity) {
      // 如果用戶有甩動 (Fling) 的動作，我們預測一個更遠的目標點
      target += velocity * 0.3;
    }

    // 計算最近的 "頁面" (Page/Round) 索引
    double page = target / itemWidth;
    int index = page.round();

    // 計算最終吸附的像素位置
    double destination = index * itemWidth;

    // 使用 ScrollSpringSimulation 來模擬彈簧吸附效果
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
  final double focusRoundIndex;

  TournamentLayoutDelegate({
    required this.nodes,
    required this.cardWidth,
    required this.cardHeight,
    required this.horizontalGap,
    required this.verticalGap,
    required this.focusRoundIndex,
  });

  @override
  Size getSize(BoxConstraints constraints) {
    // Calculate Grid Dimensions
    // Width is constant: All rounds + gaps
    int maxRound = 0;
    for (var node in nodes) {
      if (node.round > maxRound) maxRound = node.round;
    }
    double totalWidth = (maxRound + 1) * _getStepWidth() + 40; // + padding

    // 動態計算容器高度 (Dynamic Size)
    // 這是實現無縫縮放的關鍵。
    // 我們根據 focusRoundIndex (當前滾動位置) 來計算高度。

    // 例如：如果我們從 Round 0 (16強) 滾動到 Round 1 (8強)。
    // 16強的高度較高，8強的高度較矮。
    // 我們希望容器的高度能平滑地從 "16強高度" 過渡到 "8強高度"。

    // 向下取整，找到當前區間的左邊輪次 (floorRound)
    int floorRound = focusRoundIndex.floor();
    // 向上取整，找到當前區間的右邊輪次 (ceilRound)
    int ceilRound = focusRoundIndex.ceil();
    // 計算插值進度 t (0.0 ~ 1.0)
    double t = focusRoundIndex - floorRound;

    // 分別計算兩個輪次所需的理論高度
    double h1 = _calculateHeightForRound(floorRound);
    double h2 = _calculateHeightForRound(ceilRound);

    // 線性插值 (Lerp)：根據進度 t 在 h1 和 h2 之間過渡
    double currentHeight = h1 + (h2 - h1) * t;

    // 確保高度至少能顯示一張卡片
    currentHeight = currentHeight < cardHeight
        ? cardHeight + verticalGap
        : currentHeight;

    return Size(totalWidth, currentHeight);
  }

  double _getStepWidth() => cardWidth + horizontalGap;

  double _calculateHeightForRound(int round) {
    // Find how many nodes in this round
    // Since nodes list is flat, we count.
    // Or we can calculate theoretically if we know it's a perfect tournament.
    // Let's count to be safe/generic.
    int count = nodes.where((n) => n.round == round).length;
    if (count == 0) return 0; // Should not happen for valid rounds
    return count * cardHeight + (count + 1) * verticalGap;
  }

  @override
  void performLayout(Size size) {
    if (hasChild('lines')) {
      layoutChild('lines', BoxConstraints.tight(size));
      positionChild('lines', Offset.zero);
    }

    Map<int, List<Offset>> positionsByRound = {};

    // Determine the "Anchor Round"
    // We round to nearest integer to get the round that should be "normal spaced"
    int anchorRound = focusRoundIndex.round();

    // Find max round
    int maxRound = 0;
    for (var node in nodes) {
      if (node.round > maxRound) maxRound = node.round;
    }

    // 步驟 1: 佈局 Anchor Round (基準輪次)
    // ------------------------------------------------
    // "Anchor Round" 是當前視覺上的焦點輪次 (例如 Scroll 到 8強時，8強就是 Anchor)。
    // 這一輪的節點使用 "標準間距 (verticalGap)" 進行排列。
    // 這決定了當前畫面上看到的最緊湊的間距。
    List<MatchNode> anchorNodes = nodes
        .where((n) => n.round == anchorRound)
        .toList();
    anchorNodes.sort((a, b) => a.indexInRound.compareTo(b.indexInRound));
    List<Offset> anchorPositions = [];

    // 從頂部開始排列，加上一些垂直間距
    double startY = verticalGap;

    for (int i = 0; i < anchorNodes.length; i++) {
      double x = anchorRound * (cardWidth + horizontalGap) + 20;
      double y = startY + i * (cardHeight + verticalGap);
      anchorPositions.add(Offset(x, y));
    }
    positionsByRound[anchorRound] = anchorPositions;

    // 步驟 2: 向前佈局 (Forward Layout)
    // 處理比 AnchorRound 大的輪次 (例如從 8強 推算 4強 的位置)。
    // ------------------------------------------------
    // 邏輯: "居中對齊" (Center on Previous Round)
    // 每一場比賽的兩個勝者會晉級到下一輪，所以下一輪的節點應該位於上一輪兩個節點的中間。
    for (int r = anchorRound + 1; r <= maxRound; r++) {
      List<MatchNode> roundNodes = nodes.where((n) => n.round == r).toList();
      roundNodes.sort((a, b) => a.indexInRound.compareTo(b.indexInRound));
      List<Offset> currentPositions = [];

      var prevPositions = positionsByRound[r - 1];

      for (int i = 0; i < roundNodes.length; i++) {
        double x = r * (cardWidth + horizontalGap) + 20;
        double y = 0;

        // 如果上一輪有足夠的節點 (2*i 和 2*i+1)，我們就取它們 Y 坐標的平均值
        if (prevPositions != null && prevPositions.length > 2 * i + 1) {
          double y1 = prevPositions[2 * i].dy;
          double y2 = prevPositions[2 * i + 1].dy;
          y = (y1 + y2) / 2;
        }
        currentPositions.add(Offset(x, y));
      }
      positionsByRound[r] = currentPositions;
    }

    // 步驟 3: 向後佈局 (Backward Layout)
    // 處理比 AnchorRound 小的輪次 (例如從 8強 往回推算 16強 的位置)。
    // ------------------------------------------------
    // 邏輯: "反向發散" (Reverse Centering / Fanning Out)
    // 當我們聚焦在後面輪次時，前面的輪次已經移出畫面，但它們的相對位置應該取決於 當前可見的輪次。
    // 這其實是 Step 2 的反向操作：
    // 父節點 (Round r) 的位置，是由 子節點 (Round r+1) 的位置 "反推" 出來的。

    // 優化：只處理可見範圍內的輪次
    // 如果當前聚焦在 Round 1 (8強)，就不需要繪製 Round 0 (16強)
    int minVisibleRound = focusRoundIndex.floor();

    for (int r = anchorRound - 1; r >= minVisibleRound; r--) {
      List<MatchNode> roundNodes = nodes.where((n) => n.round == r).toList();
      roundNodes.sort((a, b) => a.indexInRound.compareTo(b.indexInRound));
      // 初始化位置列表
      List<Offset> currentPositions = List.filled(
        roundNodes.length,
        Offset.zero,
      );

      // 我們需要參考 "下一輪" (r+1) 的位置，因為它是我們的佈局基準
      var nextPositions = positionsByRound[r + 1];

      // 每個 (r+1) 的節點，都是由 (r) 的兩個節點晉級而來的。
      // 所以 Node J (在 r+1 輪) 連接著 Node 2*J 和 Node 2*J+1 (在 r 輪)。
      if (nextPositions != null) {
        for (int j = 0; j < nextPositions.length; j++) {
          Offset childPos = nextPositions[j];

          double x = r * (cardWidth + horizontalGap) + 20;

          // 我們需要計算兩個"父節點" (Parent) 的 Y 坐標
          // 為了對稱，我們讓這兩個父節點相對於子節點上下對稱分佈。
          // 偏移量 = (卡片高度 + 垂直間距) / 2

          // Parent 1 (上方)
          if (2 * j < roundNodes.length) {
            double y1 = childPos.dy - (cardHeight + verticalGap) / 2;
            currentPositions[2 * j] = Offset(x, y1);
          }
          // Parent 2 (下方)
          if (2 * j + 1 < roundNodes.length) {
            double y2 = childPos.dy + (cardHeight + verticalGap) / 2;
            currentPositions[2 * j + 1] = Offset(x, y2);
          }
        }
      }
      positionsByRound[r] = currentPositions;
    }

    // Apply positions to children
    for (var node in nodes) {
      // 優化：如果該輪次小於最小可見輪次，則不進行佈局 (不顯示)
      if (node.round < minVisibleRound) continue;

      if (hasChild(node.id) && positionsByRound[node.round] != null) {
        // Use indexInRound to find safe position
        List<Offset> roundPos = positionsByRound[node.round]!;
        if (node.indexInRound < roundPos.length) {
          Offset pos = roundPos[node.indexInRound];
          layoutChild(
            node.id,
            BoxConstraints.tight(Size(cardWidth, cardHeight)),
          );
          positionChild(node.id, pos);
        }
      }
    }
  }

  @override
  bool shouldRelayout(covariant TournamentLayoutDelegate oldDelegate) {
    return oldDelegate.focusRoundIndex != focusRoundIndex ||
        oldDelegate.nodes != nodes;
  }
}

class TournamentLinesPainter extends CustomPainter {
  final List<MatchNode> nodes;
  final double cardWidth;
  final double cardHeight;
  final double horizontalGap;
  final double verticalGap;
  final double focusRoundIndex;

  TournamentLinesPainter({
    required this.nodes,
    required this.cardWidth,
    required this.cardHeight,
    required this.horizontalGap,
    required this.verticalGap,
    required this.focusRoundIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Reuse Logic (Simplified copy of LayoutDelegate logic)
    // In production, this logic should be shared.

    Map<int, List<Offset>> positionsByRound = {};
    int anchorRound = focusRoundIndex.round();
    int maxRound = 0;
    for (var node in nodes) {
      if (node.round > maxRound) maxRound = node.round;
    }

    // Step 1: Anchor
    List<MatchNode> anchorNodes = nodes
        .where((n) => n.round == anchorRound)
        .toList();
    anchorNodes.sort((a, b) => a.indexInRound.compareTo(b.indexInRound));
    List<Offset> anchorPositions = [];
    double startY = verticalGap;
    for (int i = 0; i < anchorNodes.length; i++) {
      double x = anchorRound * (cardWidth + horizontalGap) + 20;
      double y = startY + i * (cardHeight + verticalGap);
      anchorPositions.add(Offset(x, y));
    }
    positionsByRound[anchorRound] = anchorPositions;

    // Step 2: Forward
    for (int r = anchorRound + 1; r <= maxRound; r++) {
      List<MatchNode> roundNodes = nodes.where((n) => n.round == r).toList();
      roundNodes.sort((a, b) => a.indexInRound.compareTo(b.indexInRound));
      List<Offset> currentPositions = [];
      var prevPositions = positionsByRound[r - 1];
      for (int i = 0; i < roundNodes.length; i++) {
        double x = r * (cardWidth + horizontalGap) + 20;
        double y = 0;
        if (prevPositions != null && prevPositions.length > 2 * i + 1) {
          double y1 = prevPositions[2 * i].dy;
          double y2 = prevPositions[2 * i + 1].dy;
          y = (y1 + y2) / 2;

          // Draw lines (Logic is same: Prev -> Current)
          Offset targetLeft = Offset(x, y + cardHeight / 2);
          Offset source1Right = Offset(
            prevPositions[2 * i].dx + cardWidth,
            y1 + cardHeight / 2,
          );
          Offset source2Right = Offset(
            prevPositions[2 * i + 1].dx + cardWidth,
            y2 + cardHeight / 2,
          );
          drawBezierLine(canvas, paint, source1Right, targetLeft);
          drawBezierLine(canvas, paint, source2Right, targetLeft);
        }
        currentPositions.add(Offset(x, y));
      }
      positionsByRound[r] = currentPositions;
    }

    // Step 3: Backward
    // 優化：只繪製可見範圍內的連線
    int minVisibleRound = focusRoundIndex.floor();

    for (int r = anchorRound - 1; r >= minVisibleRound; r--) {
      List<MatchNode> roundNodes = nodes.where((n) => n.round == r).toList();
      roundNodes.sort((a, b) => a.indexInRound.compareTo(b.indexInRound));
      List<Offset> currentPositions = List.filled(
        roundNodes.length,
        Offset.zero,
      );
      var nextPositions = positionsByRound[r + 1];
      if (nextPositions != null) {
        for (int j = 0; j < nextPositions.length; j++) {
          Offset childPos = nextPositions[j];

          double x = r * (cardWidth + horizontalGap) + 20;

          // 我們需要計算兩個"父節點" (Parent) 的 Y 坐標
          // 為了對稱，我們讓這兩個父節點相對於子節點上下對稱分佈。
          // 偏移量 = (卡片高度 + 垂直間距) / 2

          // Parent 1 (上方)
          if (2 * j < roundNodes.length) {
            double y1 = childPos.dy - (cardHeight + verticalGap) / 2;
            currentPositions[2 * j] = Offset(x, y1);

            // Draw Lines (Prev -> Current is r -> r+1)
            // Start: this node (r) right. End: child node (r+1) left.
            Offset sourceRight = Offset(x + cardWidth, y1 + cardHeight / 2);
            Offset targetLeft = Offset(
              childPos.dx,
              childPos.dy + cardHeight / 2,
            );
            drawBezierLine(canvas, paint, sourceRight, targetLeft);
          }
          // Parent 2 (下方)
          if (2 * j + 1 < roundNodes.length) {
            double y2 = childPos.dy + (cardHeight + verticalGap) / 2;
            currentPositions[2 * j + 1] = Offset(x, y2);

            Offset sourceRight = Offset(x + cardWidth, y2 + cardHeight / 2);
            Offset targetLeft = Offset(
              childPos.dx,
              childPos.dy + cardHeight / 2,
            );
            drawBezierLine(canvas, paint, sourceRight, targetLeft);
          }
        }
      }
      positionsByRound[r] = currentPositions;
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
    return oldDelegate.focusRoundIndex != focusRoundIndex;
  }
}
