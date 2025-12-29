/// 對陣圖連線繪製器
library;

import 'package:flutter/material.dart';

import '../models/tournament_match.dart';

/// CustomPainter 實作，繪製比賽之間的 S 型貝茲曲線連接線
class BracketConnectionPainter extends CustomPainter {
  /// 錦標賽資料
  final TournamentBracket bracket;

  /// 連線顏色
  final Color lineColor;

  /// 連線寬度
  final double lineWidth;

  BracketConnectionPainter({
    required this.bracket,
    this.lineColor = const Color(0xFF6B7280),
    this.lineWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 遍歷每個輪次 (從第二輪開始，因為第一輪沒有來源)
    for (var roundIndex = 1; roundIndex < bracket.rounds.length; roundIndex++) {
      final currentRound = bracket.rounds[roundIndex];
      final previousRound = bracket.rounds[roundIndex - 1];

      for (
        var matchIndex = 0;
        matchIndex < currentRound.matches.length;
        matchIndex++
      ) {
        final targetMatch = currentRound.matches[matchIndex];
        if (targetMatch.position == null) continue;

        // 找到兩個來源比賽
        final sourceMatchIndex1 = matchIndex * 2;
        final sourceMatchIndex2 = matchIndex * 2 + 1;

        // 繪製從來源 1 到目標的連線
        if (sourceMatchIndex1 < previousRound.matches.length) {
          final sourceMatch1 = previousRound.matches[sourceMatchIndex1];
          if (sourceMatch1.position != null) {
            _drawBezierCurve(
              canvas,
              paint,
              sourceMatch1.rightCenter,
              targetMatch.leftCenter,
            );
          }
        }

        // 繪製從來源 2 到目標的連線
        if (sourceMatchIndex2 < previousRound.matches.length) {
          final sourceMatch2 = previousRound.matches[sourceMatchIndex2];
          if (sourceMatch2.position != null) {
            _drawBezierCurve(
              canvas,
              paint,
              sourceMatch2.rightCenter,
              targetMatch.leftCenter,
            );
          }
        }
      }
    }
  }

  /// 繪製 S 型貝茲曲線
  void _drawBezierCurve(Canvas canvas, Paint paint, Offset start, Offset end) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // 計算控制點，形成 S 型曲線
    final controlPoint1 = Offset(start.dx + (end.dx - start.dx) / 2, start.dy);
    final controlPoint2 = Offset(start.dx + (end.dx - start.dx) / 2, end.dy);

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      end.dx,
      end.dy,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BracketConnectionPainter oldDelegate) {
    return bracket != oldDelegate.bracket ||
        lineColor != oldDelegate.lineColor ||
        lineWidth != oldDelegate.lineWidth;
  }
}
