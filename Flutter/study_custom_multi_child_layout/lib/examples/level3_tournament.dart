import 'package:flutter/material.dart';
import 'package:flutter/physics.dart'; // ScrollSpringSimulation 需要此引用

/// Level 3: 錦標賽對陣圖 (Tournament Bracket)
///
/// 這個範例展示了如何使用 [CustomMultiChildLayout] 和 [CustomPainter] 實現一個高品質的錦標賽對陣圖。
///
/// 主要功能特色：
/// 1. **精確佈局**: 使用自定義 Delegate 計算每個 "比賽卡片" (MatchNode) 的精確 (x, y) 坐標。
/// 2. **動態視窗**: 隨著用戶向右滾動 (進入決賽圈)，容器的高度會自動收縮，因為後面的比賽較少，不需要那麼高的空間。
/// 3. **平滑動畫**: 所有的位置變化和高度變化都基於滾動位置 (Scroll Position) 進行插值 (Interpolation)，確保視覺上的連續性。
/// 4. **方括號連線**: 使用自定義 Painter 繪製帶有圓角的方括號連線，並且連線會隨著滾動自動調整與卡片的間距。
/// 5. **吸附效果**: 實現了類似 PageView 的滾動吸附效果，讓用戶鬆手時總是停在某一輪的起始位置。

// =============================================================================
// 數據模型 (Data Model)
// =============================================================================

/// 代表一場比賽的節點
class MatchNode {
  final String id;
  final int round; // 輪次：0 (16強), 1 (8強), 2 (4強), 3 (準決賽), 4 (決賽)
  final int indexInRound; // 該輪次中的索引 (從上到下)
  final String label;

  MatchNode({
    required this.id,
    required this.round,
    required this.indexInRound,
    required this.label,
  });
}

// =============================================================================
// 主頁面 Widget (Main Widget)
// =============================================================================

class Level3TournamentExample extends StatefulWidget {
  const Level3TournamentExample({super.key});

  @override
  State<Level3TournamentExample> createState() =>
      _Level3TournamentExampleState();
}

