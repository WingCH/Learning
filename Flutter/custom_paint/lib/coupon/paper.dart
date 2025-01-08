import 'dart:math';
import 'package:flutter/material.dart';

class Paper extends StatelessWidget {
  const Paper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.white,
        width: 335,
        height: 118,
        child: CustomPaint(
          painter: PaperPainter(),
        ),
      ),
    );
  }
}

class PaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 底色 (可視需要關掉)
    canvas.drawColor(Colors.grey.shade200, BlendMode.srcOver);

    // 用來展示各條線段、弧線的不同顏色
    final paintLines = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // （1）定義參數
    const double margin = 10.0; // 與四邊的距離
    const double notchRadius = 10.0; // 上下凹口的半徑
    const double cornerRadius = 8.0; // 票券四角的圓角

    // 透過 size.width、size.height 動態計算
    const double left = margin;
    const double top = margin;
    final double right = size.width - margin;
    final double bottom = size.height - margin;
    final double centerX = (left + right) / 2;

    // 為了最後「整塊填色」，先建立同一個 Path
    final path = Path();

    //
    // 第一步：moveTo 到「左上角圓角的切點」
    //
    // 起點： (left + cornerRadius, top)
    //
    paintLines.color = Colors.red;
    paintLines.strokeWidth = 3;
    canvas.drawCircle(
      const Offset(left + cornerRadius, top),
      3,
      paintLines,
    );
    // 畫個小文字註記
    _drawText(
      canvas,
      '起點',
      const Offset(left + cornerRadius + 5, top - 20),
      color: Colors.red,
    );

    path.moveTo(left + cornerRadius, top);

    //
    // 第二步：畫上邊到「上凹口左端」的線段
    //
    // 終點： (centerX - notchRadius, top)
    //
    paintLines.color = Colors.blue;
    canvas.drawLine(
      const Offset(left + cornerRadius, top),
      Offset(centerX - notchRadius, top),
      paintLines,
    );
    _drawText(
      canvas,
      '上邊線',
      Offset((left + cornerRadius + (centerX - notchRadius)) / 2, top - 20),
      color: Colors.blue,
    );

    // Path 本身也要 lineTo 這個點
    path.lineTo(centerX - notchRadius, top);

    //
    // 第三步：畫「上凹口」的弧線 arcToPoint
    //
    // 終點： (centerX + notchRadius, top)
    //
    paintLines.color = Colors.orange;
    paintLines.style = PaintingStyle.stroke;
    Path tempArc1 = Path();
    tempArc1.moveTo(centerX - notchRadius, top);
    tempArc1.arcToPoint(
      Offset(centerX + notchRadius, top),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    canvas.drawPath(tempArc1, paintLines);

    path.arcToPoint(
      Offset(centerX + notchRadius, top),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    //
    // 第四步：畫右上角直到右上角圓角
    //
    // 從 (centerX + notchRadius, top) -> (right - cornerRadius, top)
    // 再用 quadraticBezierTo 做右上角圓角
    //
    paintLines.color = Colors.purple;
    // 先畫直線
    canvas.drawLine(
      Offset(centerX + notchRadius, top),
      Offset(right - cornerRadius, top),
      paintLines,
    );
    // 小圓點標記 corner
    canvas.drawCircle(
      Offset(right - cornerRadius, top),
      3,
      paintLines,
    );

    // 用同一色再把圓角畫出來
    Path tempArc2 = Path();
    tempArc2.moveTo(right - cornerRadius, top);
    tempArc2.quadraticBezierTo(
      right,
      top,
      right,
      top + cornerRadius,
    );
    canvas.drawPath(tempArc2, paintLines);

    // Path
    path.lineTo(right - cornerRadius, top);
    path.quadraticBezierTo(
      right,
      top,
      right,
      top + cornerRadius,
    );

    //
    // 第五步：右側往下到「右下角圓角」
    //
    // 先畫直線
    paintLines.color = Colors.brown;
    Path tempLine3 = Path();
    tempLine3.moveTo(right, top + cornerRadius);
    tempLine3.lineTo(right, bottom - cornerRadius);
    canvas.drawPath(tempLine3, paintLines);

    // 再畫下方圓角
    Path tempArc3 = Path();
    tempArc3.moveTo(right, bottom - cornerRadius);
    tempArc3.quadraticBezierTo(
      right,
      bottom,
      right - cornerRadius,
      bottom,
    );
    canvas.drawPath(tempArc3, paintLines);

    // Path
    path.lineTo(right, bottom - cornerRadius);
    path.quadraticBezierTo(
      right,
      bottom,
      right - cornerRadius,
      bottom,
    );

    //
    // 第六步：畫「下凹口」的 lineTo + arc
    //
    // lineTo -> (centerX + notchRadius, bottom)
    // arcTo -> (centerX - notchRadius, bottom)
    //
    paintLines.color = Colors.green;
    canvas.drawLine(
      Offset(right - cornerRadius, bottom),
      Offset(centerX + notchRadius, bottom),
      paintLines,
    );
    // 畫 arc
    Path tempArc4 = Path();
    tempArc4.moveTo(centerX + notchRadius, bottom);
    tempArc4.arcToPoint(
      Offset(centerX - notchRadius, bottom),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    canvas.drawPath(tempArc4, paintLines);

    // Path
    path.lineTo(centerX + notchRadius, bottom);
    path.arcToPoint(
      Offset(centerX - notchRadius, bottom),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    //
    // 第七步：左下角圓角 + 左側往上
    //
    paintLines.color = Colors.cyan;
    // 先畫到 (left + cornerRadius, bottom)
    canvas.drawLine(
      Offset(centerX - notchRadius, bottom),
      Offset(left + cornerRadius, bottom),
      paintLines,
    );
    // 再畫左下角圓角
    Path tempArc5 = Path();
    tempArc5.moveTo(left + cornerRadius, bottom);
    tempArc5.quadraticBezierTo(
      left,
      bottom,
      left,
      bottom - cornerRadius,
    );
    canvas.drawPath(tempArc5, paintLines);

    // 左側向上
    Path tempLine4 = Path();
    tempLine4.moveTo(left, bottom - cornerRadius);
    tempLine4.lineTo(left, top + cornerRadius);
    canvas.drawPath(tempLine4, paintLines);

    // 左上角圓角
    Path tempArc6 = Path();
    tempArc6.moveTo(left, top + cornerRadius);
    tempArc6.quadraticBezierTo(
      left,
      top,
      left + cornerRadius,
      top,
    );
    canvas.drawPath(tempArc6, paintLines);

    // Path
    path.lineTo(left + cornerRadius, bottom);
    path.quadraticBezierTo(
      left,
      bottom,
      left,
      bottom - cornerRadius,
    );
    path.lineTo(left, top + cornerRadius);
    path.quadraticBezierTo(
      left,
      top,
      left + cornerRadius,
      top,
    );

    // 至此完成整個封閉路徑
    path.close();

    //
    // 最終：真正的「填充」整塊形狀
    //
    // 可以在最上面或最下面做，這裡放在最後，讓前面分段示意的顏色不會被覆蓋太早。
    //
    final paintFill = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paintFill);
  }

  @override
  bool shouldRepaint(PaperPainter oldDelegate) => true;

  // 簡易畫文字的方法
  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    Color color = Colors.black,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }
}
