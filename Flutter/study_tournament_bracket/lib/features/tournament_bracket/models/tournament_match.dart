/// 錦標賽對陣圖資料模型
library;

import 'package:flutter/material.dart';

/// 單場比賽資料
class TournamentMatch {
  /// 比賽唯一識別碼
  final String id;

  /// 隊伍 A 名稱
  final String teamA;

  /// 隊伍 B 名稱
  final String teamB;

  /// 隊伍 A 分數 (可為 null 表示尚未比賽)
  final int? scoreA;

  /// 隊伍 B 分數 (可為 null 表示尚未比賽)
  final int? scoreB;

  /// 獲勝隊伍 (null 表示尚未決出或平局)
  final String? winner;

  /// 比賽計算後的位置 (由 Layout Delegate 填充)
  Offset? position;

  /// 比賽卡片尺寸
  static const Size cardSize = Size(160, 80);

  /// 水平間距
  static const double horizontalGap = 60;

  /// 垂直間距
  static const double verticalGap = 20;

  TournamentMatch({
    required this.id,
    required this.teamA,
    required this.teamB,
    this.scoreA,
    this.scoreB,
    this.winner,
    this.position,
  });

  /// 卡片右側中心點 (用於繪製連接線)
  Offset get rightCenter {
    if (position == null) return Offset.zero;
    return Offset(
      position!.dx + cardSize.width,
      position!.dy + cardSize.height / 2,
    );
  }

  /// 卡片左側中心點 (用於繪製連接線)
  Offset get leftCenter {
    if (position == null) return Offset.zero;
    return Offset(position!.dx, position!.dy + cardSize.height / 2);
  }

  /// 卡片 Y 軸中心點
  double get yCenter {
    if (position == null) return 0;
    return position!.dy + cardSize.height / 2;
  }
}

/// 單一輪次資料
class TournamentRound {
  /// 輪次索引 (0 = 第一輪)
  final int roundIndex;

  /// 該輪次的所有比賽
  final List<TournamentMatch> matches;

  /// 輪次名稱
  final String name;

  TournamentRound({
    required this.roundIndex,
    required this.matches,
    required this.name,
  });
}

/// 完整對陣圖資料
class TournamentBracket {
  /// 所有輪次
  final List<TournamentRound> rounds;

  /// 錦標賽名稱
  final String name;

  TournamentBracket({required this.rounds, required this.name});

  /// 輪次數量
  int get roundCount => rounds.length;

  /// 第一輪比賽數量 (最多的一輪)
  int get firstRoundMatchCount =>
      rounds.isNotEmpty ? rounds.first.matches.length : 0;

  /// 取得所有比賽的平坦列表
  List<TournamentMatch> get allMatches {
    return rounds.expand((round) => round.matches).toList();
  }

  /// 計算容器總寬度
  double get totalWidth {
    if (roundCount == 0) return 0;
    return roundCount * TournamentMatch.cardSize.width +
        (roundCount - 1) * TournamentMatch.horizontalGap;
  }

  /// 計算容器總高度
  double get totalHeight {
    if (firstRoundMatchCount == 0) return 0;
    return firstRoundMatchCount * TournamentMatch.cardSize.height +
        (firstRoundMatchCount - 1) * TournamentMatch.verticalGap;
  }
}
