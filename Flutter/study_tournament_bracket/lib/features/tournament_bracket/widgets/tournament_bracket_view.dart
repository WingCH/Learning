/// 錦標賽對陣圖主視圖
library;

import 'package:flutter/material.dart';

import '../layout/match_card_layout_id.dart';
import '../layout/tournament_bracket_delegate.dart';
import '../models/tournament_match.dart';
import '../painters/bracket_connection_painter.dart';
import 'match_card.dart';

/// 橫向滾動的錦標賽對陣圖
class TournamentBracketView extends StatefulWidget {
  /// 錦標賽資料
  final TournamentBracket bracket;

  /// 背景顏色
  final Color backgroundColor;

  /// 連線顏色
  final Color lineColor;

  const TournamentBracketView({
    super.key,
    required this.bracket,
    this.backgroundColor = const Color(0xFFF9FAFB),
    this.lineColor = const Color(0xFF9CA3AF),
  });

  @override
  State<TournamentBracketView> createState() => _TournamentBracketViewState();
}

class _TournamentBracketViewState extends State<TournamentBracketView> {
  /// 用於觸發重繪連線
  final _repaintNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    _repaintNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 對陣圖內容尺寸（加上 padding）
    const padding = 24.0;
    final contentWidth = widget.bracket.totalWidth + padding * 2;
    final contentHeight = widget.bracket.totalHeight + padding * 2;

    return Container(
      color: widget.backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 計算是否需要置中
          final shouldCenterHorizontally = contentWidth < constraints.maxWidth;
          final shouldCenterVertically = contentHeight < constraints.maxHeight;

          return InteractiveViewer(
            // 禁用縮放
            scaleEnabled: false,
            // 啟用雙軸滾動
            constrained: false,
            boundaryMargin: EdgeInsets.symmetric(
              horizontal: shouldCenterHorizontally
                  ? (constraints.maxWidth - contentWidth) / 2
                  : 0,
              vertical: shouldCenterVertically
                  ? (constraints.maxHeight - contentHeight) / 2
                  : 0,
            ),
            child: Padding(
              padding: const EdgeInsets.all(padding),
              child: SizedBox(
                width: widget.bracket.totalWidth,
                height: widget.bracket.totalHeight,
                child: Stack(
                  children: [
                    // 背景連線層
                    Positioned.fill(
                      child: CustomPaint(
                        painter: BracketConnectionPainter(
                          bracket: widget.bracket,
                          lineColor: widget.lineColor,
                        ),
                      ),
                    ),
                    // 卡片佈局層
                    CustomMultiChildLayout(
                      delegate: TournamentBracketLayoutDelegate(
                        bracket: widget.bracket,
                        onPositionsCalculated: (_) {
                          // 位置計算完成後觸發連線重繪
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {});
                            }
                          });
                        },
                      ),
                      children: _buildMatchCards(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 建立所有比賽卡片
  List<Widget> _buildMatchCards() {
    final cards = <Widget>[];

    for (
      var roundIndex = 0;
      roundIndex < widget.bracket.rounds.length;
      roundIndex++
    ) {
      final round = widget.bracket.rounds[roundIndex];
      for (
        var matchIndex = 0;
        matchIndex < round.matches.length;
        matchIndex++
      ) {
        final match = round.matches[matchIndex];
        final layoutId = MatchCardLayoutId(
          roundIndex: roundIndex,
          matchIndex: matchIndex,
        );

        cards.add(
          LayoutId(
            id: layoutId,
            child: MatchCard(match: match),
          ),
        );
      }
    }

    return cards;
  }
}
