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
  // 增加 Curve 屬性，讓高度變化有動畫曲線感
  // 雖然是 Scroll Driven，但在不同階段應用曲線會讓收縮感更自然
  final Curve sizeCurve;

  TournamentLayoutDelegate({
    required this.nodes,
    required this.cardWidth,
    required this.cardHeight,
    required this.horizontalGap,
    required this.verticalGap,
    required this.focusRoundIndex,
    this.sizeCurve = Curves.easeInOut, // 默認使用 EaseInOut
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
    double rawT = focusRoundIndex - floorRound;
    // 應用曲線，讓變化非線性 (Animations!)
    double t = sizeCurve.transform(rawT);

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

    // 使用共用的插值邏輯計算位置
    Map<int, List<Offset>> finalPositionsByRound =
        calculateInterpolatedPositions(
          nodes: nodes,
          focusRoundIndex: focusRoundIndex,
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          horizontalGap: horizontalGap,
          verticalGap: verticalGap,
          sizeCurve: sizeCurve,
        );

    int minVisibleRound = focusRoundIndex.floor();

    // Apply positions to children
    for (var node in nodes) {
      // 優化：如果該輪次小於最小可見輪次，則不進行佈局 (不顯示)
      if (node.round < minVisibleRound) continue;

      if (hasChild(node.id) && finalPositionsByRound[node.round] != null) {
        // Use indexInRound to find safe position
        List<Offset> roundPos = finalPositionsByRound[node.round]!;
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
  final Curve sizeCurve;

  TournamentLinesPainter({
    required this.nodes,
    required this.cardWidth,
    required this.cardHeight,
    required this.horizontalGap,
    required this.verticalGap,
    required this.focusRoundIndex,
    this.sizeCurve = Curves.easeInOut,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Reuse Logic (Simplified copy of LayoutDelegate logic)
    // In production, this logic should be shared.

    // 使用共用的插值邏輯計算位置
    Map<int, List<Offset>> finalPositionsByRound =
        calculateInterpolatedPositions(
          nodes: nodes,
          focusRoundIndex: focusRoundIndex,
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          horizontalGap: horizontalGap,
          verticalGap: verticalGap,
          sizeCurve: sizeCurve,
        );

    int minVisibleRound = focusRoundIndex.floor();
    // anchorRound is only used to iterate rounds.
    // Actually we should iterate all keys in finalPositionsByRound.

    int maxRound = 0;
    for (var k in finalPositionsByRound.keys) {
      if (k > maxRound) {
        maxRound = k;
      }
    }

    // Drawing lines:
    // We iterate from maxRound-1 down to minVisibleRound (Backward / Fan-out style logic matches drawing order)
    // Or iterate from minVisibleRound to maxRound.
    // Logic: Connect Round R to Round R+1.
    // Source: R. Target: R+1.

    // Let's iterate R from minVisibleRound to maxRound - 1.
    // For each node in R+1 (Target), find its parents in R (Source).

    List<int> sortedRounds = finalPositionsByRound.keys.toList()..sort();

    for (int r in sortedRounds) {
      if (r < minVisibleRound) {
        continue;
      }
      if (r == maxRound) {
        continue; // No lines from last round to nowhere? No, lines are usually between R and R+1.
      }

      // Current R is the "Source" side (Left). Next R+1 is "Target" side (Right).
      // Wait, the original logic was:
      // Round R nodes.
      // Round R+1 positions.
      // For each node in R+1, connect to parents in R.

      // Let's look at R+1.
      int nextR = r + 1;
      if (!finalPositionsByRound.containsKey(nextR)) {
        continue;
      }

      List<Offset> nextPosList = finalPositionsByRound[nextR]!;
      List<Offset> currPosList = finalPositionsByRound[r]!;

      // In this tournament structure:
      // Node J in Round R+1 comes from Node 2*J and Node 2*J+1 in Round R.

      for (int j = 0; j < nextPosList.length; j++) {
        Offset targetPos = nextPosList[j];
        Offset targetLeft = Offset(targetPos.dx, targetPos.dy + cardHeight / 2);

        // Parent 1 (2*j)
        if (2 * j < currPosList.length) {
          Offset sourcePos = currPosList[2 * j];
          Offset sourceRight = Offset(
            sourcePos.dx + cardWidth,
            sourcePos.dy + cardHeight / 2,
          );
          drawBezierLine(canvas, paint, sourceRight, targetLeft);
        }

        // Parent 2 (2*j + 1)
        if (2 * j + 1 < currPosList.length) {
          Offset sourcePos = currPosList[2 * j + 1];
          Offset sourceRight = Offset(
            sourcePos.dx + cardWidth,
            sourcePos.dy + cardHeight / 2,
          );
          drawBezierLine(canvas, paint, sourceRight, targetLeft);
        }
      }
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

// =============================================================================
// Helper Functions for Layout Logic
// =============================================================================

// 計算並插值所有節點的位置，供 Delegate and Painter 使用。
// 確保兩者的位置邏輯完全一致。
Map<int, List<Offset>> calculateInterpolatedPositions({
  required List<MatchNode> nodes,
  required double focusRoundIndex,
  required double cardWidth,
  required double cardHeight,
  required double horizontalGap,
  required double verticalGap,
  required Curve sizeCurve,
}) {
  int floorRound = focusRoundIndex.floor();
  int ceilRound = focusRoundIndex.ceil();
  // 為了效能，只計算可見範圍 (從 floorRound 開始)
  int minVisibleRound = floorRound;

  // 1. 計算 floorRound 為 Anchor 的佈局
  var positionsFloor = _calculateBasePositions(
    nodes: nodes,
    anchorRound: floorRound,
    cardWidth: cardWidth,
    cardHeight: cardHeight,
    horizontalGap: horizontalGap,
    verticalGap: verticalGap,
    minVisibleRound: minVisibleRound,
  );

  bool needInterpolation = floorRound != ceilRound;
  Map<int, List<Offset>> positionsCeil = {};

  // 2. 如果需要，計算 ceilRound 為 Anchor 的佈局
  if (needInterpolation) {
    positionsCeil = _calculateBasePositions(
      nodes: nodes,
      anchorRound: ceilRound,
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      horizontalGap: horizontalGap,
      verticalGap: verticalGap,
      minVisibleRound: minVisibleRound,
    );
  }

  // 3. 計算插值係數 t
  double rawT = focusRoundIndex - floorRound;
  double t = sizeCurve.transform(rawT);

  Map<int, List<Offset>> finalPositionsByRound = {};

  // 4. 合併結果
  Set<int> allRounds = {};
  allRounds.addAll(positionsFloor.keys);

  if (needInterpolation) {
    allRounds.addAll(positionsCeil.keys);
  }

  for (int r in allRounds) {
    List<Offset>? list1 = positionsFloor[r];
    List<Offset>? list2 = positionsCeil[r];

    List<Offset> resultList = [];
    int length = list1?.length ?? list2?.length ?? 0;

    for (int i = 0; i < length; i++) {
      // 如果某一邊沒有數據 (不應該發生在相同節點集)，使用 Offset.zero 或 對方的數據
      Offset p1 = (list1 != null && i < list1.length)
          ? list1[i]
          : (list2 != null && i < list2.length ? list2[i] : Offset.zero);
      Offset p2 = (list2 != null && i < list2.length) ? list2[i] : p1;

      // Lerp 插值
      Offset interpolated = Offset.lerp(p1, p2, t)!;
      resultList.add(interpolated);
    }
    finalPositionsByRound[r] = resultList;
  }
  return finalPositionsByRound;
}

// 根據指定的 Anchor Round 計算基本位置
Map<int, List<Offset>> _calculateBasePositions({
  required List<MatchNode> nodes,
  required int anchorRound,
  required double cardWidth,
  required double cardHeight,
  required double horizontalGap,
  required double verticalGap,
  required int minVisibleRound,
}) {
  Map<int, List<Offset>> positionsByRound = {};
  int maxRound = 0;
  for (var node in nodes) {
    if (node.round > maxRound) {
      maxRound = node.round;
    }
  }

  // 步驟 1: 佈局 Anchor Round
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

  // 步驟 2: 向前佈局 (Rounds > Anchor)
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
      }
      currentPositions.add(Offset(x, y));
    }
    positionsByRound[r] = currentPositions;
  }

  // 步驟 3: 向後佈局 (Rounds < Anchor)
  // 只計算 minVisibleRound 以後的
  for (int r = anchorRound - 1; r >= minVisibleRound; r--) {
    List<MatchNode> roundNodes = nodes.where((n) => n.round == r).toList();
    roundNodes.sort((a, b) => a.indexInRound.compareTo(b.indexInRound));
    List<Offset> currentPositions = List.filled(roundNodes.length, Offset.zero);
    var nextPositions = positionsByRound[r + 1];

    if (nextPositions != null) {
      for (int j = 0; j < nextPositions.length; j++) {
        Offset childPos = nextPositions[j];
        double x = r * (cardWidth + horizontalGap) + 20;

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
  return positionsByRound;
}
