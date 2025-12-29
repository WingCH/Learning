/// 比賽卡片組件
library;

import 'package:flutter/material.dart';

import '../models/tournament_match.dart';

/// 顯示單場比賽資訊的卡片
class MatchCard extends StatelessWidget {
  /// 比賽資料
  final TournamentMatch match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: TournamentMatch.cardSize.width,
      height: TournamentMatch.cardSize.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26), // 0.1 * 255
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTeamRow(
            match.teamA,
            match.scoreA,
            isWinner: match.winner == match.teamA,
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
          _buildTeamRow(
            match.teamB,
            match.scoreB,
            isWinner: match.winner == match.teamB,
          ),
        ],
      ),
    );
  }

  /// 建立隊伍行
  Widget _buildTeamRow(String teamName, int? score, {required bool isWinner}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            // 獲勝標記
            if (isWinner)
              Container(
                width: 4,
                height: 16,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(width: 10),
            // 隊伍名稱
            Expanded(
              child: Text(
                teamName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                  color: isWinner
                      ? const Color(0xFF111827)
                      : const Color(0xFF6B7280),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 分數
            if (score != null)
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isWinner
                      ? const Color(0xFF10B981)
                      : const Color(0xFF6B7280),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