class _Level3TournamentExampleState extends State<Level3TournamentExample>
    with TickerProviderStateMixin {
  // 比賽數據列表
  late List<MatchNode> _nodes;
  // 總輪數 (例如 5 輪對應 16 隊單敗淘汰制) 16 -> 8 -> 4 -> 2 -> 1 (5 rounds)
  final int _totalRounds = 5;

  // 滾動控制器，用於監聽滾動位置
  final ScrollController _scrollController = ScrollController();

  // 當前滾動到的 "輪次索引" (可以是小數，例如 1.5 代表在第1輪和第2輪中間)
  // 這個變量驅動了整個佈局的動畫狀態
  double _currentRoundIndex = 0.0;

  // --- 佈局配置參數 ---
  final double _cardHeight = 60; // 卡片高度
  final double _horizontalGap = 20; // 卡片之間的水平間距
  final double _verticalGap = 10; // 卡片之間的垂直間距
  final double _paddingLeft = 8; // 容器左邊距
  final double _paddingRight = 20; // 容器右邊距

  // --- 展開/收起功能相關變數 ---
  /// 目前「吸附後」所在的輪次頁面（用於偵測翻頁後 reset）
  int _activeRoundPage = 0;

  /// 收起時的固定高度（約顯示 4 張卡片）
  /// 計算公式：4 * (cardHeight + verticalGap) + verticalGap
  double get _collapsedHeight =>
      4 * (_cardHeight + _verticalGap) + _verticalGap;

  /// 按鈕區域高度
  final double _buttonHeight = 60;

  /// 展開/收起動畫控制器
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  // 動態計算卡片寬度
  // (螢幕寬度 - 左邊距 - 右邊距 - 一個水平間隙) / 2
  double get _cardWidth {
    double screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth - _paddingLeft - _paddingRight - _horizontalGap) / 2;
  }

  @override
  void initState() {
    super.initState();
    _nodes = _generateNodes();
    // 監聽滾動事件，實時更新 _currentRoundIndex
    _scrollController.addListener(_onScroll);

    // 展開/收起動畫
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  /// 滾動監聯回調
  void _onScroll() {
    // 計算每一 "頁" (一輪比賽) 的總寬度 = 卡片寬度 + 間距
    final itemWidth = _cardWidth + _horizontalGap;

    // 將像素偏移量轉換為輪次索引 (例如 滾動了 300px, itemWidth 是 150px, 則 index = 2.0)
    double newRoundIndex = _scrollController.offset / itemWidth;

    // 限制範圍，防止越界
    newRoundIndex = newRoundIndex.clamp(0.0, (_totalRounds - 1).toDouble());

    // 偵測頁面切換並重置展開狀態
    int newPage = newRoundIndex.round();
    if (newPage != _activeRoundPage) {
      _activeRoundPage = newPage;
      // 如果當前是展開狀態，自動收起
      if (_expandController.value > 0) {
        _expandController.reverse();
      }
    }

    // 更新狀態。
    // 因為這是一個 Scroll-Driven Animation (滾動驅動動畫)，我們這裡使用 setState 來驅動每一幀的變化。
    setState(() {
      _currentRoundIndex = newRoundIndex;
    });
  }

  /// 生成模擬數據
  List<MatchNode> _generateNodes() {
    List<MatchNode> nodes = [];
    int matchesInRound = 16;
    for (int r = 0; r < _totalRounds; r++) {
      for (int i = 0; i < matchesInRound; i++) {
        String roundName;
        // 根據剩餘比賽數量命名
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
      matchesInRound ~/= 2; // 下一輪比賽數量減半
    }
    return nodes;
  }

  /// 構建展開/收起按鈕
  Widget _buildExpandCollapseButton() {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, _) {
        bool isExpanded = _expandController.value > 0.5;
        return Container(
          color: Colors.grey.shade50,
          child: Center(
            child: TextButton.icon(
              onPressed: () {
                if (_expandController.isCompleted) {
                  _expandController.reverse();
                } else {
                  _expandController.forward();
                }
              },
              icon: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 20,
              ),
              label: Text(isExpanded ? '收起' : '更多'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 計算當前 round 的完整高度
    final double fullHeight = calculateInterpolatedHeight(
      nodes: _nodes,
      focusRoundIndex: _currentRoundIndex,
      cardHeight: _cardHeight,
      verticalGap: _verticalGap,
    );

    // 判斷是否需要顯示展開按鈕（使用 epsilon 避免浮點誤差）
    final bool canExpand = fullHeight > _collapsedHeight + 0.5;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 主要內容：水平滾動的錦標賽佈局
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: _SnappingScrollPhysics(
              itemWidth: _cardWidth + _horizontalGap,
            ),
            child: ClipRect(
              child: Container(
                color: Colors.grey.shade50,
                child: CustomMultiChildLayout(
                  delegate: TournamentLayoutDelegate(
                    nodes: _nodes,
                    cardWidth: _cardWidth,
                    cardHeight: _cardHeight,
                    horizontalGap: _horizontalGap,
                    verticalGap: _verticalGap,
                    paddingLeft: _paddingLeft,
                    focusRoundIndex: _currentRoundIndex,
                    screenWidth: MediaQuery.sizeOf(context).width,
                    // 展開/收起功能參數
                    expandAnimation: _expandAnimation,
                    collapsedHeight: _collapsedHeight,
                    canExpand: canExpand,
                    buttonHeight: _buttonHeight,
                  ),
                  children: [
                    // 1. 繪製連線 (背景層)
                    LayoutId(
                      id: 'lines',
                      child: CustomPaint(
                        painter: TournamentLinesPainter(
                          nodes: _nodes,
                          cardWidth: _cardWidth,
                          cardHeight: _cardHeight,
                          horizontalGap: _horizontalGap,
                          verticalGap: _verticalGap,
                          paddingLeft: _paddingLeft,
                          focusRoundIndex: _currentRoundIndex,
                        ),
                      ),
                    ),
                    // 2. 繪製卡片 (前景層)
                    for (var node in _nodes)
                      if (node.round >= _currentRoundIndex.floor())
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
          ),
          // 展開/收起按鈕：在卡片區域下方，不遮擋內容
          if (canExpand) _buildExpandCollapseButton(),
        ],
      ),
    );
  }
}

// =============================================================================
// 滾動物理效果 (Scroll Physics)
// =============================================================================

/// 自定義滾動物理，實現 "翻頁吸附" 效果。
/// 當用戶停止滾動時，會自動彈回到最近的一個 "列" (Round) 的起始位置。
class _SnappingScrollPhysics extends ScrollPhysics {
  final double itemWidth; // 每一列的寬度 (卡片寬 + 間距)

  const _SnappingScrollPhysics({required this.itemWidth, super.parent});

  @override
  _SnappingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SnappingScrollPhysics(
      itemWidth: itemWidth,
      parent: buildParent(ancestor),
    );
  }

  // 創建彈道模擬 (當用戶手指離開螢幕時觸發)
  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // 如果已經滾動超出邊界，使用默認行為 (彈回)
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final Tolerance tolerance = toleranceFor(position);

    // 預測用戶原本會停下的位置
    double target = position.pixels;
    if (velocity.abs() > tolerance.velocity) {
      // 如果有甩動速度，稍微預測遠一點
      target += velocity * 0.3;
    }

    // 計算這是在第幾頁 (Round)
    double page = target / itemWidth;
    // 四捨五入到最近的整數頁
    int index = page.round();

    // 最終吸附的目標像素位置
    double destination = index * itemWidth;

    // 使用彈簧模擬 (Spring) 讓它平滑地彈到目標位置
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      destination,
      velocity,
      tolerance: tolerance,
    );
  }
}

// =============================================================================
// UI 組件: 比賽卡片 (Tournament Card)
// =============================================================================

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
    // 一個簡單的卡片樣式
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
          const SizedBox(height: 2),
          const Text("vs", style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

// =============================================================================
// 佈局邏輯 Delegate (The Brain)
// =============================================================================

class TournamentLayoutDelegate extends MultiChildLayoutDelegate {
  final List<MatchNode> nodes;
  final double cardWidth;
  final double cardHeight;
  final double horizontalGap;
  final double verticalGap;
  final double paddingLeft;
  final double focusRoundIndex; // 核心參數：當前滾動進度

  final double screenWidth;

  // 曲線屬性，用於讓高度變化的過渡更自然
  final Curve sizeCurve;

  // --- 展開/收起功能參數 ---
  final Animation<double> expandAnimation;
  final double collapsedHeight;
  final bool canExpand;
  final double buttonHeight;

  TournamentLayoutDelegate({
    required this.nodes,
    required this.cardWidth,
    required this.cardHeight,
    required this.horizontalGap,
    required this.verticalGap,
    required this.paddingLeft,
    required this.focusRoundIndex,
    required this.screenWidth,
    required this.expandAnimation,
    required this.collapsedHeight,
    required this.canExpand,
    this.buttonHeight = 60,
    this.sizeCurve = Curves.easeInOut,
  }) : super(relayout: expandAnimation); // 關鍵！綁定動畫驅動 relayout

  /// 決定整個 Layout 的總尺寸
  @override
  Size getSize(BoxConstraints constraints) {
    // 1. 計算總寬度
    int maxRound = 0;
    for (var node in nodes) {
      if (node.round > maxRound) maxRound = node.round;
    }

    // 總寬度邏輯：
    // 我們希望最後能停在 "準決賽 & 決賽" (Displaying the last two rounds together).
    // 所以最後一個吸附點應該是 maxRound - 1 (倒數第二輪)。
    // 這樣當我們吸附到這裡時，螢幕左邊是 "準決賽"，右邊是 "決賽"。
    // TotalWidth = (maxRound - 1) * itemWidth + screenWidth;

    double itemWidth = cardWidth + horizontalGap;
    // 使用 max(0, ...) 避免只有一輪時出錯
    double totalWidth =
        (maxRound > 0 ? maxRound - 1 : 0) * itemWidth + screenWidth;

    // 確保總寬度至少能容納內容 (雖然後面的公式應該cover了，但保險起見)

    // 2. 計算完整高度
    double fullHeight = calculateInterpolatedHeight(
      nodes: nodes,
      focusRoundIndex: focusRoundIndex,
      cardHeight: cardHeight,
      verticalGap: verticalGap,
      sizeCurve: sizeCurve,
    );

    // 3. 根據展開狀態計算實際高度
    double currentHeight;
    if (!canExpand) {
      // 不需要展開功能，使用完整高度
      currentHeight = fullHeight;
    } else {
      // 使用動畫值插值計算高度
      currentHeight =
          collapsedHeight +
          (fullHeight - collapsedHeight) * expandAnimation.value;
    }

    return Size(totalWidth, currentHeight);
  }

  /// 執行佈局，放置每個子元件
  @override
  void performLayout(Size size) {
    // 1. 佈局連線層 (它鋪滿整個容器)
    if (hasChild('lines')) {
      layoutChild('lines', BoxConstraints.tight(size));
      positionChild('lines', Offset.zero);
    }

    // 2. 計算所有卡片的位置
    // 這裡我們抽取出了一個共用函數，因為 Painter 也需要同樣的位置邏輯
    Map<int, List<Offset>> finalPositionsByRound =
        calculateInterpolatedPositions(
          nodes: nodes,
          focusRoundIndex: focusRoundIndex,
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          horizontalGap: horizontalGap,
          verticalGap: verticalGap,
          paddingLeft: paddingLeft,
          sizeCurve: sizeCurve,
        );

    int minVisibleRound = focusRoundIndex.floor();

    // 3. 遍歷節點並設置位置
    for (var node in nodes) {
      // 隱藏已經滾出畫面很遠的節點 (優化)
      if (node.round < minVisibleRound) continue;

      if (hasChild(node.id) && finalPositionsByRound[node.round] != null) {
        List<Offset> roundPos = finalPositionsByRound[node.round]!;
        if (node.indexInRound < roundPos.length) {
          Offset pos = roundPos[node.indexInRound];

          // 設置子元件大小
          layoutChild(
            node.id,
            BoxConstraints.tight(Size(cardWidth, cardHeight)),
          );
          // 設置子元件位置
          positionChild(node.id, pos);
        }
      }
    }
  }

  @override
  bool shouldRelayout(covariant TournamentLayoutDelegate oldDelegate) {
    // 當滾動或者節點改變時，重新佈局
    // 注意：expandAnimation 透過 super(relayout:) 自動處理
    return oldDelegate.focusRoundIndex != focusRoundIndex ||
        oldDelegate.nodes != nodes ||
        oldDelegate.canExpand != canExpand ||
        oldDelegate.collapsedHeight != collapsedHeight;
  }
}

// =============================================================================
// 繪圖邏輯 (Custom Painter)
// =============================================================================

class TournamentLinesPainter extends CustomPainter {
  final List<MatchNode> nodes;
  final double cardWidth;
  final double cardHeight;
  final double horizontalGap;
  final double verticalGap;
  final double paddingLeft;
  final double focusRoundIndex;
  final Curve sizeCurve;

  TournamentLinesPainter({
    required this.nodes,
    required this.cardWidth,
    required this.cardHeight,
    required this.horizontalGap,
    required this.verticalGap,
    required this.paddingLeft,
    required this.focusRoundIndex,
    this.sizeCurve = Curves.easeInOut,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 重複使用相同的邏輯來獲取卡片位置
    Map<int, List<Offset>> finalPositionsByRound =
        calculateInterpolatedPositions(
          nodes: nodes,
          focusRoundIndex: focusRoundIndex,
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          horizontalGap: horizontalGap,
          verticalGap: verticalGap,
          paddingLeft: paddingLeft,
          sizeCurve: sizeCurve,
        );

    int minVisibleRound = focusRoundIndex.floor();

    // 取得所有存在的輪次並排序
    List<int> sortedRounds = finalPositionsByRound.keys.toList()..sort();
    int maxRound = sortedRounds.isEmpty ? 0 : sortedRounds.last;

    // 遍歷每一輪，畫出它 "連接到下一輪" 的線
    for (int r in sortedRounds) {
      // 優化：不需要畫看不見的輪次，但為了保險起見，畫 minVisibleRound 之前的連線可能需要小心
      // 這裡我們畫出 minVisibleRound 及其之後的連線
      if (r < minVisibleRound) continue;

      // 最後一輪沒有 "下一輪"，所以不需要畫線
      if (r == maxRound) continue;

      int nextR = r + 1;
      if (!finalPositionsByRound.containsKey(nextR)) continue;

      List<Offset> nextPosList = finalPositionsByRound[nextR]!;
      List<Offset> currPosList = finalPositionsByRound[r]!;

      // 邏輯：下一輪的卡片 J，是由 本輪的卡片 2*J 和 2*J+1 晉級而來的。
      // 所以我們遍歷下一輪 (Target)，回頭找本輪的父母 (Source)。
      for (int j = 0; j < nextPosList.length; j++) {
        Offset targetPos = nextPosList[j];

        // --- 動態間距動畫 ---
        // 我們希望當用戶滾動過去時，舊的連線會慢慢與卡片分離，形成一種 "過去式" 的感覺，
        // 或者至少是為了視覺上的整潔。
        double animatedGap = 0.0;
        if (r < focusRoundIndex) {
          double t = focusRoundIndex - r;
          if (t > 1.0) t = 1.0;
          // 當完全滾過這一輪時，Gap 會變成 8.0
          animatedGap = t * 8.0;
        }

        // 確保 Gap 不會大到讓線條交叉或看起來奇怪
        double maxPadding = horizontalGap / 2 - 1.0;
        if (maxPadding < 0) maxPadding = 0;
        double linePadding = (animatedGap > maxPadding)
            ? maxPadding
            : animatedGap;

        // 計算目標點 (右側卡片的左邊緣)
        // 注意：targetPos 是卡片的左上角
        Offset targetLeft = Offset(
          targetPos.dx - linePadding,
          targetPos.dy + cardHeight / 2, // 垂直置中
        );

        // 尋找來源 (左側卡片的右邊緣)
        Offset? source1Right; // 上方的來源
        Offset? source2Right; // 下方的來源

        // 來源 1 (Index: 2*j)
        if (2 * j < currPosList.length) {
          Offset sourcePos = currPosList[2 * j];
          source1Right = Offset(
            sourcePos.dx + cardWidth,
            sourcePos.dy + cardHeight / 2,
          );
        }

        // 來源 2 (Index: 2*j + 1)
        if (2 * j + 1 < currPosList.length) {
          Offset sourcePos = currPosList[2 * j + 1];
          source2Right = Offset(
            sourcePos.dx + cardWidth,
            sourcePos.dy + cardHeight / 2,
          );
        }

        // 繪製連線
        if (source1Right != null && source2Right != null) {
          // 兩個來源都有 -> 畫一個合併的方括號
          drawBracketConnection(
            canvas,
            paint,
            source1Right,
            source2Right,
            targetLeft,
          );
        } else if (source1Right != null) {
          // 只有一個來源 -> 畫單條折線 (可能是輪空的情況)
          drawSingleConnection(canvas, paint, source1Right, targetLeft);
        } else if (source2Right != null) {
          drawSingleConnection(canvas, paint, source2Right, targetLeft);
        }
      }
    }
  }

  /// 繪製方括號連線 (Squared Bracket)
  /// 形狀像是一個橫向的 ']'，將兩個源頭匯聚到一個目標
  void drawBracketConnection(
    Canvas canvas,
    Paint paint,
    Offset src1,
    Offset src2,
    Offset target,
  ) {
    final path = Path();
    // 找出轉折點的 X 坐標 (兩點之間的中線)
    double midX = (src1.dx + target.dx) / 2;

    // 計算可用的圓角半徑空間，避免空間太小圓角錯亂
    double availableSpace = (midX - src1.dx).abs();
    double radius = (availableSpace < 10.0) ? availableSpace : 10.0;

    // 確保 src1 在上方，src2 在下方，方便邏輯處理
    if (src1.dy > src2.dy) {
      final temp = src1;
      src1 = src2;
      src2 = temp;
    }

    // --- 上半部路徑 (src1 -> target) ---
    path.moveTo(src1.dx, src1.dy);
    // 1. 水平線向右
    if (availableSpace > radius) {
      path.lineTo(midX - radius, src1.dy);
    }
    // 2. 向下彎的圓角
    path.quadraticBezierTo(midX, src1.dy, midX, src1.dy + radius);
    // 3. 垂直線向下延伸到 target 的高度
    path.lineTo(midX, target.dy);

    // --- 下半部路徑 (src2 -> target) ---
    path.moveTo(src2.dx, src2.dy);
    // 1. 水平線向右
    if (availableSpace > radius) {
      path.lineTo(midX - radius, src2.dy);
    }
    // 2. 向上彎的圓角
    path.quadraticBezierTo(midX, src2.dy, midX, src2.dy - radius);
    // 3. 垂直線向上延伸 (會與上半部路徑重合)
    path.lineTo(midX, target.dy);

    // --- 匯合後連向目標 ---
    path.moveTo(midX, target.dy);
    path.lineTo(target.dx, target.dy);

    canvas.drawPath(path, paint);
  }

  /// 繪製單一連線 (Single Connection)
  /// 用於只有一個來源節點的情況 (例如輪空)
  void drawSingleConnection(
    Canvas canvas,
    Paint paint,
    Offset src,
    Offset target,
  ) {
    final path = Path();
    double midX = (src.dx + target.dx) / 2;
    double radius = 10.0;

    path.moveTo(src.dx, src.dy);

    // 具體的路徑邏輯：畫一個簡單的 S 型折線 (Horizontal -> Corner -> Vertical -> Corner -> Horizontal)

    // 如果空間不足以畫圓角，則直接畫折線
    if ((midX - src.dx).abs() < radius) {
      path.lineTo(midX, src.dy);
      path.lineTo(midX, target.dy);
      path.lineTo(target.dx, target.dy);
    } else {
      // 1. 水平延伸至中線前
      path.lineTo(midX - radius, src.dy);

      // 2. 第一個圓角 (轉向垂直)
      // 判斷 target 在 src 的上方還是下方
      double verticalDirection = (target.dy > src.dy) ? 1.0 : -1.0;
      path.quadraticBezierTo(
        midX,
        src.dy,
        midX,
        src.dy + radius * verticalDirection,
      );

      // 3. 垂直延伸至 target 高度前 (如果有足夠垂直空間)
      double verticalDist = (target.dy - src.dy).abs();
      if (verticalDist > 2 * radius) {
        path.lineTo(midX, target.dy - radius * verticalDirection);

        // 4. 第二個圓角 (轉向水平)
        path.quadraticBezierTo(
          midX,
          target.dy,
          midX + radius, // 假設 target 在右測
          target.dy,
        );
      } else {
        // 垂直距離很短，直接連過去 (簡化)
        path.lineTo(midX, target.dy);
      }

      // 5. 水平延伸至 target
      path.lineTo(target.dx, target.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TournamentLinesPainter oldDelegate) {
    return oldDelegate.focusRoundIndex != focusRoundIndex;
  }
}

// =============================================================================
// 核心算法: 位置計算與插值 (Core Algorithm)
// =============================================================================

/// 計算所有節點在當前畫面時刻的精確位置。
/// 這是實現 "平滑過渡" 的關鍵。
Map<int, List<Offset>> calculateInterpolatedPositions({
  required List<MatchNode> nodes,
  required double focusRoundIndex,
  required double cardWidth,
  required double cardHeight,
  required double horizontalGap,
  required double verticalGap,
  required double paddingLeft,
  required Curve sizeCurve,
}) {
  // 找出插值的兩個端點：Floor (前一整數輪) 和 Ceil (後一整數輪)
  // 例如 focusRoundIndex = 1.5，則 Floor=1, Ceil=2
  int floorRound = focusRoundIndex.floor();
  int ceilRound = focusRoundIndex.ceil();

  // 優化：只計算可見範圍
  int minVisibleRound = floorRound;

  // 1. 計算【狀態 A】：假設當前是 floorRound (例如 16強) 時，所有卡片的位置
  var positionsFloor = _calculateBasePositions(
    nodes: nodes,
    anchorRound: floorRound,
    cardWidth: cardWidth,
    cardHeight: cardHeight,
    horizontalGap: horizontalGap,
    verticalGap: verticalGap,
    paddingLeft: paddingLeft,
    minVisibleRound: minVisibleRound,
  );

  bool needInterpolation = floorRound != ceilRound;
  Map<int, List<Offset>> positionsCeil = {};

  // 2. 計算【狀態 B】：假設當前是 ceilRound (例如 8強) 時，所有卡片的位置
  // 在狀態 B 中，8強會變成 "基準" (Anchor)，排列會更緊湊。
  if (needInterpolation) {
    positionsCeil = _calculateBasePositions(
      nodes: nodes,
      anchorRound: ceilRound,
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      horizontalGap: horizontalGap,
      verticalGap: verticalGap,
      paddingLeft: paddingLeft,
      minVisibleRound: minVisibleRound,
    );
  }

  // 3. 計算插值係數 t
  double rawT = focusRoundIndex - floorRound;
  double t = sizeCurve.transform(rawT);

  Map<int, List<Offset>> finalPositionsByRound = {};

  // 4. 合併結果：對每一個節點的位置進行線性插值 (Lerp)
  // Pos = PosA * (1-t) + PosB * t
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
      // 獲取起點和終點，如果某邊缺失則用對方位置或 Zero
      Offset p1 = (list1 != null && i < list1.length)
          ? list1[i]
          : (list2 != null && i < list2.length ? list2[i] : Offset.zero);
      Offset p2 = (list2 != null && i < list2.length) ? list2[i] : p1;

      // 執行插值
      Offset interpolated = Offset.lerp(p1, p2, t)!;
      resultList.add(interpolated);
    }
    finalPositionsByRound[r] = resultList;
  }
  return finalPositionsByRound;
}

/// 基礎位置計算函數
/// 根據給定的 [anchorRound] 作為基準，計算整個樹狀結構的位置。
///
/// 算法邏輯：
/// 1. Anchor Round (基準輪): 從上到下緊密排列，作為定位的錨點。
/// 2. Forward (向右): 下一輪的位置取決於上一輪對應節點的中點 (Vertical Center)。
/// 3. Backward (向左): 上一輪的位置取決於下一輪對應節點的展開。
Map<int, List<Offset>> _calculateBasePositions({
  required List<MatchNode> nodes,
  required int anchorRound,
  required double cardWidth,
  required double cardHeight,
  required double horizontalGap,
  required double verticalGap,
  required double paddingLeft,
  required int minVisibleRound,
}) {
  Map<int, List<Offset>> positionsByRound = {};
  int maxRound = 0;
  for (var node in nodes) {
    if (node.round > maxRound) maxRound = node.round;
  }

  // --- 步驟 1: 佈局 Anchor Round (基準輪) ---
  // 這是最重要的一步。當我們說 "現在是 8強" 時，8強的卡片應該排列整齊，沒有多餘間隙。
  List<MatchNode> anchorNodes = nodes
      .where((n) => n.round == anchorRound)
      .toList();
  anchorNodes.sort((a, b) => a.indexInRound.compareTo(b.indexInRound));

  List<Offset> anchorPositions = [];
  double startY = verticalGap;

  for (int i = 0; i < anchorNodes.length; i++) {
    double x = anchorRound * (cardWidth + horizontalGap) + paddingLeft;
    double y = startY + i * (cardHeight + verticalGap);
    anchorPositions.add(Offset(x, y));
  }
  positionsByRound[anchorRound] = anchorPositions;

  // --- 步驟 2: 向右佈局 (Rounds > Anchor) ---
  // 例如已經排好 16強，現在排 8強。8強某個卡片的位置，應該是它來源的兩個 16強卡片的垂直中心。
  for (int r = anchorRound + 1; r <= maxRound; r++) {
    List<MatchNode> roundNodes = nodes.where((n) => n.round == r).toList();
    roundNodes.sort((a, b) => a.indexInRound.compareTo(b.indexInRound));
    List<Offset> currentPositions = [];
    var prevPositions = positionsByRound[r - 1];

    for (int i = 0; i < roundNodes.length; i++) {
      double x = r * (cardWidth + horizontalGap) + paddingLeft;
      double y = 0;
      // 找到上一輪對應的兩個節點 (2*i 和 2*i+1)
      if (prevPositions != null && prevPositions.length > 2 * i + 1) {
        double y1 = prevPositions[2 * i].dy;
        double y2 = prevPositions[2 * i + 1].dy;
        y = (y1 + y2) / 2; // 取中點
      }
      currentPositions.add(Offset(x, y));
    }
    positionsByRound[r] = currentPositions;
  }

  // --- 步驟 3: 向左佈局 (Rounds < Anchor) ---
  // 例如已經排好 8強 (Anchor)，現在要反推 16強的位置。
  // 16強的位置會相對於 8強展開。
  for (int r = anchorRound - 1; r >= minVisibleRound; r--) {
    List<MatchNode> roundNodes = nodes.where((n) => n.round == r).toList();
    roundNodes.sort((a, b) => a.indexInRound.compareTo(b.indexInRound));
    List<Offset> currentPositions = List.filled(roundNodes.length, Offset.zero);
    var nextPositions = positionsByRound[r + 1];

    if (nextPositions != null) {
      for (int j = 0; j < nextPositions.length; j++) {
        Offset childPos = nextPositions[j];
        double x = r * (cardWidth + horizontalGap) + paddingLeft;

        // 我們知道 childPos 是 nextPositions[j]，它是由 currentPositions[2*j] 和 [2*j+1] 組成的。
        // 所以我們把 childPos 上下展開來決定 currentPositions。

        // Parent 1 (上方節點)
        if (2 * j < roundNodes.length) {
          double y1 = childPos.dy - (cardHeight + verticalGap) / 2;
          currentPositions[2 * j] = Offset(x, y1);
        }
        // Parent 2 (下方節點)
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

// =============================================================================
// 共用高度計算函數 (Shared Height Calculation)
// =============================================================================

/// 計算某一輪的理論總高度
double calculateHeightForRound({
  required List<MatchNode> nodes,
  required int round,
  required double cardHeight,
  required double verticalGap,
}) {
  int count = nodes.where((n) => n.round == round).length;
  if (count == 0) return 0;
  return count * cardHeight + (count + 1) * verticalGap;
}

/// 計算當前滾動位置的插值高度（與 delegate 完全一致）
double calculateInterpolatedHeight({
  required List<MatchNode> nodes,
  required double focusRoundIndex,
  required double cardHeight,
  required double verticalGap,
  Curve sizeCurve = Curves.easeInOut,
}) {
  int floorRound = focusRoundIndex.floor();
  int ceilRound = focusRoundIndex.ceil();

  double rawT = focusRoundIndex - floorRound;
  double t = sizeCurve.transform(rawT);

  double h1 = calculateHeightForRound(
    nodes: nodes,
    round: floorRound,
    cardHeight: cardHeight,
    verticalGap: verticalGap,
  );
  double h2 = calculateHeightForRound(
    nodes: nodes,
    round: ceilRound,
    cardHeight: cardHeight,
    verticalGap: verticalGap,
  );

  double currentHeight = h1 + (h2 - h1) * t;

  // 最小高度防呆
  if (currentHeight < cardHeight) {
    currentHeight = cardHeight + verticalGap;
  }

  return currentHeight;
}
