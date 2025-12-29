/// 錦標賽對陣圖佈局委託
library;

import 'package:flutter/rendering.dart';

import '../models/tournament_match.dart';
import 'match_card_layout_id.dart';

/// CustomMultiChildLayoutDelegate 實作
///
/// 負責計算每個比賽卡片的精確位置，實現：
/// - X 軸：根據輪次決定水平位置
/// - Y 軸：動態置中，後續輪次根據來源卡片位置計算
class TournamentBracketLayoutDelegate extends MultiChildLayoutDelegate {
  /// 錦標賽資料
  final TournamentBracket bracket;

  /// 用於通知卡片位置更新 (供連線繪製使用)
  final void Function(Map<MatchCardLayoutId, Offset>)? onPositionsCalculated;

  TournamentBracketLayoutDelegate({
    required this.bracket,
    this.onPositionsCalculated,
  });

  @override
  void performLayout(Size size) {
    final cardWidth = TournamentMatch.cardSize.width;
    final cardHeight = TournamentMatch.cardSize.height;
    final horizontalGap = TournamentMatch.horizontalGap;
    final verticalGap = TournamentMatch.verticalGap;

    // 儲存計算出的位置
    final positions = <MatchCardLayoutId, Offset>{};

    // 遍歷每個輪次
    for (var roundIndex = 0; roundIndex < bracket.rounds.length; roundIndex++) {
      final round = bracket.rounds[roundIndex];

      // X 軸位置：根據輪次
      final x = roundIndex * (cardWidth + horizontalGap);

      for (
        var matchIndex = 0;
        matchIndex < round.matches.length;
        matchIndex++
      ) {
        final layoutId = MatchCardLayoutId(
          roundIndex: roundIndex,
          matchIndex: matchIndex,
        );

        // 確認此 child 存在
        if (!hasChild(layoutId)) continue;

        // 讓 child 自己決定尺寸
        layoutChild(layoutId, BoxConstraints.tight(TournamentMatch.cardSize));

        // 計算 Y 軸位置
        double y;
        if (roundIndex == 0) {
          // 第一輪：依序由上而下排列
          y = matchIndex * (cardHeight + verticalGap);
        } else {
          // 後續輪次：使用來源依賴算法
          // 找到兩個來源比賽的位置
          final sourceMatchIndex1 = matchIndex * 2;
          final sourceMatchIndex2 = matchIndex * 2 + 1;

          final sourceId1 = MatchCardLayoutId(
            roundIndex: roundIndex - 1,
            matchIndex: sourceMatchIndex1,
          );
          final sourceId2 = MatchCardLayoutId(
            roundIndex: roundIndex - 1,
            matchIndex: sourceMatchIndex2,
          );

          final sourcePos1 = positions[sourceId1];
          final sourcePos2 = positions[sourceId2];

          if (sourcePos1 != null && sourcePos2 != null) {
            // Y 中心點 = (來源卡片A.y_center + 來源卡片B.y_center) / 2
            final sourceY1Center = sourcePos1.dy + cardHeight / 2;
            final sourceY2Center = sourcePos2.dy + cardHeight / 2;
            final targetYCenter = (sourceY1Center + sourceY2Center) / 2;
            y = targetYCenter - cardHeight / 2;
          } else {
            // 如果找不到來源，使用相對位置
            final spacing = (cardHeight + verticalGap) * (1 << roundIndex);
            y = matchIndex * spacing + (spacing - cardHeight) / 2;
          }
        }

        final position = Offset(x, y);
        positions[layoutId] = position;

        // 定位卡片
        positionChild(layoutId, position);

        // 更新 Match 資料中的位置 (供連線繪製使用)
        round.matches[matchIndex].position = position;
      }
    }

    // 通知位置計算完成
    onPositionsCalculated?.call(positions);
  }

  @override
  Size getSize(BoxConstraints constraints) {
    // 返回整個對陣圖的總尺寸
    return Size(bracket.totalWidth, bracket.totalHeight);
  }

  @override
  bool shouldRelayout(covariant TournamentBracketLayoutDelegate oldDelegate) {
    return bracket != oldDelegate.bracket;
  }
}
